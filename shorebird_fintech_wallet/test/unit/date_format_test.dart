import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  group('Date Formatting Tests', () {
    test('Verify transaction date format MMM dd, hh:mm a', () {
      final date = DateTime(2023, 10, 25, 14, 30); // Oct 25, 02:30 PM
      final formatted = DateFormat('MMM dd, hh:mm a').format(date);

      expect(formatted, 'Oct 25, 02:30 PM');
    });

    test('Verify morning time format', () {
      final date = DateTime(2023, 1, 1, 9, 5); // Jan 01, 09:05 AM
      final formatted = DateFormat('MMM dd, hh:mm a').format(date);

      expect(formatted, 'Jan 01, 09:05 AM');
    });
  });
}
