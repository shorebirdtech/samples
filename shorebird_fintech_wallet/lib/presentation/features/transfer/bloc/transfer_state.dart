import 'package:equatable/equatable.dart';

abstract class TransferState extends Equatable {
  const TransferState();

  @override
  List<Object?> get props => [];
}

class TransferInitial extends TransferState {}

class TransferLoading extends TransferState {}

class TransferSuccess extends TransferState {}

class TransferFailure extends TransferState {
  final String errorMessage;

  const TransferFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class TransferPreview extends TransferState {
  final double amount;
  final double fee;
  final double total;

  const TransferPreview({
    required this.amount,
    required this.fee,
    required this.total,
  });

  @override
  List<Object?> get props => [amount, fee, total];
}
