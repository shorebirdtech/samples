import 'package:flutter_test/flutter_test.dart';
import 'package:clear_skies/features/features.dart';

void main() {
  group('WeatherState', () {
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
      final state1 = const WeatherState();
      final state2 = const WeatherState();

      expect(state1, equals(state2));
      expect(state1.props, [WeatherStatus.initial, null, null]);
    });

    test('copyWith returns same object if no arguments are provided', () {
      final state = const WeatherState();
      expect(state.copyWith(), equals(state));
    });

    test('copyWith returns updated object with new values', () {
      final state = const WeatherState();
      final updatedState = state.copyWith(
        status: WeatherStatus.loaded,
        weather: mockWeather,
        errorMessage: 'Error',
      );

      expect(updatedState.status, WeatherStatus.loaded);
      expect(updatedState.weather, mockWeather);
      expect(updatedState.errorMessage, 'Error');
    });
  });
}
