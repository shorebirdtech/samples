import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clear_skies/features/features.dart';

void main() {
  group('FavoritesRepository', () {
    late FavoritesRepository favoritesRepository;

    setUp(() {
      SharedPreferences.setMockInitialValues({
        'favorite_cities': ['London', 'Paris'],
      });
      favoritesRepository = FavoritesRepository();
    });

    test('getFavorites returns list of cities', () async {
      final cities = await favoritesRepository.getFavorites();
      expect(cities, ['London', 'Paris']);
    });

    test('getFavorites returns empty list when no data is present', () async {
      SharedPreferences.setMockInitialValues({});
      final cities = await favoritesRepository.getFavorites();
      expect(cities, isEmpty);
    });

    test('saveFavorites persists the list of cities', () async {
      await favoritesRepository.saveFavorites(['New York']);

      final prefs = await SharedPreferences.getInstance();
      final savedCities = prefs.getStringList('favorite_cities');

      expect(savedCities, ['New York']);
    });
  });
}
