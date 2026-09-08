import 'package:shared_preferences/shared_preferences.dart';
import 'package:shorebird_runner/core/storage/i_high_score_repository.dart';

/// SharedPreferences implementation of [IHighScoreRepository].
class HighScoreRepository implements IHighScoreRepository {
  static const String _key = 'shorebird_runner_high_score';

  const HighScoreRepository();

  @override
  Future<int> loadHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_key) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<void> saveHighScore(int score) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_key) ?? 0;
      if (score > current) {
        await prefs.setInt(_key, score);
      }
    } catch (_) {}
  }
}
