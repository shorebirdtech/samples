import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shorebird_fintech_wallet/presentation/features/wallet/screens/wallet_screen.dart';
import 'package:shorebird_fintech_wallet/store/wallet_store/wallet_store.dart';
import 'package:intl/intl.dart';

void main() {
  testWidgets('WalletScreen updates UI when store balance changes', (
    WidgetTester tester,
  ) async {
    final store = WalletStore();
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    await tester.pumpWidget(MaterialApp(home: WalletScreen(store: store)));

    // Verify initial balance
    expect(find.text(currencyFormat.format(10000.00)), findsOneWidget);

    // Directly update the store
    store.updateBalanceAndTransactions(500.0, 5.0, false);

    // Pump a frame to let ListenableBuilder react
    await tester.pump();

    // Verify new balance (10000 - 505 = 9495)
    expect(find.text(currencyFormat.format(9495.00)), findsOneWidget);
  });
}
