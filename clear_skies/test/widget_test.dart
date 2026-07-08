import 'package:flutter_test/flutter_test.dart';
import 'package:clear_skies/main.dart';
import 'package:clear_skies/core/core.dart';

void main() {
  testWidgets(AppStrings.smokeTestName, (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ClearSkiesApp());

    // Verify that the initial search state is displayed.
    expect(find.text(AppStrings.initialSearchPrompt), findsOneWidget);
  });
}
