import 'package:flutter_test/flutter_test.dart';
import 'package:shorebird_fintech_wallet/presentation/features/transfer/bloc/transfer_bloc.dart';
import 'package:shorebird_fintech_wallet/presentation/features/transfer/bloc/transfer_event.dart';
import 'package:shorebird_fintech_wallet/presentation/features/transfer/bloc/transfer_state.dart';
import 'package:shorebird_fintech_wallet/store/wallet_store/transaction_logic.dart';
import 'package:shorebird_fintech_wallet/store/wallet_store/wallet_store.dart';

void main() {
  group('TransferBloc Tests', () {
    late TransferBloc bloc;
    late TransactionLogic transactionLogic;
    late WalletStore walletStore;

    setUp(() {
      transactionLogic = TransactionLogic();
      walletStore = WalletStore();
      bloc = TransferBloc(transactionLogic, walletStore);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is TransferInitial', () {
      expect(bloc.state, isA<TransferInitial>());
    });

    test('UpdateTransferValues emits TransferPreview', () async {
      final future = expectLater(bloc.stream, emits(isA<TransferPreview>()));
      bloc.add(const UpdateTransferValues(amount: 100.0, isInternal: true));
      await future;
    });

    test(
      'ConfirmTransfer emits Loading and Success when balance is enough',
      () async {
        final future = expectLater(
          bloc.stream,
          emitsInOrder([isA<TransferLoading>(), isA<TransferSuccess>()]),
        );
        bloc.add(
          const ConfirmTransfer(amount: 100.0, fee: 5.0, isInternal: true),
        );
        await future;
        expect(walletStore.balance, 10000.00 - 105.0);
      },
    );

    test(
      'ConfirmTransfer emits Failure when balance is insufficient',
      () async {
        final future = expectLater(
          bloc.stream,
          emitsInOrder([isA<TransferLoading>(), isA<TransferFailure>()]),
        );
        bloc.add(
          const ConfirmTransfer(amount: 20000.0, fee: 200.0, isInternal: false),
        );
        await future;
      },
    );

    test('ResetTransfer emits TransferInitial', () async {
      bloc.add(const UpdateTransferValues(amount: 100.0, isInternal: true));
      await expectLater(bloc.stream, emits(isA<TransferPreview>()));

      final resetFuture = expectLater(
        bloc.stream,
        emits(isA<TransferInitial>()),
      );
      bloc.add(const ResetTransfer());
      await resetFuture;
      expect(bloc.state, isA<TransferInitial>());
    });

    test(
      'UpdateTransferValues with zero amount emits TransferInitial from Preview',
      () async {
        bloc.add(const UpdateTransferValues(amount: 100.0, isInternal: true));
        await expectLater(bloc.stream, emits(isA<TransferPreview>()));

        final future = expectLater(bloc.stream, emits(isA<TransferInitial>()));
        bloc.add(const UpdateTransferValues(amount: 0.0, isInternal: true));
        await future;
        expect(bloc.state, isA<TransferInitial>());
      },
    );

    test(
      'UpdateTransferValues with negative amount emits TransferInitial from Preview',
      () async {
        bloc.add(const UpdateTransferValues(amount: 100.0, isInternal: true));
        await expectLater(bloc.stream, emits(isA<TransferPreview>()));

        final future = expectLater(bloc.stream, emits(isA<TransferInitial>()));
        bloc.add(const UpdateTransferValues(amount: -50.0, isInternal: true));
        await future;
        expect(bloc.state, isA<TransferInitial>());
      },
    );
  });
}
