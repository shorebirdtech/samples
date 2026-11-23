import 'package:flutter_test/flutter_test.dart';
import 'package:plume/core/money.dart';

void main() {
  group('Money', () {
    test('fromMajor converts dollars to cents without float drift', () {
      expect(Money.fromMajor(19.99).cents, 1999);
      expect(Money.fromMajor(0.1 + 0.2).cents, 30);
    });

    test('arithmetic and comparison', () {
      const a = Money.cents(1000);
      const b = Money.cents(250);
      expect(a + b, const Money.cents(1250));
      expect(a - b, const Money.cents(750));
      expect(b * 3, const Money.cents(750));
      expect(a > b, isTrue);
      expect(b < a, isTrue);
      expect(a.compareTo(b), greaterThan(0));
    });

    test('percentage rounds to the nearest cent', () {
      expect(const Money.cents(999).percentage(15).cents, 150);
      expect(const Money.cents(1000).percentage(8).cents, 80);
    });

    test('clamp keeps the amount within bounds', () {
      expect(
        const Money.cents(-5).clamp(Money.zero, const Money.cents(10)),
        Money.zero,
      );
    });

    test('formats as US dollars', () {
      expect(const Money.cents(12900).format('en_US'), r'$129.00');
    });
  });
}
