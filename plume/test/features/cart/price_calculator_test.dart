import 'package:flutter_test/flutter_test.dart';
import 'package:plume/core/money.dart';
import 'package:plume/data/models/models.dart';
import 'package:plume/features/cart/domain/price_calculator.dart';

import '../../helpers/fixtures.dart';

void main() {
  const calculator = PriceCalculator();

  group('PriceCalculator', () {
    test('empty cart is all zeros', () {
      expect(calculator.calculate(items: const []), OrderSummary.empty);
    });

    test('charges standard shipping below the free shipping threshold', () {
      final summary = calculator.calculate(
        items: [item(product(priceCents: 2000), quantity: 2)],
      );
      expect(summary.subtotal, const Money.cents(4000));
      expect(summary.shipping, ShippingMethod.standard.price);
      expect(summary.tax, const Money.cents(320));
      expect(summary.total, const Money.cents(4000 + 599 + 320));
      expect(summary.freeShippingRemaining, const Money.cents(3500));
    });

    test(r'standard shipping is free at or above $75', () {
      final summary = calculator.calculate(
        items: [item(product(priceCents: 7500))],
      );
      expect(summary.shipping, Money.zero);
      expect(summary.freeShippingRemaining, Money.zero);
    });

    test('express shipping is always charged', () {
      final summary = calculator.calculate(
        items: [item(product(priceCents: 20000))],
        shippingMethod: ShippingMethod.express,
      );
      expect(summary.shipping, ShippingMethod.express.price);
    });

    test('percentage promotions discount the subtotal', () {
      final summary = calculator.calculate(
        items: [item(product(priceCents: 10000))],
        promotion: welcome15,
      );
      expect(summary.discount, const Money.cents(1500));
      expect(summary.tax, const Money.cents(680));
      expect(summary.promotion, welcome15);
    });

    test('shipping promotions make standard shipping free', () {
      final summary = calculator.calculate(
        items: [item(product(priceCents: 1000))],
        promotion: freeShip,
      );
      expect(summary.shipping, Money.zero);
      expect(summary.discount, Money.zero);
    });

    test('promotions below their minimum report the shortfall', () {
      final summary = calculator.calculate(
        items: [item(product(priceCents: 3000))],
        promotion: save10,
      );
      expect(summary.promotion, isNull);
      expect(summary.discount, Money.zero);
      expect(summary.promoShortfall, const Money.cents(2000));
    });

    test(
      'fixed promotions take their amount in dollars',
      () {
        final summary = calculator.calculate(
          items: [item(product(priceCents: 12900))],
          promotion: save10,
        );
        expect(summary.discount, const Money.cents(1000));
        expect(summary.total, const Money.cents(11900 + 952));
      },
      // TODO(Demo): Remove this skip during the live patch! Release 1.0.0
      // deliberately ships with this bug; DEMO.md has the fix.
      skip: 'Known bug in release 1.0.0, fixed by the demo patch (DEMO.md)',
    );

    test('a discount never takes the order below zero', () {
      final summary = calculator.calculate(
        items: [item(product(priceCents: 1000))],
        promotion: const Promotion(
          code: 'HUGE',
          kind: PromotionKind.percent,
          amount: 150,
          minSubtotal: 0,
          description: '',
        ),
      );
      expect(summary.discount, const Money.cents(1000));
      expect(summary.tax, Money.zero);
    });
  });
}
