import 'package:equatable/equatable.dart';
import 'package:plume/core/money.dart';
import 'package:plume/data/models/models.dart';

/// The totals shown in the cart, at checkout and on the receipt.
class OrderSummary extends Equatable {
  const OrderSummary({
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.freeShippingRemaining,
    this.promotion,
    this.promoShortfall,
  });

  static const empty = OrderSummary(
    subtotal: Money.zero,
    discount: Money.zero,
    shipping: Money.zero,
    tax: Money.zero,
    total: Money.zero,
    freeShippingRemaining: Money.zero,
  );

  final Money subtotal;
  final Money discount;
  final Money shipping;
  final Money tax;
  final Money total;

  /// How much more the customer needs to spend for free standard shipping.
  final Money freeShippingRemaining;

  /// The promotion that was applied, if it qualified.
  final Promotion? promotion;

  /// Set when a promotion was entered but the cart is below its minimum.
  final Money? promoShortfall;

  Map<String, int> toAmounts() => {
    'subtotal': subtotal.cents,
    'discount': discount.cents,
    'shipping': shipping.cents,
    'tax': tax.cents,
    'total': total.cents,
  };

  @override
  List<Object?> get props => [
    subtotal,
    discount,
    shipping,
    tax,
    total,
    freeShippingRemaining,
    promotion,
    promoShortfall,
  ];
}

/// Works out an order's totals. Shared by the cart, checkout and receipt so
/// the customer always sees the same numbers.
class PriceCalculator {
  const PriceCalculator();

  static const taxRatePercent = 8;
  static final freeShippingThreshold = Money.fromMajor(75);

  OrderSummary calculate({
    required List<CartItem> items,
    Promotion? promotion,
    ShippingMethod shippingMethod = ShippingMethod.standard,
  }) {
    if (items.isEmpty) return OrderSummary.empty;

    final subtotal = items.fold(
      Money.zero,
      (sum, item) => sum + item.lineTotal,
    );

    var discount = Money.zero;
    var freeShipping = false;
    Promotion? applied;
    Money? shortfall;

    if (promotion != null) {
      final minimum = Money.fromMajor(promotion.minSubtotal);
      if (subtotal < minimum) {
        shortfall = minimum - subtotal;
      } else {
        applied = promotion;
        switch (promotion.kind) {
          // TODO(Demo): Fix during the live patch! SAVE10 takes off $0.10
          // instead of $10: the amount is in dollars, not cents.
          case PromotionKind.fixed:
            discount = Money.cents(promotion.amount.toInt());
          case PromotionKind.percent:
            discount = subtotal.percentage(promotion.amount);
          case PromotionKind.shipping:
            freeShipping = true;
        }
      }
    }
    // A discount can never take the order below zero.
    discount = discount.clamp(Money.zero, subtotal);

    final discounted = subtotal - discount;
    final qualifiesForFreeShipping =
        shippingMethod == ShippingMethod.standard &&
        (freeShipping || discounted >= freeShippingThreshold);
    final shipping = qualifiesForFreeShipping
        ? Money.zero
        : shippingMethod.price;
    final tax = discounted.percentage(taxRatePercent);

    return OrderSummary(
      subtotal: subtotal,
      discount: discount,
      shipping: shipping,
      tax: tax,
      total: discounted + shipping + tax,
      freeShippingRemaining: discounted >= freeShippingThreshold
          ? Money.zero
          : freeShippingThreshold - discounted,
      promotion: applied,
      promoShortfall: shortfall,
    );
  }
}
