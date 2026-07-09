import 'package:flutter_test/flutter_test.dart';
import 'package:clear_skies/features/features.dart';

void main() {
  group('FavoritesState', () {
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

    test('supports value equality', () {
      final state1 = const FavoritesState();
      final state2 = const FavoritesState();

      expect(state1, equals(state2));
      expect(state1.props, [FavoritesStatus.initial, [], null]);
    });

    test('copyWith returns same object if no arguments are provided', () {
      final state = const FavoritesState();
      expect(state.copyWith(), equals(state));
    });

    test('copyWith returns updated object with new values', () {
      final state = const FavoritesState();
      final updatedState = state.copyWith(
        status: FavoritesStatus.loaded,
        favorites: [mockWeather],
        errorMessage: 'Error',
      );

      expect(updatedState.status, FavoritesStatus.loaded);
      expect(updatedState.favorites, [mockWeather]);
      expect(updatedState.errorMessage, 'Error');
    });
  });
}
