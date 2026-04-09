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

  testWidgets(
    'TransferScreen validation: tapping preview with invalid amount should not navigate',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TransferScreen()));
      await tester.pumpAndSettle();

      // Try with empty text
      await tester.tap(find.text(AppStrings.preview));
      await tester.pumpAndSettle();
      // Still on TransferScreen (AppBar title matches)
      expect(find.text(AppStrings.transfer), findsOneWidget);

      // Try with non-numeric text
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.tap(find.text(AppStrings.preview));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.transfer), findsOneWidget);

      // Try with zero
      await tester.enterText(find.byType(TextField), '0.0');
      await tester.tap(find.text(AppStrings.preview));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.transfer), findsOneWidget);

      // Try with negative
      await tester.enterText(find.byType(TextField), '-10.0');
      await tester.tap(find.text(AppStrings.preview));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.transfer), findsOneWidget);
    },
  );
}
