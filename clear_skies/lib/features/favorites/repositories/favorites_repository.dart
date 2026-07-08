import 'package:shared_preferences/shared_preferences.dart';

class FavoritesRepository {
  Future<List<String>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesList = prefs.getStringList('favorite_cities');
      return favoritesList?.toList() ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFavorites(List<String> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorite_cities', favorites);
    } catch (_) {}
  }
}
