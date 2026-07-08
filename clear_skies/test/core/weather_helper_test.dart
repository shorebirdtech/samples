import 'package:flutter_test/flutter_test.dart';
import 'package:clear_skies/core/core.dart';

void main() {
  group('WeatherHelper', () {
    group('getWeatherIcon', () {
      test('returns clear sky icon for 0', () {
        expect(WeatherHelper.getWeatherIcon(0), '☀️');
      });

      test('returns partly cloudy icon for 1, 2, 3', () {
        expect(WeatherHelper.getWeatherIcon(1), '🌤️');
        expect(WeatherHelper.getWeatherIcon(2), '🌤️');
        expect(WeatherHelper.getWeatherIcon(3), '🌤️');
      });

      test('returns fog icon for 45, 48', () {
        expect(WeatherHelper.getWeatherIcon(45), '🌫️');
        expect(WeatherHelper.getWeatherIcon(48), '🌫️');
      });

      test('returns rain icon for 51, 53, 55, 61, 63, 65', () {
        final rainCodes = [51, 53, 55, 61, 63, 65];
        for (var code in rainCodes) {
          expect(WeatherHelper.getWeatherIcon(code), '🌧️');
        }
      });

      test('returns rain showers icon for 80, 81, 82', () {
        final rainCodes = [80, 81, 82];
        for (var code in rainCodes) {
          expect(WeatherHelper.getWeatherIcon(code), '🌦️');
        }
      });

      test('returns snow icon for 71, 73, 75, 77', () {
        final snowCodes = [71, 73, 75, 77];
        for (var code in snowCodes) {
          expect(WeatherHelper.getWeatherIcon(code), '❄️');
        }
      });

      test('returns storm icon for 95, 96, 99', () {
        final stormCodes = [95, 96, 99];
        for (var code in stormCodes) {
          expect(WeatherHelper.getWeatherIcon(code), '⛈️');
        }
      });

      test('returns default icon for unknown codes', () {
        expect(WeatherHelper.getWeatherIcon(999), '🌈');
      });
    });
  });
}
