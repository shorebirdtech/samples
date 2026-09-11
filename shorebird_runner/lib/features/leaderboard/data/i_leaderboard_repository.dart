import 'package:shorebird_runner/features/leaderboard/models/leaderboard_entry_model.dart';

abstract class ILeaderboardRepository {
  /// Fetches top leaderboard scores, optionally filtered by event.
  Future<List<LeaderboardEntryModel>> getScores({String? event});

  /// Submits a new score entry to the leaderboard.
  Future<void> submitScore(LeaderboardEntryModel entry);

  /// Retrieves list of distinct events available on the leaderboard.
  Future<List<String>> getEvents();
}
