import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String sender;
  final double amount;
  final double fee;
  final DateTime timestamp;
  final bool isInternal;

  const TransactionEntity({
    required this.id,
    required this.sender,
    required this.amount,
    required this.fee,
    required this.timestamp,
    this.isInternal = false,
  });

  @override
  List<Object?> get props => [id, sender, amount, fee, timestamp, isInternal];
}
