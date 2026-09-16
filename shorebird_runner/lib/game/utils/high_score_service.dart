import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes the same stored high score as [HighScoreRepository].
///
/// These used to be two different keys: the game wrote `patch_rush_high_score`
/// on crash and showed it in the HUD, while SoloRunnerBloc wrote
/// `shorebird_runner_high_score` and used *that* for the game-over screen and
/// the NEW RECORD decision. One value lived in two stores, so the two screens
/// could disagree and a record could be judged against a total the HUD never
/// showed. The repository's key wins; the old one is migrated on first read so
/// a booth machine mid-event does not appear to lose its high score.
class HighScoreService {
  static const _key = 'shorebird_runner_high_score';
  static const _legacyKey = 'patch_rush_high_score';

  static Future<int> load() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_key) ?? 0;
    final legacy = prefs.getInt(_legacyKey) ?? 0;
    if (legacy > current) {
      await prefs.setInt(_key, legacy);
      return legacy;
    }
    return current;
  }

  static Future<void> save(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_key) ?? 0;
    if (score > current) {
      await prefs.setInt(_key, score);
    }
  }
}
