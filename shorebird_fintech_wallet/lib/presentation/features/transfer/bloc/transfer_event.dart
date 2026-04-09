import 'package:equatable/equatable.dart';

abstract class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object?> get props => [];
}

class UpdateTransferValues extends TransferEvent {
  final double amount;
  final bool isInternal;

  const UpdateTransferValues({required this.amount, required this.isInternal});

  @override
  List<Object?> get props => [amount, isInternal];
}

class ConfirmTransfer extends TransferEvent {
  final double amount;
  final double fee;
  final bool isInternal;

  const ConfirmTransfer({
    required this.amount,
    required this.fee,
    required this.isInternal,
  });

  @override
  List<Object?> get props => [amount, fee, isInternal];
}

class ResetTransfer extends TransferEvent {}
