import 'package:flutter_test/flutter_test.dart';
import 'package:shorebird_fintech_wallet/store/wallet_store/wallet_store.dart';

void main() {
  group(
    'WalletStore Tests',
    () {
      late WalletStore store;

      setUp(() {
        store = WalletStore();
      });

      test(
        'initial balance should be 10000.00',
        () {
          expect(store.balance, 10000.00);
        },
      );

      test(
        'initial transactions should not be empty',
        () {
          expect(store.transactions.isNotEmpty, isTrue);
          expect(store.transactions.length, 2);
        },
      );

      test(
        'updating balance and transactions adds a new record and decreases balance',
        () {
          final initialBalance = store.balance;
          const amount = 100.0;
          const fee = 5.0;
          
          store.updateBalanceAndTransactions(amount, fee, true);
          
          expect(store.balance, initialBalance - (amount + fee));
          expect(store.transactions.length, 3);
          expect(store.transactions.first.amount, amount);
          expect(store.transactions.first.fee, fee);
        },
      );

      test(
        'notifies listeners when balance is updated',
        () {
          int count = 0;
          store.addListener(() => count++);
          
          store.updateBalanceAndTransactions(10.0, 1.0, true);
          
          expect(count, 1);
        },
      );
    },
  );
}
