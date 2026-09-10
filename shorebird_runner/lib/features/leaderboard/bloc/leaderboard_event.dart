import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/features/leaderboard/models/leaderboard_entry_model.dart';

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchLeaderboard extends LeaderboardEvent {
  final String? initialEvent;

  const FetchLeaderboard({this.initialEvent});

  @override
  List<Object?> get props => [initialEvent];
}

class FilterLeaderboardByEvent extends LeaderboardEvent {
  final String? event;

  const FilterLeaderboardByEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class SearchLeaderboard extends LeaderboardEvent {
  final String query;

  const SearchLeaderboard(this.query);

  @override
  List<Object?> get props => [query];
}

class RecordScore extends LeaderboardEvent {
  final LeaderboardEntryModel entry;

  const RecordScore(this.entry);

  @override
  List<Object?> get props => [entry];
}

class RefreshLeaderboard extends LeaderboardEvent {
  const RefreshLeaderboard();
}
