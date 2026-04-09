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
    'TransferPreviewScreen displays correct amounts and badge',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => TransferBloc(TransactionLogic(), WalletStore()),
            child: const TransferPreviewScreen(
              amount: 100.0,
              fee: 5.0,
              total: 105.0,
              isInternal: true,
            ),
          ),
        ),
      );

      // Check amounts
      expect(find.text('\$100.00'), findsOneWidget);
      expect(find.text('\$5.00'), findsOneWidget);
      expect(find.text('\$105.00'), findsOneWidget);

      // Check internal transfer badge
      expect(find.text(AppStrings.internalTransfer), findsOneWidget);

      // Check confirm button
      expect(find.text(AppStrings.confirmTransfer), findsOneWidget);
    },
  );
}
