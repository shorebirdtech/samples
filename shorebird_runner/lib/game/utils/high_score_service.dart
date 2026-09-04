import 'package:shared_preferences/shared_preferences.dart';

class HighScoreService {
  static const _key = 'patch_rush_high_score';

  static Future<int> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  static Future<void> save(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_key) ?? 0;
    if (score > current) {
      await prefs.setInt(_key, score);
    }
  }
}
