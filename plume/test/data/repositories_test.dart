import 'package:flutter_test/flutter_test.dart';
import 'package:plume/core/money.dart';
import 'package:plume/core/storage/key_value_store.dart';
import 'package:plume/data/models/models.dart';
import 'package:plume/data/repositories/repositories.dart';
import 'package:plume/data/sources/catalog_api.dart';

import '../helpers/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CatalogApi api;
  late CatalogRepository catalog;

  setUp(() {
    api = CatalogApi(latency: Duration.zero);
    catalog = CatalogRepository(api);
  });

  group('CatalogRepository', () {
    test('loads the bundled catalog', () async {
      final products = await catalog.products();
      expect(products, isNotEmpty);
      expect(await catalog.categories(), hasLength(5));
      expect(await catalog.collections(), isNotEmpty);
      expect(await catalog.productById('nomad-pack'), isNotNull);
      expect(await catalog.productById('missing'), isNull);
    });

    test('every collection and review points at a real product', () async {
      final ids = (await catalog.products()).map((p) => p.id).toSet();
      for (final collection in await catalog.collections()) {
        expect(ids, containsAll(collection.productIds));
      }
      for (final product in await catalog.products()) {
        final reviews = await catalog.reviewsFor(product.id);
        expect(reviews, isNotEmpty, reason: product.id);
      }
    });

    test('search filters by text, category, price and sale', () async {
      final keyboards = await catalog.search(
        const ProductQuery(text: 'keyboard'),
      );
      expect(keyboards.map((p) => p.id), contains('flux-keyboard'));

      final audio = await catalog.search(
        const ProductQuery(categoryId: 'audio'),
      );
      expect(audio.every((p) => p.categoryId == 'audio'), isTrue);

      final cheap = await catalog.search(
        const ProductQuery(maxPriceCents: 7000),
      );
      expect(cheap.every((p) => p.price.cents <= 7000), isTrue);

      final sale = await catalog.search(const ProductQuery(onSaleOnly: true));
      expect(sale.every((p) => p.isOnSale), isTrue);
    });

    test('search sorts results', () async {
      final low = await catalog.search(
        const ProductQuery(sort: ProductSort.priceLowHigh),
      );
      for (var i = 1; i < low.length; i++) {
        expect(low[i].price >= low[i - 1].price, isTrue);
      }
      final rated = await catalog.search(
        const ProductQuery(sort: ProductSort.rating),
      );
      expect(rated.first.rating, greaterThanOrEqualTo(rated.last.rating));
    });

    test('related products exclude the product itself', () async {
      final product = (await catalog.productById('aero-buds'))!;
      final related = await catalog.related(product);
      expect(related.map((p) => p.id), isNot(contains('aero-buds')));
    });

    test('network failures surface as NetworkException', () async {
      api.failNextRequest = true;
      await expectLater(catalog.categories(), throwsA(isA<NetworkException>()));
      expect(await catalog.categories(), isNotEmpty);
    });
  });

  group('PromotionRepository', () {
    test('redeems codes case-insensitively', () async {
      final promo = await PromotionRepository(api).redeem(' save10 ');
      expect(promo.code, 'SAVE10');
      expect(promo.kind, PromotionKind.fixed);
    });

    test('rejects unknown codes', () {
      expect(
        PromotionRepository(api).redeem('BOGUS'),
        throwsA(
          isA<PromoException>().having(
            (e) => e.error,
            'error',
            PromoError.notFound,
          ),
        ),
      );
    });

    test('reports network failures', () {
      api.failNextRequest = true;
      expect(
        PromotionRepository(api).redeem('SAVE10'),
        throwsA(
          isA<PromoException>().having(
            (e) => e.error,
            'error',
            PromoError.network,
          ),
        ),
      );
    });
  });

  group('CartRepository', () {
    test('round-trips items and promotion', () async {
      final store = InMemoryStore();
      final repository = CartRepository(store, catalog);
      final pack = (await catalog.productById('nomad-pack'))!;
      await repository.save([item(pack, quantity: 2, color: 'Olive')], save10);
      final loaded = await repository.load();
      expect(loaded.items.single.quantity, 2);
      expect(loaded.items.single.colorName, 'Olive');
      expect(loaded.promotion, save10);
    });

    test('drops products that left the catalog', () async {
      final store = InMemoryStore({
        'cart.v1':
            '{"items":[{"productId":"gone","colorName":"x","quantity":1}]}',
      });
      final loaded = await CartRepository(store, catalog).load();
      expect(loaded.items, isEmpty);
    });

    test('survives corrupt data', () async {
      final store = InMemoryStore({'cart.v1': '{not json'});
      final loaded = await CartRepository(store, catalog).load();
      expect(loaded.items, isEmpty);
    });
  });

  group('User', () {
    test('the demo shopper has a first name and initials', () {
      expect(User.demo.firstName, 'Alex');
      expect(User.demo.initials, 'AM');
    });
  });

  group('OrderRepository', () {
    final placedAt = DateTime(2026, 11, 20, 12);

    OrderRepository build(KeyValueStore store) =>
        OrderRepository(store, latency: Duration.zero, clock: () => placedAt);

    const line = OrderLine(
      productId: 'nomad-pack',
      name: 'Nomad Daypack',
      icon: 'backpack',
      colorName: 'Olive',
      colorValue: 0xFF6B7550,
      quantity: 1,
      unitPrice: Money.cents(12900),
    );

    test('places and persists orders, newest first', () async {
      final store = InMemoryStore();
      final repository = build(store);
      final first = await repository.place(
        lines: const [line],
        amounts: const {'subtotal': 12900, 'total': 13932},
        address: address,
        shippingMethod: ShippingMethod.standard,
        card: const PaymentCard(
          holder: 'Ada',
          number: '4242 4242 4242 4242',
          expiry: '12/30',
        ),
      );
      expect(first.total.cents, 13932);
      expect(first.cardLast4, '4242');
      final orders = await build(store).load();
      expect(orders.single.id, first.id);
      expect(orders.single.lines.single, line);
    });

    test('declines the 0002 test card', () {
      expect(
        build(InMemoryStore()).place(
          lines: const [line],
          amounts: const {},
          address: address,
          shippingMethod: ShippingMethod.express,
          card: const PaymentCard(
            holder: 'Ada',
            number: '4000 0000 0000 0002',
            expiry: '12/30',
          ),
        ),
        throwsA(isA<PaymentException>()),
      );
    });

    test('order status advances on the demo clock', () {
      final order = Order(
        id: 'PL-1',
        placedAt: placedAt,
        lines: const [line],
        subtotal: Money.zero,
        discount: Money.zero,
        shipping: Money.zero,
        tax: Money.zero,
        total: Money.zero,
        address: address,
        shippingMethod: ShippingMethod.standard,
        cardLast4: '4242',
      );
      expect(order.statusAt(placedAt), OrderStatus.placed);
      expect(
        order.statusAt(placedAt.add(const Duration(seconds: 95))),
        OrderStatus.shipped,
      );
      expect(
        order.statusAt(placedAt.add(const Duration(hours: 1))),
        OrderStatus.delivered,
      );
    });
  });

  group('SettingsRepository', () {
    test('defaults, then round-trips', () async {
      final store = InMemoryStore();
      final repository = SettingsRepository(store);
      expect((await repository.load()).onboardingComplete, isFalse);
      await repository.save(
        const AppSettings(onboardingComplete: true, localeCode: 'es'),
      );
      final loaded = await repository.load();
      expect(loaded.onboardingComplete, isTrue);
      expect(loaded.locale?.languageCode, 'es');
    });
  });
}
