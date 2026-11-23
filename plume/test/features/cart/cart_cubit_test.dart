import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plume/core/logging/analytics.dart';
import 'package:plume/data/models/models.dart';
import 'package:plume/data/repositories/repositories.dart';
import 'package:plume/features/cart/cubit/cart_cubit.dart';

import '../../helpers/fixtures.dart';

class _MockCartRepository extends Mock implements CartRepository;

class _MockPromotionRepository extends Mock implements PromotionRepository;

class _MockAnalytics extends Mock implements Analytics;

void main() {
  late _MockCartRepository cartRepository;
  late _MockPromotionRepository promotions;
  final now = DateTime(2026, 11, 20, 9);
  final p = product(priceCents: 4000);

  setUpAll(() => registerFallbackValue(<CartItem>[]));

  setUp(() {
    cartRepository = _MockCartRepository();
    promotions = _MockPromotionRepository();
    when(() => cartRepository.save(any(), any())).thenAnswer((_) async {});
  });

  CartCubit build() => CartCubit(
    cartRepository: cartRepository,
    promotionRepository: promotions,
    analytics: _MockAnalytics(),
    clock: () => now,
  );

  group('CartCubit', () {
    blocTest<CartCubit, CartState>(
      'load restores the stored cart',
      setUp: () => when(() => cartRepository.load()).thenAnswer(
        (_) async => StoredCart(items: [item(p)], promotion: save10),
      ),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        CartState(
          status: CartStatus.ready,
          items: [item(p)],
          promotion: save10,
        ),
      ],
    );

    blocTest<CartCubit, CartState>(
      'add merges the same product and colour into one line',
      build: build,
      act: (cubit) async {
        await cubit.add(p);
        await cubit.add(p, quantity: 2);
        await cubit.add(p, colorName: 'Sand');
      },
      verify: (cubit) {
        expect(cubit.state.items, [
          item(p, quantity: 3),
          item(p, color: 'Sand'),
        ]);
        expect(cubit.state.itemCount, 4);
        expect(cubit.state.lastAddedAt, now);
        verify(() => cartRepository.save(any(), any())).called(3);
      },
    );

    blocTest<CartCubit, CartState>(
      'quantity is capped and zero removes the line',
      build: build,
      seed: () => CartState(status: CartStatus.ready, items: [item(p)]),
      act: (cubit) async {
        await cubit.setQuantity(item(p), 99);
        expect(cubit.state.items.single.quantity, CartCubit.maxQuantity);
        await cubit.setQuantity(cubit.state.items.single, 0);
      },
      verify: (cubit) => expect(cubit.state.isEmpty, isTrue),
    );

    blocTest<CartCubit, CartState>(
      'restore puts a removed line back where it was',
      build: build,
      seed: () => CartState(
        status: CartStatus.ready,
        items: [
          item(p),
          item(p, color: 'Sand'),
        ],
      ),
      act: (cubit) async {
        final removed = cubit.state.items.first;
        await cubit.remove(removed);
        await cubit.restore(removed, 0);
      },
      verify: (cubit) => expect(cubit.state.items.first, item(p)),
    );

    blocTest<CartCubit, CartState>(
      'applyPromo stores a valid code',
      setUp: () =>
          when(() => promotions.redeem('save10'))
              .thenAnswer((_) async => save10),
      build: build,
      seed: () => CartState(status: CartStatus.ready, items: [item(p)]),
      act: (cubit) => cubit.applyPromo('save10'),
      expect: () => [
        CartState(
          status: CartStatus.ready,
          items: [item(p)],
          promoStatus: PromoStatus.applying,
        ),
        CartState(
          status: CartStatus.ready,
          items: [item(p)],
          promotion: save10,
        ),
      ],
    );

    blocTest<CartCubit, CartState>(
      'applyPromo reports an unknown code',
      setUp: () =>
          when(() => promotions.redeem('NOPE'))
              .thenThrow(const PromoException(PromoError.notFound)),
      build: build,
      act: (cubit) => cubit.applyPromo('NOPE'),
      skip: 1,
      expect: () => [
        const CartState(
          promoStatus: PromoStatus.failed,
          promoError: PromoError.notFound,
        ),
      ],
    );

    blocTest<CartCubit, CartState>(
      'applyPromo ignores blank input',
      build: build,
      act: (cubit) => cubit.applyPromo('   '),
      expect: () => <CartState>[],
    );

    blocTest<CartCubit, CartState>(
      'clear empties the cart and drops the promotion',
      build: build,
      seed: () => CartState(
        status: CartStatus.ready,
        items: [item(p)],
        promotion: save10,
      ),
      act: (cubit) => cubit.clear(),
      expect: () => [const CartState(status: CartStatus.ready)],
    );
  });
}
