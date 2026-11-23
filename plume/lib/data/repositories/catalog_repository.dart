import 'package:plume/data/models/models.dart';
import 'package:plume/data/sources/catalog_api.dart';

enum ProductSort { featured, priceLowHigh, priceHighLow, rating }

class ProductQuery {
  const ProductQuery({
    this.text = '',
    this.categoryId,
    this.maxPriceCents,
    this.onSaleOnly = false,
    this.sort = ProductSort.featured,
  });

  final String text;
  final String? categoryId;
  final int? maxPriceCents;
  final bool onSaleOnly;
  final ProductSort sort;
}

class CatalogRepository {
  CatalogRepository(this._api);

  final CatalogApi _api;

  List<Product>? _products;

  Future<List<Product>> products({bool refresh = false}) async {
    if (_products != null && !refresh) return _products!;
    final json = await _api.get('products');
    return _products = json.map(Product.fromJson).toList();
  }

  Future<Product?> productById(String id) async {
    final all = await products();
    for (final product in all) {
      if (product.id == id) return product;
    }
    return null;
  }

  Future<List<Category>> categories() async =>
      (await _api.get('categories')).map(Category.fromJson).toList();

  Future<List<Collection>> collections() async =>
      (await _api.get('collections')).map(Collection.fromJson).toList();

  Future<List<Review>> reviewsFor(String productId) async =>
      (await _api.get('reviews'))
          .map(Review.fromJson)
          .where((r) => r.productId == productId)
          .toList();

  Future<List<Product>> related(Product product, {int limit = 6}) async {
    final all = await products();
    return all
        .where((p) => p.categoryId == product.categoryId && p.id != product.id)
        .followedBy(
          all.where(
            (p) => p.categoryId != product.categoryId && p.isBestseller,
          ),
        )
        .take(limit)
        .toList();
  }

  Future<List<Product>> search(ProductQuery query) async {
    final text = query.text.trim().toLowerCase();
    final results = (await products()).where((p) {
      if (query.categoryId != null && p.categoryId != query.categoryId) {
        return false;
      }
      if (query.maxPriceCents != null && p.price.cents > query.maxPriceCents!) {
        return false;
      }
      if (query.onSaleOnly && !p.isOnSale) return false;
      if (text.isEmpty) return true;
      return p.name.toLowerCase().contains(text) ||
          p.brand.toLowerCase().contains(text) ||
          p.categoryId.contains(text) ||
          p.highlights.any((h) => h.toLowerCase().contains(text));
    }).toList();
    switch (query.sort) {
      case ProductSort.featured:
        break;
      case ProductSort.priceLowHigh:
        results.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceHighLow:
        results.sort((a, b) => b.price.compareTo(a.price));
      case ProductSort.rating:
        results.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return results;
  }
}
