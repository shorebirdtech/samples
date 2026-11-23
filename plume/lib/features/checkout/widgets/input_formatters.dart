import 'package:flutter/services.dart';

/// Groups card digits as `4242 4242 4242 4242`.
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < clipped.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(clipped[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Formats expiry dates as `MM/YY`.
class ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 4 ? digits.substring(0, 4) : digits;
    final text = clipped.length > 2
        ? '${clipped.substring(0, 2)}/${clipped.substring(2)}'
        : clipped;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Luhn checksum, the same check payment forms use to catch typos.
bool passesLuhn(String digits) {
  if (digits.length < 12) return false;
  var sum = 0;
  var alternate = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    var n = int.parse(digits[i]);
    if (alternate) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    alternate = !alternate;
  }
  return sum % 10 == 0;
}

/// Whether `MM/YY` is a real month that hasn't passed yet.
bool isValidExpiry(String value, DateTime now) {
  final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(value);
  if (match == null) return false;
  final month = int.parse(match.group(1)!);
  final year = 2000 + int.parse(match.group(2)!);
  if (month < 1 || month > 12) return false;
  final endOfMonth = DateTime(year, month + 1);
  return endOfMonth.isAfter(now);
}
