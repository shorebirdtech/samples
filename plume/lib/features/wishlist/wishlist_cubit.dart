import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plume/core/logging/analytics.dart';
import 'package:plume/data/repositories/wishlist_repository.dart';

/// Holds the ids of saved products, most recently saved first.
class WishlistCubit extends Cubit<List<String>> {
  WishlistCubit(this._repository, this._analytics) : super(const []);

  final WishlistRepository _repository;
  final Analytics _analytics;

  Future<void> load() async => emit(await _repository.load());

  bool contains(String productId) => state.contains(productId);

  Future<void> toggle(String productId) async {
    final saved = state.contains(productId);
    final next = saved
        ? state.where((id) => id != productId).toList()
        : [productId, ...state];
    _analytics.event(saved ? 'wishlist_remove' : 'wishlist_add', {
      'product': productId,
    });
    emit(next);
    await _repository.save(next);
  }
}
