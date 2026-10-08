import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/features/leaderboard/bloc/leaderboard_event.dart';
import 'package:shorebird_runner/features/leaderboard/bloc/leaderboard_state.dart';
import 'package:shorebird_runner/features/leaderboard/data/i_leaderboard_repository.dart';
import 'package:shorebird_runner/features/leaderboard/models/leaderboard_entry_model.dart';

export 'leaderboard_event.dart';
export 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final ILeaderboardRepository repository;

  /// How often queued offline scores are retried while any are waiting.
  static const pendingSyncInterval = Duration(seconds: 30);

  Timer? _pendingSyncTimer;

  LeaderboardBloc({required this.repository})
      : super(const LeaderboardState()) {
    on<FetchLeaderboard>(_onFetchLeaderboard);
    on<FilterLeaderboardByEvent>(_onFilterByEvent);
    on<SearchLeaderboard>(_onSearchLeaderboard);
    on<RecordScore>(_onRecordScore);
    on<RetryScoreSync>(_onRetryScoreSync);
    on<SyncPendingScores>(_onSyncPendingScores);
    on<RefreshLeaderboard>(_onRefreshLeaderboard);

    add(const SyncPendingScores());
  }

  @override
  Future<void> close() {
    _pendingSyncTimer?.cancel();
    return super.close();
  }

  Future<void> _onSyncPendingScores(
    SyncPendingScores event,
    Emitter<LeaderboardState> emit,
  ) async {
    final int remaining;
    try {
      remaining = await repository.syncPendingScores();
    } catch (_) {
      _schedulePendingSync();
      return;
    }
    if (remaining > 0) {
      _schedulePendingSync();
      return;
    }
    _pendingSyncTimer?.cancel();
    _pendingSyncTimer = null;
    if (state.scoreSyncStatus == ScoreSyncStatus.failed) {
      emit(
        state.copyWith(
          scoreSyncStatus: ScoreSyncStatus.synced,
          pendingScore: () => null,
        ),
      );
      add(const RefreshLeaderboard());
    }
  }

  void _schedulePendingSync() {
    if (isClosed) return;
    _pendingSyncTimer?.cancel();
    _pendingSyncTimer = Timer(
      pendingSyncInterval,
      () => isClosed ? null : add(const SyncPendingScores()),
    );
  }

  Future<void> _onFetchLeaderboard(
    FetchLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(state.copyWith(status: LeaderboardStatus.loading));

    final targetEvent = event.initialEvent ?? state.selectedEvent;

    try {
      final scores = await repository.getScores();
      final eventList = await repository.getEvents();

      final available = ['All Events'];
      for (final e in eventList) {
        if (!available.contains(e)) available.add(e);
      }

      // Ensure active event is in available list
      if (targetEvent.isNotEmpty && !available.contains(targetEvent)) {
        available.add(targetEvent);
      }

      final filtered = _applyFilterAndSearch(
        entries: scores,
        event: targetEvent,
        query: state.searchQuery,
      );

      emit(
        state.copyWith(
          status: LeaderboardStatus.success,
          allEntries: scores,
          filteredEntries: filtered,
          selectedEvent: targetEvent,
          availableEvents: available,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LeaderboardStatus.failure,
          errorMessage: 'Failed to load leaderboard scores.',
        ),
      );
    }
  }

  void _onFilterByEvent(
    FilterLeaderboardByEvent event,
    Emitter<LeaderboardState> emit,
  ) {
    final newEvent = event.event ?? 'All Events';
    final filtered = _applyFilterAndSearch(
      entries: state.allEntries,
      event: newEvent,
      query: state.searchQuery,
    );

    emit(
      state.copyWith(
        selectedEvent: newEvent,
        filteredEntries: filtered,
      ),
    );
  }

  void _onSearchLeaderboard(
    SearchLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) {
    final filtered = _applyFilterAndSearch(
      entries: state.allEntries,
      event: state.selectedEvent,
      query: event.query,
    );

    emit(
      state.copyWith(
        searchQuery: event.query,
        filteredEntries: filtered,
      ),
    );
  }

  Future<void> _onRecordScore(
    RecordScore event,
    Emitter<LeaderboardState> emit,
  ) =>
      _syncScore(event.entry, emit);

  Future<void> _onRetryScoreSync(
    RetryScoreSync event,
    Emitter<LeaderboardState> emit,
  ) async {
    final pending = state.pendingScore;
    if (pending == null) return;
    await _syncScore(pending, emit);
  }

  Future<void> _syncScore(
    LeaderboardEntryModel entry,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(
      state.copyWith(
        scoreSyncStatus: ScoreSyncStatus.syncing,
        pendingScore: () => entry,
      ),
    );
    try {
      await repository.submitScore(entry);
      emit(
        state.copyWith(
          scoreSyncStatus: ScoreSyncStatus.synced,
          pendingScore: () => null,
        ),
      );
    } catch (_) {
      // The repository keeps it queued and it is retried in the background;
      // the banner lets the player reconnect and retry right away.
      emit(state.copyWith(scoreSyncStatus: ScoreSyncStatus.failed));
      _schedulePendingSync();
    }
    add(const RefreshLeaderboard());
  }

  Future<void> _onRefreshLeaderboard(
    RefreshLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    try {
      final scores = await repository.getScores();
      final eventList = await repository.getEvents();

      final available = ['All Events'];
      for (final e in eventList) {
        if (!available.contains(e)) available.add(e);
      }

      final filtered = _applyFilterAndSearch(
        entries: scores,
        event: state.selectedEvent,
        query: state.searchQuery,
      );

      emit(
        state.copyWith(
          status: LeaderboardStatus.success,
          allEntries: scores,
          filteredEntries: filtered,
          availableEvents: available,
        ),
      );
    } catch (_) {}
  }

  List<LeaderboardEntryModel> _applyFilterAndSearch({
    required List<LeaderboardEntryModel> entries,
    required String event,
    required String query,
  }) {
    final ranked = rankedForEvent(entries, event);
    if (query.trim().isEmpty) return ranked;

    // Filtering after sorting keeps the result a subsequence of the ranked
    // board, so rows can still be shown with their board rank.
    final q = query.trim().toLowerCase();
    return ranked.where((e) {
      final matchName = e.playerName.toLowerCase().contains(q);
      final matchOrg = e.organization.toLowerCase().contains(q);
      final matchEvent = e.event.toLowerCase().contains(q);
      return matchName || matchOrg || matchEvent;
    }).toList();
  }

  /// The board for [event] (or every event for 'All Events'), highest score
  /// first. A row's rank is its position here, independent of any search.
  static List<LeaderboardEntryModel> rankedForEvent(
    List<LeaderboardEntryModel> entries,
    String event,
  ) {
    var result = List<LeaderboardEntryModel>.from(entries);

    if (event != 'All Events' && event.trim().isNotEmpty) {
      final normalized = event.trim().toLowerCase();
      result = result
          .where((e) => e.event.trim().toLowerCase() == normalized)
          .toList();
    }

    result.sort((a, b) => b.score.compareTo(a.score));
    return result;
  }
}
