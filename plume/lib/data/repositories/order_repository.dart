import 'dart:math';

import 'package:plume/core/money.dart';
import 'package:plume/core/storage/key_value_store.dart';
import 'package:plume/data/models/models.dart';

enum PaymentError { declined, network }

class PaymentException implements Exception {
  const PaymentException(this.error);

  final PaymentError error;
}

/// Places and stores orders. The payment gateway is simulated: card numbers
/// ending in `0002` are declined, like the test cards real gateways provide.
class OrderRepository {
  OrderRepository(
    this._store, {
    this.latency = const Duration(milliseconds: 1600),
    DateTime Function()? clock,
    Random? random,
  }) : _clock = clock ?? DateTime.now,
       _random = random ?? Random();

  static const _key = 'orders.v1';

  final KeyValueStore _store;
  final Duration latency;
  final DateTime Function() _clock;
  final Random _random;

  Future<List<Order>> load() async {
    final json = await _store.readJson(_key);
    if (json is! List) return const [];
    return json.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
  }

  Future<Order> place({
    required List<OrderLine> lines,
    required Map<String, int> amounts,
    required Address address,
    required ShippingMethod shippingMethod,
    required PaymentCard card,
    String? promoCode,
  }) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    if (card.digits.endsWith('0002')) {
      throw const PaymentException(PaymentError.declined);
    }
    final order = Order(
      id: 'PL-${100000 + _random.nextInt(899999)}',
      placedAt: _clock(),
      lines: lines,
      subtotal: _money(amounts, 'subtotal'),
      discount: _money(amounts, 'discount'),
      shipping: _money(amounts, 'shipping'),
      tax: _money(amounts, 'tax'),
      total: _money(amounts, 'total'),
      address: address,
      shippingMethod: shippingMethod,
      cardLast4: card.last4,
      promoCode: promoCode,
    );
    final existing = await load();
    await _store.writeJson(
      _key,
      [order, ...existing].map((e) => e.toJson()).toList(),
    );
    return order;
  }

  static Money _money(Map<String, int> amounts, String key) =>
      Money.cents(amounts[key] ?? 0);
}
