import 'package:injectable/injectable.dart';

@lazySingleton
class TransactionLogic {
  /// Calculates the service fee for a transaction.
  ///
  /// CRITICAL BUSINESS RULE (Expected):
  /// - Internal transfers (between friends) should be free ($0$ fee).
  /// - Standard transfers should be $1\%$ of the amount.
  ///
  /// BROKEN LOGIC (For Shorebird Demo):
  /// - Accidentally applies a flat $5\%$ fee to ALL transactions,
  ///   completely ignoring the `isInternal` flag.
  double calculateFee(double amount, bool isInternal) {
    // BUGGY CODE: Applying flat 5% fee to everyone.
    // This is the target for the Shorebird hotfix.
    return amount * 0.05;

    /* 
    EXPECTED LOGIC:
    if (isInternal) {
      return 0.0;
    } else {
      return amount * 0.01;
    }
    */
  }

  /// Validates if the user has enough balance.
  bool hasEnoughBalance(double currentBalance, double amount, double fee) {
    return currentBalance >= (amount + fee);
  }
}
