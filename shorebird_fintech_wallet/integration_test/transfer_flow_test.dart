import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shorebird_fintech_wallet/core/app_strings.dart';
import 'package:shorebird_fintech_wallet/core/di/injection.dart';
import 'package:shorebird_fintech_wallet/main.dart' as app;
import 'package:shorebird_fintech_wallet/store/wallet_store/wallet_store.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await getIt.reset();
    configureDependencies();
  });

  testWidgets(
      'End-to-end integration flow: Transfer from WalletScreen to Success', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    final store = getIt<WalletStore>();
    final initialBalance = store.balance;

    // 1. On Wallet Screen, tap Transfer
    expect(find.text(AppStrings.walletBalance), findsOneWidget);
    await tester.tap(find.text(AppStrings.transfer));
    await tester.pumpAndSettle();

    // 2. On Transfer Screen, enter amount
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), '200');
    await tester.pump();

    // 3. Tap Preview
    await tester.tap(find.text(AppStrings.preview));
    await tester.pumpAndSettle();

    // 4. On Preview Screen, verify summary
    expect(find.text('\$200.00'), findsOneWidget);
    // Fee is 5% in buggy implementation, so $10.00
    expect(find.text('\$10.00'), findsOneWidget);
    expect(find.text('\$210.00'), findsOneWidget);

    // 5. Tap Confirm
    await tester.tap(find.text(AppStrings.confirmTransfer));

    // We expect loading state
    await tester.pump(const Duration(milliseconds: 500));
    // Then animation finishes after 1 sec delay in bloc
    await tester.pumpAndSettle();

    // 6. Verify back on Wallet Screen and balance updated
    expect(find.text(AppStrings.walletBalance), findsOneWidget);

    final expectedBalance = initialBalance - 210.0;
    expect(store.balance, expectedBalance);

    // Verify Snackbar or success indicator
    expect(find.text(AppStrings.transactionSuccess), findsOneWidget);
  });
}
