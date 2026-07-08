import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:clear_skies/features/features.dart';

class MockFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState> implements FavoritesBloc {}
class FakeFavoritesEvent extends Fake implements FavoritesEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeFavoritesEvent());
  });

  group('WeatherDisplay', () {
    late MockFavoritesBloc mockFavoritesBloc;

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
      mockFavoritesBloc = MockFavoritesBloc();
    });

    Widget createWidgetUnderTest() {
      return BlocProvider<FavoritesBloc>.value(
        value: mockFavoritesBloc,
        child: MaterialApp(
          home: Scaffold(
            body: WeatherDisplay(
              weather: mockWeather,
            ),
          ),
        ),
      );
    }

    testWidgets('renders weather information correctly', (WidgetTester tester) async {
      when(() => mockFavoritesBloc.state).thenReturn(const FavoritesState());

      await tester.pumpWidget(createWidgetUnderTest());

      // Find city name
      expect(find.text('London'), findsOneWidget);
      
      // Find temperature (15.0 rounded -> 15°)
      expect(find.text('15°'), findsWidgets); // Can be found multiple times depending on UI structure, but we at least expect it

      // Find humidity
      expect(find.text('50%'), findsOneWidget);

      // Find wind speed
      expect(find.text('10 km/h'), findsOneWidget);
      
      // Find favorite icon
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
    });

    testWidgets('favorite icon is filled when city is in favorites', (WidgetTester tester) async {
      when(() => mockFavoritesBloc.state).thenReturn(FavoritesState(
        status: FavoritesStatus.loaded,
        favorites: [mockWeather],
      ));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });

    testWidgets('tapping favorite icon dispatches RemoveFavorite if already favorited', (WidgetTester tester) async {
      when(() => mockFavoritesBloc.state).thenReturn(FavoritesState(
        status: FavoritesStatus.loaded,
        favorites: [mockWeather],
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byIcon(Icons.favorite_rounded));

      verify(() => mockFavoritesBloc.add(const RemoveFavorite('London'))).called(1);
    });

    testWidgets('tapping favorite icon dispatches AddFavorite if not favorited', (WidgetTester tester) async {
      when(() => mockFavoritesBloc.state).thenReturn(const FavoritesState());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byIcon(Icons.favorite_border_rounded));

      verify(() => mockFavoritesBloc.add(AddFavorite(mockWeather))).called(1);
    });
  });
}
