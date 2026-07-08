import 'package:flutter_test/flutter_test.dart';
import 'package:clear_skies/features/features.dart';

void main() {
  group('FavoritesEvent', () {
    final mockWeather = Weather(
      cityName: 'London',
      temperature: 15.0,
      weatherCode: 1,
      isDay: true,
      humidity: 50,
      feelsLike: 14.5,
      windSpeed: 10.0,
      forecast: [],
    );

    test('LoadFavorites supports value equality', () {
      expect(LoadFavorites(), equals(LoadFavorites()));
      expect(LoadFavorites().props, isEmpty);
    });

    test('AddFavorite supports value equality', () {
      final event1 = AddFavorite(mockWeather);
      final event2 = AddFavorite(mockWeather);

      expect(event1, equals(event2));
      expect(event1.props, [mockWeather]);
    });

    test('RemoveFavorite supports value equality', () {
      final event1 = const RemoveFavorite('London');
      final event2 = const RemoveFavorite('London');
      final event3 = const RemoveFavorite('Paris');

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
      expect(event1.props, ['London']);
    });
  });
}
