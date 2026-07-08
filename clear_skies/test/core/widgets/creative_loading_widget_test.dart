import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clear_skies/core/core.dart';

void main() {
  group('CreativeLoadingWidget', () {
    testWidgets('renders correctly and disposes without error', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CreativeLoadingWidget(
              textColor: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.byType(CreativeLoadingWidget), findsOneWidget);
      expect(find.text('☁️'), findsOneWidget);
      expect(find.text(AppStrings.loadingMessage), findsOneWidget);
      
      // Let animation run
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
