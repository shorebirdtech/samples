import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:clear_skies/features/features.dart';
import 'package:clear_skies/core/core.dart';

class MockWeatherBloc extends MockBloc<WeatherEvent, WeatherState> implements WeatherBloc {}
class MockFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState> implements FavoritesBloc {}
class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  group('WeatherScreen', () {
    late MockWeatherBloc mockWeatherBloc;
    late MockFavoritesBloc mockFavoritesBloc;
    late MockWeatherRepository mockWeatherRepository;

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
      mockWeatherBloc = MockWeatherBloc();
      mockFavoritesBloc = MockFavoritesBloc();
      mockWeatherRepository = MockWeatherRepository();

      when(() => mockWeatherBloc.state).thenReturn(const WeatherState());
      when(() => mockFavoritesBloc.state).thenReturn(const FavoritesState());
    });

    Widget createWidgetUnderTest() {
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<WeatherRepository>.value(value: mockWeatherRepository),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<WeatherBloc>.value(value: mockWeatherBloc),
            BlocProvider<FavoritesBloc>.value(value: mockFavoritesBloc),
          ],
          child: const MaterialApp(
            home: WeatherScreen(),
          ),
        ),
      );
    }

    testWidgets('renders favorites when initial and favorites exist', (WidgetTester tester) async {
      when(() => mockFavoritesBloc.state).thenReturn(FavoritesState(
        status: FavoritesStatus.loaded,
        favorites: [mockWeather],
      ));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(SearchBarWidget), findsOneWidget);
      
      // Should display favorites list
      expect(find.text('London'), findsOneWidget);
    });

    testWidgets('renders CreativeLoadingWidget when weather is loading', (WidgetTester tester) async {
      when(() => mockWeatherBloc.state).thenReturn(const WeatherState(status: WeatherStatus.loading));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CreativeLoadingWidget), findsOneWidget);
    });

    testWidgets('renders WeatherDisplay when weather is loaded', (WidgetTester tester) async {
      when(() => mockWeatherBloc.state).thenReturn(WeatherState(
        status: WeatherStatus.loaded,
        weather: mockWeather,
      ));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(WeatherDisplay), findsOneWidget);
      expect(find.byType(SearchBarWidget), findsOneWidget);
    });

    testWidgets('shows error widget when weather emits error', (WidgetTester tester) async {
      whenListen(
        mockWeatherBloc,
        Stream.fromIterable([
          const WeatherState(status: WeatherStatus.loading),
          const WeatherState(status: WeatherStatus.error, errorMessage: 'Network Error'),
        ]),
        initialState: const WeatherState(status: WeatherStatus.initial),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Pump the error state

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.text('Network Error'), findsOneWidget);
    });

    testWidgets('tapping a favorite city triggers WeatherRequested', (WidgetTester tester) async {
      when(() => mockFavoritesBloc.state).thenReturn(FavoritesState(
        status: FavoritesStatus.loaded,
        favorites: [mockWeather],
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      
      // Tap on the favorite list tile
      await tester.tap(find.text('London'));
      await tester.pump();

      verify(() => mockWeatherBloc.add(const WeatherRequested('London'))).called(1);
    });

    testWidgets('shows loading for favorites if favorites are loading', (WidgetTester tester) async {
      when(() => mockFavoritesBloc.state).thenReturn(const FavoritesState(status: FavoritesStatus.loading));
      
      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
