import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shorebird_fintech_wallet/core/app_strings.dart';
import 'package:shorebird_fintech_wallet/store/wallet_store/transaction_logic.dart';
import 'package:shorebird_fintech_wallet/store/wallet_store/wallet_store.dart';
import 'package:shorebird_fintech_wallet/presentation/features/transfer/bloc/transfer_event.dart';
import 'package:shorebird_fintech_wallet/presentation/features/transfer/bloc/transfer_state.dart';

@injectable
class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final TransactionLogic _transactionLogic;
  final WalletStore _walletStore;

  TransferBloc(this._transactionLogic, this._walletStore)
    : super(TransferInitial()) {
    on<UpdateTransferValues>(_onUpdateValues);
    on<ConfirmTransfer>(_onConfirmTransfer);
    on<ResetTransfer>(_onReset);
  }

  void _onUpdateValues(
    UpdateTransferValues event,
    Emitter<TransferState> emit,
  ) {
    if (event.amount <= 0) {
      emit(TransferInitial());
      return;
    }

    final fee = _transactionLogic.calculateFee(event.amount, event.isInternal);
    final total = event.amount + fee;

    emit(TransferPreview(amount: event.amount, fee: fee, total: total));
  }

  Future<void> _onConfirmTransfer(
    ConfirmTransfer event,
    Emitter<TransferState> emit,
  ) async {
    emit(TransferLoading());

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final canTransact = _transactionLogic.hasEnoughBalance(
      _walletStore.balance,
      event.amount,
      event.fee,
    );

    if (canTransact) {
      _walletStore.updateBalanceAndTransactions(
        event.amount,
        event.fee,
        event.isInternal,
      );
      emit(TransferSuccess());
    } else {
      emit(const TransferFailure(AppStrings.insufficientBalance));
    }
  }

  void _onReset(ResetTransfer event, Emitter<TransferState> emit) {
    emit(TransferInitial());
  }
}
