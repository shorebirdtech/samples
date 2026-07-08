import 'package:flutter_test/flutter_test.dart';
import 'package:clear_skies/features/features.dart';

void main() {
  group('Weather Model', () {
    test('fromJson constructs Weather correctly', () {
      final json = {
        'current': {
          'temperature_2m': 20.5,
          'weather_code': 1,
          'is_day': 1,
          'relative_humidity_2m': 45,
          'apparent_temperature': 19.0,
          'wind_speed_10m': 5.5,
        },
        'daily': {
          'time': ['2023-10-25', '2023-10-26'],
          'weather_code': [1, 2],
          'temperature_2m_max': [22.0, 21.0],
          'temperature_2m_min': [15.0, 14.0],
        }
      };

      final weather = Weather.fromJson('London', json);

      expect(weather.cityName, 'London');
      expect(weather.temperature, 20.5);
      expect(weather.weatherCode, 1);
      expect(weather.isDay, true);
      expect(weather.humidity, 45);
      expect(weather.feelsLike, 19.0);
      expect(weather.windSpeed, 5.5);
      expect(weather.forecast.length, 2);
      expect(weather.forecast[0].date, DateTime.parse('2023-10-25'));
      expect(weather.forecast[0].maxTemp, 22.0);
      expect(weather.forecast[0].minTemp, 15.0);
      expect(weather.forecast[0].weatherCode, 1);
      
      expect(weather.props, [
        'London',
        20.5,
        1,
        true,
        45,
        19.0,
        5.5,
        weather.forecast
      ]);
    });

    test('isDay handles 0 as false', () {
      final json = {
        'current': {
          'temperature_2m': 20.5,
          'weather_code': 1,
          'is_day': 0,
          'relative_humidity_2m': 45,
          'apparent_temperature': 19.0,
          'wind_speed_10m': 5.5,
        },
        'daily': {
          'time': [],
          'weather_code': [],
          'temperature_2m_max': [],
          'temperature_2m_min': [],
        }
      };

      final weather = Weather.fromJson('Paris', json);
      expect(weather.isDay, false);
    });
  });

  group('DailyForecast', () {
    test('props includes all fields', () {
      final forecast = DailyForecast(
        date: DateTime.parse('2023-10-25'),
        maxTemp: 22.0,
        minTemp: 15.0,
        weatherCode: 1,
      );

      expect(forecast.props, [DateTime.parse('2023-10-25'), 1, 22.0, 15.0]);
    });
  });

  group('CitySuggestion Model', () {
    test('displayName returns correctly with admin1 and country', () {
      final city = CitySuggestion(
        name: 'London',
        admin1: 'England',
        country: 'United Kingdom',
        latitude: 51.5,
        longitude: -0.12,
      );

      expect(city.displayName, 'London, England, United Kingdom');
      expect(city.props, ['London', 'England', 'United Kingdom', 51.5, -0.12]);
    });

    test('displayName returns correctly without admin1', () {
      final city = CitySuggestion(
        name: 'London',
        country: 'United Kingdom',
        latitude: 51.5,
        longitude: -0.12,
      );

      expect(city.displayName, 'London, United Kingdom');
    });

    test('displayName returns correctly without country', () {
      final city = CitySuggestion(
        name: 'London',
        admin1: 'England',
        latitude: 51.5,
        longitude: -0.12,
      );

      expect(city.displayName, 'London, England');
    });

    test('displayName returns just name if admin1 and country are null', () {
      final city = CitySuggestion(
        name: 'London',
        latitude: 51.5,
        longitude: -0.12,
      );

      expect(city.displayName, 'London');
    });
  });
}
