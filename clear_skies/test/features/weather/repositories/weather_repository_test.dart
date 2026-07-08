import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:clear_skies/features/features.dart';
import 'package:clear_skies/core/core.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  group('WeatherRepository', () {
    late WeatherRepository weatherRepository;
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      weatherRepository = WeatherRepository(httpClient: mockHttpClient);
    });

    group('getWeather', () {
      final String city = 'London';
      final String geoUrlStr = AppStrings.geoUrl(city);

      test('returns Weather on successful fetch', () async {
        final mockGeoResponse = {
          'results': [
            {'latitude': 51.50853, 'longitude': -0.12574, 'name': 'London'}
          ]
        };

        final mockWeatherResponse = {
          'current': {
            'temperature_2m': 15.0,
            'weather_code': 1,
            'is_day': 1,
            'relative_humidity_2m': 50,
            'apparent_temperature': 14.5,
            'wind_speed_10m': 10.0,
          },
          'daily': {
            'time': ['2023-10-25', '2023-10-26'],
            'weather_code': [1, 2],
            'temperature_2m_max': [16.0, 17.0],
            'temperature_2m_min': [10.0, 11.0],
          }
        };

        when(() => mockHttpClient.get(Uri.parse(geoUrlStr)))
            .thenAnswer((_) async => http.Response(jsonEncode(mockGeoResponse), 200));

        when(() => mockHttpClient.get(any(that: predicate<Uri>((uri) => uri.toString().contains('/v1/forecast')))))
            .thenAnswer((_) async => http.Response(jsonEncode(mockWeatherResponse), 200));

        final result = await weatherRepository.getWeather(city);

        expect(result.cityName, 'London');
        expect(result.temperature, 15.0);
        expect(result.weatherCode, 1);
        expect(result.isDay, true);
        expect(result.humidity, 50);
        expect(result.feelsLike, 14.5);
        expect(result.windSpeed, 10.0);
        expect(result.forecast.length, 2);
        
        verify(() => mockHttpClient.get(Uri.parse(geoUrlStr))).called(1);
      });

      test('throws Exception when geo fetch fails (non-200)', () async {
        when(() => mockHttpClient.get(Uri.parse(geoUrlStr)))
            .thenAnswer((_) async => http.Response('Error', 404));

        expect(
          () => weatherRepository.getWeather(city),
          throwsA(isA<Exception>()),
        );
      });

      test('throws Exception when city is not found in results', () async {
        final mockGeoResponse = {'results': []};

        when(() => mockHttpClient.get(Uri.parse(geoUrlStr)))
            .thenAnswer((_) async => http.Response(jsonEncode(mockGeoResponse), 200));

        expect(
          () => weatherRepository.getWeather(city),
          throwsA(isA<Exception>()),
        );
      });

      test('throws Exception when weather fetch fails (non-200)', () async {
        final mockGeoResponse = {
          'results': [
            {'latitude': 51.50853, 'longitude': -0.12574, 'name': 'London'}
          ]
        };

        when(() => mockHttpClient.get(Uri.parse(geoUrlStr)))
            .thenAnswer((_) async => http.Response(jsonEncode(mockGeoResponse), 200));

        when(() => mockHttpClient.get(any(that: predicate<Uri>((uri) => uri.toString().contains('/v1/forecast')))))
            .thenAnswer((_) async => http.Response('Error', 500));

        expect(
          () => weatherRepository.getWeather(city),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('searchCities', () {
      test('returns empty list for empty query', () async {
        final results = await weatherRepository.searchCities('   ');
        expect(results, isEmpty);
        verifyNever(() => mockHttpClient.get(any()));
      });

      test('returns list of CitySuggestion on successful search', () async {
        final query = 'Lon';
        final mockSearchResponse = {
          'results': [
            {
              'name': 'London',
              'admin1': 'England',
              'country': 'United Kingdom',
              'latitude': 51.50853,
              'longitude': -0.12574,
            },
            {
              'name': 'London',
              'admin1': 'Ontario',
              'country': 'Canada',
              'latitude': 42.98339,
              'longitude': -81.23304,
            }
          ]
        };

        when(() => mockHttpClient.get(Uri.parse(AppStrings.geoSearchUrl(query))))
            .thenAnswer((_) async => http.Response(jsonEncode(mockSearchResponse), 200));

        final results = await weatherRepository.searchCities(query);

        expect(results.length, 2);
        expect(results[0].name, 'London');
        expect(results[0].country, 'United Kingdom');
        expect(results[1].name, 'London');
        expect(results[1].country, 'Canada');
      });

      test('filters out duplicate display names', () async {
        final query = 'Lon';
        final mockSearchResponse = {
          'results': [
            {
              'name': 'London',
              'admin1': 'England',
              'country': 'United Kingdom',
              'latitude': 51.50853,
              'longitude': -0.12574,
            },
            {
              'name': 'London',
              'admin1': 'England',
              'country': 'United Kingdom',
              'latitude': 51.51,
              'longitude': -0.13,
            }
          ]
        };

        when(() => mockHttpClient.get(Uri.parse(AppStrings.geoSearchUrl(query))))
            .thenAnswer((_) async => http.Response(jsonEncode(mockSearchResponse), 200));

        final results = await weatherRepository.searchCities(query);

        // Expect only 1 because the displayName is identical ("London, England, United Kingdom")
        expect(results.length, 1);
      });

      test('returns empty list when results key is missing or empty', () async {
        final query = 'InvalidCity';
        
        when(() => mockHttpClient.get(Uri.parse(AppStrings.geoSearchUrl(query))))
            .thenAnswer((_) async => http.Response(jsonEncode({'results': []}), 200));

        final results = await weatherRepository.searchCities(query);
        expect(results, isEmpty);
      });
      
      test('returns empty list when geo fetch fails (non-200)', () async {
        final query = 'Lon';
        
        when(() => mockHttpClient.get(Uri.parse(AppStrings.geoSearchUrl(query))))
            .thenAnswer((_) async => http.Response('Error', 500));

        final results = await weatherRepository.searchCities(query);
        expect(results, isEmpty);
      });
    });
  });
}
