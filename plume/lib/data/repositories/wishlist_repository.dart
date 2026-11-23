import 'package:plume/core/storage/key_value_store.dart';

class WishlistRepository {
  WishlistRepository(this._store);

  static const _key = 'wishlist.v1';

  final KeyValueStore _store;

  Future<List<String>> load() async {
    final json = await _store.readJson(_key);
    return json is List ? json.cast<String>() : <String>[];
  }

  Future<void> save(List<String> productIds) =>
      _store.writeJson(_key, productIds);
}
