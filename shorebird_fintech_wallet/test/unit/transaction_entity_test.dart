import 'package:flutter_test/flutter_test.dart';
import 'package:shorebird_fintech_wallet/domain/entities/transaction_entity.dart';

void main() {
  group('TransactionEntity Tests', () {
    final now = DateTime.now();

    test('TransactionEntity equality works', () {
      final t1 = TransactionEntity(
        id: '1',
        sender: 'Alice',
        amount: 100.0,
        fee: 1.0,
        timestamp: now,
        isInternal: true,
      );

      final t2 = TransactionEntity(
        id: '1',
        sender: 'Alice',
        amount: 100.0,
        fee: 1.0,
        timestamp: now,
        isInternal: true,
      );

      expect(t1, equals(t2));
    });

    test('TransactionEntity inequality works', () {
      final t1 = TransactionEntity(
        id: '1',
        sender: 'Alice',
        amount: 100.0,
        fee: 1.0,
        timestamp: now,
      );

      final t2 = TransactionEntity(
        id: '2',
        sender: 'Bob',
        amount: 200.0,
        fee: 2.0,
        timestamp: now,
      );

      expect(t1, isNot(equals(t2)));
    });
  });
}
