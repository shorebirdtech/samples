import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shorebird_fintech_wallet/core/app_strings.dart';
import 'package:shorebird_fintech_wallet/presentation/features/transfer/screens/transfer_preview_screen.dart';
import 'package:shorebird_fintech_wallet/presentation/features/transfer/bloc/transfer_bloc.dart';
import 'package:shorebird_fintech_wallet/store/wallet_store/transaction_logic.dart';
import 'package:shorebird_fintech_wallet/store/wallet_store/wallet_store.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  testWidgets(
    'TransferPreviewScreen shows failure snackbar on TransferFailure state',
    (WidgetTester tester) async {
      // Create a bloc that we can control or that will fail
      final bloc = TransferBloc(TransactionLogic(), WalletStore());
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: const TransferPreviewScreen(
              amount: 20000.0, // This will fail because initial balance is 10000
              fee: 200.0,
              total: 20200.0,
              isInternal: false,
            ),
          ),
        ),
      );

      // Tap confirm to trigger failure
      await tester.tap(find.text(AppStrings.confirmTransfer));
      
      // Wait for delayed bloc logic (1 sec)
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(); // SnackBar needs a frame

      // Check for failure message in snackbar
      expect(find.text(AppStrings.insufficientBalance), findsOneWidget);
    },
  );
}
