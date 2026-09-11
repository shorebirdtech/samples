import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/features/leaderboard/models/leaderboard_entry_model.dart';

enum LeaderboardStatus { initial, loading, success, failure }

class LeaderboardState extends Equatable {
  final LeaderboardStatus status;
  final List<LeaderboardEntryModel> allEntries;
  final List<LeaderboardEntryModel> filteredEntries;
  final String selectedEvent;
  final List<String> availableEvents;
  final String searchQuery;
  final String? errorMessage;

  const LeaderboardState({
    this.status = LeaderboardStatus.initial,
    this.allEntries = const [],
    this.filteredEntries = const [],
    this.selectedEvent = 'All Events',
    this.availableEvents = const ['All Events'],
    this.searchQuery = '',
    this.errorMessage,
  });

  LeaderboardState copyWith({
    LeaderboardStatus? status,
    List<LeaderboardEntryModel>? allEntries,
    List<LeaderboardEntryModel>? filteredEntries,
    String? selectedEvent,
    List<String>? availableEvents,
    String? searchQuery,
    String? errorMessage,
  }) {
    return LeaderboardState(
      status: status ?? this.status,
      allEntries: allEntries ?? this.allEntries,
      filteredEntries: filteredEntries ?? this.filteredEntries,
      selectedEvent: selectedEvent ?? this.selectedEvent,
      availableEvents: availableEvents ?? this.availableEvents,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
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
      ];
}
