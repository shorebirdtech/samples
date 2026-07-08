import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clear_skies/features/features.dart';

void main() {
  group('ForecastListWidget', () {
    testWidgets('renders correct number of forecast items', (WidgetTester tester) async {
      final forecastList = [
        DailyForecast(date: DateTime.parse('2023-10-25'), maxTemp: 22.0, minTemp: 15.0, weatherCode: 1),
        DailyForecast(date: DateTime.parse('2023-10-26'), maxTemp: 20.0, minTemp: 14.0, weatherCode: 2),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ForecastListWidget(
              forecast: forecastList,
              textColor: Colors.black,
            ),
          ),
        ),
      );

      // Verify two items are rendered
      expect(find.text('22°'), findsOneWidget); // 22.0.round()
      expect(find.text('15°'), findsOneWidget);
      expect(find.text('20°'), findsOneWidget);
      expect(find.text('14°'), findsOneWidget);
    });

    testWidgets('renders empty gracefully if no forecast', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ForecastListWidget(
              forecast: [],
              textColor: Colors.black,
            ),
          ),
        ),
      );

      // Nothing rendered
      expect(find.byType(ListView), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
