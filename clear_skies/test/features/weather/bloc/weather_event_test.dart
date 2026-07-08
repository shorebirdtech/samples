import 'package:flutter_test/flutter_test.dart';
import 'package:clear_skies/features/features.dart';

void main() {
  group('WeatherEvent', () {
    test('ResetWeather supports value equality', () {
      expect(ResetWeather(), equals(ResetWeather()));
      expect(ResetWeather().props, isEmpty);
    });

    test('WeatherRequested supports value equality', () {
      final event1 = const WeatherRequested('London');
      final event2 = const WeatherRequested('London');
      final event3 = const WeatherRequested('Paris');

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
      expect(event1.props, ['London']);
    });

    test('WeatherLocationRequested supports value equality', () {
      final event1 = const WeatherLocationRequested(
        latitude: 51.5,
        longitude: -0.12,
        cityName: 'London',
      );
      final event2 = const WeatherLocationRequested(
        latitude: 51.5,
        longitude: -0.12,
        cityName: 'London',
      );
      final event3 = const WeatherLocationRequested(
        latitude: 48.8,
        longitude: 2.35,
        cityName: 'Paris',
      );

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
      expect(event1.props, [51.5, -0.12, 'London']);
    });
  });
}
