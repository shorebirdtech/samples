import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:clear_skies/features/features.dart';

class MockWeatherBloc extends MockBloc<WeatherEvent, WeatherState> implements WeatherBloc {}
class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  group('SearchBarWidget', () {
    late MockWeatherBloc mockWeatherBloc;
    late MockWeatherRepository mockWeatherRepository;

    setUp(() {
      mockWeatherBloc = MockWeatherBloc();
      mockWeatherRepository = MockWeatherRepository();
    });

    Widget createWidgetUnderTest({bool isDay = true}) {
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<WeatherRepository>.value(value: mockWeatherRepository),
        ],
        child: BlocProvider<WeatherBloc>.value(
          value: mockWeatherBloc,
          child: MaterialApp(
            home: Scaffold(
              body: SearchBarWidget(isDay: isDay),
            ),
          ),
        ),
      );
    }

    testWidgets('renders TextField and no back button initially', (WidgetTester tester) async {
      when(() => mockWeatherBloc.state).thenReturn(const WeatherState(status: WeatherStatus.initial));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
    });

    testWidgets('renders back button when status is loaded', (WidgetTester tester) async {
      when(() => mockWeatherBloc.state).thenReturn(const WeatherState(status: WeatherStatus.loaded));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('submitting text adds WeatherRequested event', (WidgetTester tester) async {
      when(() => mockWeatherBloc.state).thenReturn(const WeatherState(status: WeatherStatus.initial));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField), 'London');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      verify(() => mockWeatherBloc.add(const WeatherRequested('London'))).called(1);
    });

    testWidgets('typing shows autocomplete suggestions and tapping one adds WeatherLocationRequested event', (WidgetTester tester) async {
      when(() => mockWeatherBloc.state).thenReturn(const WeatherState(status: WeatherStatus.initial));

      final suggestion = CitySuggestion(
        name: 'Paris',
        admin1: 'Ile-de-France',
        country: 'France',
        latitude: 48.85,
        longitude: 2.35,
      );

      when(() => mockWeatherRepository.searchCities('Par'))
          .thenAnswer((_) async => [suggestion]);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField), 'Par');
      await tester.pumpAndSettle(); // Wait for autocomplete to process and fetch

      expect(find.text('Paris, Ile-de-France, France'), findsOneWidget);

      await tester.tap(find.text('Paris, Ile-de-France, France'));
      await tester.pumpAndSettle();

      verify(() => mockWeatherBloc.add(
        const WeatherLocationRequested(
          latitude: 48.85,
          longitude: 2.35,
          cityName: 'Paris',
        ),
      )).called(1);
    });

    testWidgets('clicking back button clears text and adds ResetWeather event', (WidgetTester tester) async {
      when(() => mockWeatherBloc.state).thenReturn(const WeatherState(status: WeatherStatus.loaded));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField), 'some text');
      
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      verify(() => mockWeatherBloc.add(ResetWeather())).called(1);
      
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });
  });
}
