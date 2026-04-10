import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shorebird_fintech_wallet/core/app_strings.dart';
import 'package:shorebird_fintech_wallet/core/di/injection.dart';
import 'package:shorebird_fintech_wallet/presentation/features/transfer/screens/transfer_screen.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    configureDependencies();
  });

  testWidgets('Transfer screen shows input field and internal toggle', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TransferScreen()));

    // Check for Amount label
    expect(find.text(AppStrings.amount), findsOneWidget);

    // Check for TextField with hint 0.00
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('0.00'), findsOneWidget);

    // Check for Internal Transfer toggle
    expect(find.text(AppStrings.internalTransfer), findsOneWidget);
    expect(find.text(AppStrings.internalTransferSubtitle), findsOneWidget);

    // Check for Preview button
    expect(find.text(AppStrings.preview), findsOneWidget);
  });

  testWidgets(
    'Entering amount and tapping preview navigates (mocking bloc if possible)',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TransferScreen()));

      // Enter amount
      await tester.enterText(find.byType(TextField), '100.0');
      await tester.pump();

      // Tap preview
      await tester.tap(find.text(AppStrings.preview));
      await tester.pumpAndSettle();

      // Should show Preview Transfer screen title
      expect(find.text(AppStrings.preview), findsOneWidget);
    },
  );
}
