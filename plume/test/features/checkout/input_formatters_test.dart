import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plume/data/models/checkout.dart';
import 'package:plume/features/checkout/widgets/input_formatters.dart';

TextEditingValue _format(TextInputFormatter formatter, String text) => formatter
    .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text));

void main() {
  test('card numbers are grouped and capped at 16 digits', () {
    expect(
      _format(CardNumberFormatter(), '42424242424242424242').text,
      '4242 4242 4242 4242',
    );
    expect(_format(CardNumberFormatter(), '42a4-2').text, '4242');
  });

  test('expiry is formatted as MM/YY', () {
    expect(_format(ExpiryFormatter(), '1229').text, '12/29');
    expect(_format(ExpiryFormatter(), '1').text, '1');
  });

  test('Luhn accepts real test cards and rejects typos', () {
    expect(passesLuhn('4242424242424242'), isTrue);
    expect(passesLuhn('4000000000000002'), isTrue);
    expect(passesLuhn('4242424242424241'), isFalse);
    expect(passesLuhn('42'), isFalse);
  });

  test('expiry must be a real month in the future', () {
    final now = DateTime(2026, 11, 20);
    expect(isValidExpiry('11/26', now), isTrue);
    expect(isValidExpiry('10/26', now), isFalse);
    expect(isValidExpiry('13/30', now), isFalse);
    expect(isValidExpiry('1230', now), isFalse);
  });

  test('card brands are detected from the leading digits', () {
    expect(CardBrand.detect('4242'), CardBrand.visa);
    expect(CardBrand.detect('5555'), CardBrand.mastercard);
    expect(CardBrand.detect('2221'), CardBrand.mastercard);
    expect(CardBrand.detect('3782'), CardBrand.amex);
    expect(CardBrand.detect('6011'), CardBrand.unknown);
  });
}
