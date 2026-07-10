import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clear_skies/main.dart';
import 'package:clear_skies/core/core.dart';
import 'package:clear_skies/features/features.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  testWidgets(AppStrings.smokeTestName, (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    final mockWeatherRepo = MockWeatherRepository();
    final mockFavRepo = MockFavoritesRepository();

    when(() => mockFavRepo.getFavorites()).thenAnswer((_) async => []);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ClearSkiesApp(
        weatherRepository: mockWeatherRepo,
        favoritesRepository: mockFavRepo,
      ),
    );

    await tester.pump(const Duration(seconds: 1));

    // Verify that the initial search state is displayed.
    expect(find.text(AppStrings.welcomeTitle), findsOneWidget);
  });

  testWidgets(
    'ClearSkiesApp initializes with default repositories when none are provided',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      // Build our app without injecting mocked repositories
      await tester.pumpWidget(const ClearSkiesApp());

      await tester.pump(const Duration(seconds: 1));

      // Verify it still renders correctly up to the search prompt
      expect(find.text(AppStrings.welcomeTitle), findsOneWidget);
    },
  );
}
