import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shorebird_fintech_wallet/domain/entities/transaction_entity.dart';

@lazySingleton
class WalletStore extends ChangeNotifier {
  double _balance = 10000.00; // Starting balance
  List<TransactionEntity> _transactions = [
    TransactionEntity(
      id: '1',
      sender: 'Alice Doe',
      amount: 1200.0,
      fee: 0.0,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isInternal: true,
    ),
    TransactionEntity(
      id: '2',
      sender: 'Tech Gadgets Store',
      amount: 450.0,
      fee: 4.5,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isInternal: false,
    ),
  ];

  double get balance => _balance;
  List<TransactionEntity> get transactions => List.unmodifiable(_transactions);

  void updateBalanceAndTransactions(
    double amount,
    double fee,
    bool isInternal,
  ) {
    final total = amount + fee;
    _balance -= total;
    _transactions = [
      TransactionEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: isInternal ? 'Friend' : 'Merchant',
        amount: amount,
        fee: fee,
        timestamp: DateTime.now(),
        isInternal: isInternal,
      ),
      ..._transactions,
    ];
    notifyListeners();
  }
}
