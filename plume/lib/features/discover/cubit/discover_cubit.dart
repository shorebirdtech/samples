import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plume/data/models/models.dart';
import 'package:plume/data/repositories/catalog_repository.dart';
import 'package:plume/data/sources/catalog_api.dart';

enum DiscoverStatus { loading, ready, failure }

class DiscoverState extends Equatable {
  const DiscoverState({
    this.status = DiscoverStatus.loading,
    this.categories = const [],
    this.collections = const [],
    this.products = const [],
  });

  final DiscoverStatus status;
  final List<Category> categories;
  final List<Collection> collections;
  final List<Product> products;

  List<Product> get trending => products.where((p) => p.isTrending).toList();
  List<Product> get deals => products.where((p) => p.isOnSale).toList();
  List<Product> get newArrivals => products.where((p) => p.isNew).toList();
  List<Product> get bestsellers =>
      products.where((p) => p.isBestseller).toList();

  @override
  List<Object> get props => [status, categories, collections, products];
}

class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit(this._catalog) : super(const DiscoverState());

  final CatalogRepository _catalog;

  Future<void> load({bool refresh = false}) async {
    if (!refresh) emit(const DiscoverState());
    try {
      final results = await Future.wait([
        _catalog.categories(),
        _catalog.collections(),
        _catalog.products(refresh: refresh),
      ]);
      emit(
        DiscoverState(
          status: DiscoverStatus.ready,
          categories: results[0] as List<Category>,
          collections: results[1] as List<Collection>,
          products: results[2] as List<Product>,
        ),
      );
    } on NetworkException {
      emit(const DiscoverState(status: DiscoverStatus.failure));
    }
  }
}
