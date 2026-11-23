import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plume/core/logging/analytics.dart';
import 'package:plume/data/models/models.dart';
import 'package:plume/data/repositories/repositories.dart';
import 'package:plume/features/cart/domain/price_calculator.dart';

enum CartStatus { loading, ready }

enum PromoStatus { idle, applying, failed }

class CartState extends Equatable {
  const CartState({
    this.status = CartStatus.loading,
    this.items = const [],
    this.promotion,
    this.promoStatus = PromoStatus.idle,
    this.promoError,
    this.lastAddedAt,
  });

  final CartStatus status;
  final List<CartItem> items;
  final Promotion? promotion;
  final PromoStatus promoStatus;
  final PromoError? promoError;

  /// Changes every time something is added, so the cart badge can bounce.
  final DateTime? lastAddedAt;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;

  OrderSummary get summary =>
      const PriceCalculator().calculate(items: items, promotion: promotion);

  CartState copyWith({
    CartStatus? status,
    List<CartItem>? items,
    Promotion? Function()? promotion,
    PromoStatus? promoStatus,
    PromoError? Function()? promoError,
    DateTime? lastAddedAt,
  }) => CartState(
    status: status ?? this.status,
    items: items ?? this.items,
    promotion: promotion != null ? promotion() : this.promotion,
    promoStatus: promoStatus ?? this.promoStatus,
    promoError: promoError != null ? promoError() : this.promoError,
    lastAddedAt: lastAddedAt ?? this.lastAddedAt,
  );

  @override
  List<Object?> get props => [
    status,
    items,
    promotion,
    promoStatus,
    promoError,
    lastAddedAt,
  ];
}

class CartCubit extends Cubit<CartState> {
  CartCubit({
    required this._cartRepository,
    required this._promotionRepository,
    required this._analytics,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(const CartState());

  static const maxQuantity = 10;

  final CartRepository _cartRepository;
  final PromotionRepository _promotionRepository;
  final Analytics _analytics;
  final DateTime Function() _clock;

  Future<void> load() async {
    final stored = await _cartRepository.load();
    emit(
      state.copyWith(
        status: CartStatus.ready,
        items: stored.items,
        promotion: () => stored.promotion,
      ),
    );
  }

  Future<void> add(Product product, {String? colorName, int quantity = 1}) {
    final color = colorName ?? product.colors.first.name;
    final items = [...state.items];
    final index = items.indexWhere(
      (i) => i.product.id == product.id && i.colorName == color,
    );
    if (index == -1) {
      items.add(
        CartItem(product: product, colorName: color, quantity: quantity),
      );
    } else {
      final next = (items[index].quantity + quantity).clamp(1, maxQuantity);
      items[index] = items[index].copyWith(quantity: next);
    }
    _analytics.event('add_to_cart', {'product': product.id, 'color': color});
    return _update(state.copyWith(items: items, lastAddedAt: _clock()));
  }

  Future<void> setQuantity(CartItem item, int quantity) {
    if (quantity <= 0) return remove(item);
    final items = state.items
        .map(
          (i) => i.key == item.key
              ? i.copyWith(quantity: quantity.clamp(1, maxQuantity))
              : i,
        )
        .toList();
    return _update(state.copyWith(items: items));
  }

  Future<void> remove(CartItem item) {
    _analytics.event('remove_from_cart', {'product': item.product.id});
    return _update(
      state.copyWith(
        items: state.items.where((i) => i.key != item.key).toList(),
      ),
    );
  }

  /// Puts back a line removed by mistake (the "Undo" in the snackbar).
  Future<void> restore(CartItem item, int index) {
    final items = [...state.items]
      ..insert(index.clamp(0, state.items.length), item);
    return _update(state.copyWith(items: items));
  }

  Future<bool> applyPromo(String code) async {
    if (code.trim().isEmpty) return false;
    emit(
      state.copyWith(promoStatus: PromoStatus.applying, promoError: () => null),
    );
    try {
      final promotion = await _promotionRepository.redeem(code);
      _analytics.event('promo_applied', {'code': promotion.code});
      await _update(
        state.copyWith(
          promotion: () => promotion,
          promoStatus: PromoStatus.idle,
        ),
      );
      return true;
    } on PromoException catch (e) {
      emit(
        state.copyWith(
          promoStatus: PromoStatus.failed,
          promoError: () => e.error,
        ),
      );
      return false;
    }
  }

  Future<void> removePromo() =>
      _update(state.copyWith(promotion: () => null, promoError: () => null));

  Future<void> clear() =>
      _update(state.copyWith(items: const [], promotion: () => null));

  Future<void> _update(CartState next) async {
    emit(next);
    await _cartRepository.save(next.items, next.promotion);
  }
}
