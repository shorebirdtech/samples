import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/features/leaderboard/bloc/leaderboard_event.dart';
import 'package:shorebird_runner/features/leaderboard/bloc/leaderboard_state.dart';
import 'package:shorebird_runner/features/leaderboard/data/i_leaderboard_repository.dart';
import 'package:shorebird_runner/features/leaderboard/models/leaderboard_entry_model.dart';

export 'leaderboard_event.dart';
export 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final ILeaderboardRepository repository;

  LeaderboardBloc({required this.repository})
      : super(const LeaderboardState()) {
    on<FetchLeaderboard>(_onFetchLeaderboard);
    on<FilterLeaderboardByEvent>(_onFilterByEvent);
    on<SearchLeaderboard>(_onSearchLeaderboard);
    on<RecordScore>(_onRecordScore);
    on<RefreshLeaderboard>(_onRefreshLeaderboard);
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
  ) async {
    try {
      await repository.submitScore(event.entry);
      add(const RefreshLeaderboard());
    } catch (_) {}
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
