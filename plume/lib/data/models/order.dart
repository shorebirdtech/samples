import 'package:equatable/equatable.dart';
import 'package:plume/core/money.dart';
import 'package:plume/data/models/checkout.dart';

enum OrderStatus { placed, packed, shipped, outForDelivery, delivered }

class OrderLine extends Equatable {
  const OrderLine({
    required this.productId,
    required this.name,
    required this.icon,
    required this.colorName,
    required this.colorValue,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderLine.fromJson(Map<String, dynamic> json) => OrderLine(
    productId: json['productId'] as String,
    name: json['name'] as String,
    icon: json['icon'] as String,
    colorName: json['colorName'] as String,
    colorValue: json['colorValue'] as int,
    quantity: json['quantity'] as int,
    unitPrice: Money.cents(json['unitPriceCents'] as int),
  );

  final String productId;
  final String name;
  final String icon;
  final String colorName;
  final int colorValue;
  final int quantity;
  final Money unitPrice;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'icon': icon,
    'colorName': colorName,
    'colorValue': colorValue,
    'quantity': quantity,
    'unitPriceCents': unitPrice.cents,
  };

  @override
  List<Object> get props => [productId, colorName, quantity, unitPrice];
}

class Order extends Equatable {
  const Order({
    required this.id,
    required this.placedAt,
    required this.lines,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.address,
    required this.shippingMethod,
    required this.cardLast4,
    this.promoCode,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    placedAt: DateTime.parse(json['placedAt'] as String),
    lines: (json['lines'] as List<dynamic>)
        .map((e) => OrderLine.fromJson(e as Map<String, dynamic>))
        .toList(),
    subtotal: Money.cents(json['subtotalCents'] as int),
    discount: Money.cents(json['discountCents'] as int),
    shipping: Money.cents(json['shippingCents'] as int),
    tax: Money.cents(json['taxCents'] as int),
    total: Money.cents(json['totalCents'] as int),
    address: Address.fromJson(json['address'] as Map<String, dynamic>),
    shippingMethod: ShippingMethod.values.byName(
      json['shippingMethod'] as String,
    ),
    cardLast4: json['cardLast4'] as String,
    promoCode: json['promoCode'] as String?,
  );

  final String id;
  final DateTime placedAt;
  final List<OrderLine> lines;
  final Money subtotal;
  final Money discount;
  final Money shipping;
  final Money tax;
  final Money total;
  final Address address;
  final ShippingMethod shippingMethod;
  final String cardLast4;
  final String? promoCode;

  int get itemCount => lines.fold(0, (sum, line) => sum + line.quantity);

  DateTime get estimatedDelivery =>
      placedAt.add(Duration(days: shippingMethod.days));

  /// Orders advance through their statuses on a demo clock so the tracking
  /// screen has something to show: one step every 45 seconds.
  OrderStatus statusAt(DateTime now) {
    final steps = now.difference(placedAt).inSeconds ~/ 45;
    final index = steps.clamp(0, OrderStatus.values.length - 1);
    return OrderStatus.values[index];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'placedAt': placedAt.toIso8601String(),
    'lines': lines.map((e) => e.toJson()).toList(),
    'subtotalCents': subtotal.cents,
    'discountCents': discount.cents,
    'shippingCents': shipping.cents,
    'taxCents': tax.cents,
    'totalCents': total.cents,
    'address': address.toJson(),
    'shippingMethod': shippingMethod.name,
    'cardLast4': cardLast4,
    'promoCode': promoCode,
  };

  @override
  List<Object?> get props => [id];
}
