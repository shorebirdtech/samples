import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/features/leaderboard/models/leaderboard_entry_model.dart';

enum LeaderboardStatus { initial, loading, success, failure }

/// Whether the latest recorded score made it to the remote leaderboard.
enum ScoreSyncStatus { idle, syncing, synced, failed }

class LeaderboardState extends Equatable {
  final LeaderboardStatus status;
  final List<LeaderboardEntryModel> allEntries;
  final List<LeaderboardEntryModel> filteredEntries;
  final String selectedEvent;
  final List<String> availableEvents;
  final String searchQuery;
  final String? errorMessage;
  final ScoreSyncStatus scoreSyncStatus;

  /// The score that failed to post, kept so the player can retry once
  /// they're back online.
  final LeaderboardEntryModel? pendingScore;

  const LeaderboardState({
    this.status = LeaderboardStatus.initial,
    this.allEntries = const [],
    this.filteredEntries = const [],
    this.selectedEvent = 'All Events',
    this.availableEvents = const ['All Events'],
    this.searchQuery = '',
    this.errorMessage,
    this.scoreSyncStatus = ScoreSyncStatus.idle,
    this.pendingScore,
  });

  LeaderboardState copyWith({
    LeaderboardStatus? status,
    List<LeaderboardEntryModel>? allEntries,
    List<LeaderboardEntryModel>? filteredEntries,
    String? selectedEvent,
    List<String>? availableEvents,
    String? searchQuery,
    String? errorMessage,
    ScoreSyncStatus? scoreSyncStatus,
    LeaderboardEntryModel? Function()? pendingScore,
  }) {
    return LeaderboardState(
      status: status ?? this.status,
      allEntries: allEntries ?? this.allEntries,
      filteredEntries: filteredEntries ?? this.filteredEntries,
      selectedEvent: selectedEvent ?? this.selectedEvent,
      availableEvents: availableEvents ?? this.availableEvents,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      scoreSyncStatus: scoreSyncStatus ?? this.scoreSyncStatus,
      pendingScore: pendingScore != null ? pendingScore() : this.pendingScore,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allEntries,
        filteredEntries,
        selectedEvent,
        availableEvents,
        searchQuery,
        errorMessage,
        scoreSyncStatus,
        pendingScore,
      ];
}
