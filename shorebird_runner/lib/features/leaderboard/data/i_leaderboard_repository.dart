import 'package:shorebird_runner/features/leaderboard/models/leaderboard_entry_model.dart';

abstract class ILeaderboardRepository {
  /// Fetches top leaderboard scores, optionally filtered by event.
  Future<List<LeaderboardEntryModel>> getScores({String? event});

  /// Submits a new score entry to the leaderboard.
  ///
  /// Throws [ScoreSyncException] when the score could not reach the remote
  /// leaderboard (e.g. the device is offline) so the UI can ask the player to
  /// reconnect and retry. The score is still saved locally in that case.
  Future<void> submitScore(LeaderboardEntryModel entry);

  /// Posts any scores that were saved while offline to the remote
  /// leaderboard. Returns how many are still waiting to be posted.
  Future<int> syncPendingScores();

  /// Retrieves list of distinct events available on the leaderboard.
  Future<List<String>> getEvents();
}

/// The score was saved locally but could not be posted to the remote
/// leaderboard.
class ScoreSyncException implements Exception {
  final String message;

  const ScoreSyncException(this.message);

  @override
  String toString() => 'ScoreSyncException: $message';
}
