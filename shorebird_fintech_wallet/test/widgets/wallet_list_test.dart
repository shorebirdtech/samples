import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shorebird_fintech_wallet/core/app_strings.dart';
import 'package:shorebird_fintech_wallet/core/di/injection.dart';
import 'package:shorebird_fintech_wallet/main.dart';
import 'package:shorebird_fintech_wallet/store/wallet_store/wallet_store.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    configureDependencies();
  });

  testWidgets('Wallet screen renders transaction list and handles scrolling', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify Recent Transactions header
    expect(find.text(AppStrings.recentTransactions), findsOneWidget);

    // Verify initial transactions exist
    expect(find.text('Alice Doe'), findsOneWidget);

    // Add MANY transactions
    final store = getIt<WalletStore>();
    for (int i = 0; i < 30; i++) {
      store.updateBalanceAndTransactions(1.0, 0.05, true);
    }

    await tester.pumpAndSettle();

    // Ensure Alice Doe is still reachable
    await tester.scrollUntilVisible(
      find.text('Alice Doe'),
      500.0,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Alice Doe'), findsOneWidget);
  });
}
