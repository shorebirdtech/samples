import 'package:plume/core/storage/key_value_store.dart';
import 'package:plume/data/models/models.dart';
import 'package:plume/data/repositories/catalog_repository.dart';

class StoredCart {
  const StoredCart({required this.items, this.promotion});

  final List<CartItem> items;
  final Promotion? promotion;
}

class CartRepository {
  CartRepository(this._store, this._catalog);

  static const _key = 'cart.v1';

  final KeyValueStore _store;
  final CatalogRepository _catalog;

  Future<StoredCart> load() async {
    final json = await _store.readJson(_key);
    if (json is! Map<String, dynamic>) return const StoredCart(items: []);
    final items = <CartItem>[];
    for (final raw in (json['items'] as List<dynamic>? ?? const [])) {
      final line = raw as Map<String, dynamic>;
      final product = await _catalog.productById(line['productId'] as String);
      // Products can disappear from the catalog between sessions.
      if (product == null) continue;
      items.add(
        CartItem(
          product: product,
          colorName: line['colorName'] as String,
          quantity: line['quantity'] as int,
        ),
      );
    }
    final promo = json['promotion'];
    return StoredCart(
      items: items,
      promotion: promo is Map<String, dynamic>
          ? Promotion.fromJson(promo)
          : null,
    );
  }

  Future<void> save(List<CartItem> items, Promotion? promotion) =>
      _store.writeJson(_key, {
        'items': items.map((e) => e.toJson()).toList(),
        'promotion': promotion?.toJson(),
      });
}
