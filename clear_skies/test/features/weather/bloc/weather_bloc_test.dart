import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clear_skies/features/features.dart';
import 'package:clear_skies/core/core.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  group('WeatherBloc', () {
    late WeatherRepository mockWeatherRepository;
    late WeatherBloc weatherBloc;

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

    setUp(() {
      mockWeatherRepository = MockWeatherRepository();
      weatherBloc = WeatherBloc(weatherRepository: mockWeatherRepository);
    });

    tearDown(() {
      weatherBloc.close();
    });

    test('initial state is WeatherState with status initial', () {
      expect(weatherBloc.state.status, WeatherStatus.initial);
    });

    blocTest<WeatherBloc, WeatherState>(
      'emits [loading, loaded] when WeatherRequested succeeds',
      build: () {
        when(
          () => mockWeatherRepository.getWeather('London'),
        ).thenAnswer((_) async => mockWeather);
        return weatherBloc;
      },
      act: (bloc) => bloc.add(const WeatherRequested('London')),
      expect: () => [
        const WeatherState(status: WeatherStatus.loading),
        WeatherState(status: WeatherStatus.loaded, weather: mockWeather),
      ],
      verify: (_) {
        verify(() => mockWeatherRepository.getWeather('London')).called(1);
      },
    );

    blocTest<WeatherBloc, WeatherState>(
      'emits [loading, error] when WeatherRequested fails',
      build: () {
        when(
          () => mockWeatherRepository.getWeather('UnknownCity'),
        ).thenThrow(Exception(AppStrings.errorCityNotFound));
        return weatherBloc;
      },
      act: (bloc) => bloc.add(const WeatherRequested('UnknownCity')),
      expect: () => [
        const WeatherState(status: WeatherStatus.loading),
        WeatherState(
          status: WeatherStatus.error,
          errorMessage: AppStrings.errorCityNotFound,
        ),
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'emits [loading, loaded] when WeatherLocationRequested succeeds',
      build: () {
        when(
          () => mockWeatherRepository.getWeatherByCoordinates(
            51.5,
            -0.12,
            'London',
          ),
        ).thenAnswer((_) async => mockWeather);
        return weatherBloc;
      },
      act: (bloc) => bloc.add(
        const WeatherLocationRequested(
          latitude: 51.5,
          longitude: -0.12,
          cityName: 'London',
        ),
      ),
      expect: () => [
        const WeatherState(status: WeatherStatus.loading),
        WeatherState(status: WeatherStatus.loaded, weather: mockWeather),
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'emits [loading, error] when WeatherLocationRequested fails',
      build: () {
        when(
          () => mockWeatherRepository.getWeatherByCoordinates(
            51.5,
            -0.12,
            'London',
          ),
        ).thenThrow(Exception('Location error'));
        return weatherBloc;
      },
      act: (bloc) => bloc.add(
        const WeatherLocationRequested(
          latitude: 51.5,
          longitude: -0.12,
          cityName: 'London',
        ),
      ),
      expect: () => [
        const WeatherState(status: WeatherStatus.loading),
        const WeatherState(
          status: WeatherStatus.error,
          errorMessage: 'Location error',
        ),
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'emits [initial] when ResetWeather is added',
      build: () => weatherBloc,
      seed: () =>
          WeatherState(status: WeatherStatus.loaded, weather: mockWeather),
      act: (bloc) => bloc.add(ResetWeather()),
      expect: () => [const WeatherState(status: WeatherStatus.initial)],
    );
  });
}
