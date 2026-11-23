import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plume/core/logging/analytics.dart';
import 'package:plume/data/models/models.dart';
import 'package:plume/data/repositories/order_repository.dart';
import 'package:plume/features/cart/domain/price_calculator.dart';

enum PlaceOrderStatus { idle, placing, failed }

class OrdersState extends Equatable {
  const OrdersState({
    this.orders = const [],
    this.placeStatus = PlaceOrderStatus.idle,
    this.paymentError,
  });

  final List<Order> orders;
  final PlaceOrderStatus placeStatus;
  final PaymentError? paymentError;

  Order? byId(String id) {
    for (final order in orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  OrdersState copyWith({
    List<Order>? orders,
    PlaceOrderStatus? placeStatus,
    PaymentError? Function()? paymentError,
  }) => OrdersState(
    orders: orders ?? this.orders,
    placeStatus: placeStatus ?? this.placeStatus,
    paymentError: paymentError != null ? paymentError() : this.paymentError,
  );

  @override
  List<Object?> get props => [orders, placeStatus, paymentError];
}

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repository, this._analytics) : super(const OrdersState());

  final OrderRepository _repository;
  final Analytics _analytics;

  Future<void> load() async =>
      emit(state.copyWith(orders: await _repository.load()));

  /// Places the order and returns it, or `null` if payment failed.
  Future<Order?> place({
    required List<CartItem> items,
    required OrderSummary summary,
    required Address address,
    required ShippingMethod shippingMethod,
    required PaymentCard card,
  }) async {
    emit(
      state.copyWith(
        placeStatus: PlaceOrderStatus.placing,
        paymentError: () => null,
      ),
    );
    try {
      final order = await _repository.place(
        lines: [
          for (final item in items)
            OrderLine(
              productId: item.product.id,
              name: item.product.name,
              icon: item.product.icon,
              colorName: item.colorName,
              colorValue: item.color.color.toARGB32(),
              quantity: item.quantity,
              unitPrice: item.product.price,
            ),
        ],
        amounts: summary.toAmounts(),
        address: address,
        shippingMethod: shippingMethod,
        card: card,
        promoCode: summary.promotion?.code,
      );
      _analytics.event('purchase', {
        'order': order.id,
        'total_cents': order.total.cents,
        'promo': order.promoCode,
      });
      emit(
        state.copyWith(
          orders: [order, ...state.orders],
          placeStatus: PlaceOrderStatus.idle,
        ),
      );
      return order;
    } on PaymentException catch (e) {
      emit(
        state.copyWith(
          placeStatus: PlaceOrderStatus.failed,
          paymentError: () => e.error,
        ),
      );
      return null;
    }
  }
}
