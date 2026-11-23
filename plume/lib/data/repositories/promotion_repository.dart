import 'package:plume/data/models/promotion.dart';
import 'package:plume/data/sources/catalog_api.dart';

enum PromoError { notFound, network }

class PromoException implements Exception {
  const PromoException(this.error);

  final PromoError error;
}

class PromotionRepository {
  PromotionRepository(this._api);

  final CatalogApi _api;

  Future<Promotion> redeem(String code) async {
    final normalized = code.trim().toUpperCase();
    try {
      final promotions = (await _api.get('promotions')).map(Promotion.fromJson);
      return promotions.firstWhere(
        (p) => p.code == normalized,
        orElse: () => throw const PromoException(PromoError.notFound),
      );
    } on NetworkException {
      throw const PromoException(PromoError.network);
    }
  }

  Future<List<Promotion>> featured() async =>
      (await _api.get('promotions')).map(Promotion.fromJson).toList();
}
