import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plume/data/models/models.dart';
import 'package:plume/data/repositories/catalog_repository.dart';
import 'package:plume/data/sources/catalog_api.dart';

enum ProductStatus { loading, ready, notFound, failure }

class ProductState extends Equatable {
  const ProductState({
    this.status = ProductStatus.loading,
    this.product,
    this.reviews = const [],
    this.related = const [],
    this.colorIndex = 0,
    this.quantity = 1,
  });

  final ProductStatus status;
  final Product? product;
  final List<Review> reviews;
  final List<Product> related;
  final int colorIndex;
  final int quantity;

  ProductColor? get color => product?.colors[colorIndex];

  /// Count of reviews per star rating, index 0 being five stars.
  List<int> get ratingHistogram {
    final counts = List.filled(5, 0);
    for (final review in reviews) {
      counts[5 - review.rating.clamp(1, 5)]++;
    }
    return counts;
  }

  ProductState copyWith({
    ProductStatus? status,
    Product? product,
    List<Review>? reviews,
    List<Product>? related,
    int? colorIndex,
    int? quantity,
  }) => ProductState(
    status: status ?? this.status,
    product: product ?? this.product,
    reviews: reviews ?? this.reviews,
    related: related ?? this.related,
    colorIndex: colorIndex ?? this.colorIndex,
    quantity: quantity ?? this.quantity,
  );

  @override
  List<Object?> get props => [
    status,
    product,
    reviews,
    related,
    colorIndex,
    quantity,
  ];
}

class ProductCubit extends Cubit<ProductState> {
  ProductCubit(this._catalog, this.productId) : super(const ProductState());

  final CatalogRepository _catalog;
  final String productId;

  Future<void> load() async {
    emit(state.copyWith(status: ProductStatus.loading));
    try {
      final product = await _catalog.productById(productId);
      if (product == null) {
        emit(state.copyWith(status: ProductStatus.notFound));
        return;
      }
      final results = await Future.wait([
        _catalog.reviewsFor(productId),
        _catalog.related(product),
      ]);
      emit(
        state.copyWith(
          status: ProductStatus.ready,
          product: product,
          reviews: results[0] as List<Review>,
          related: results[1] as List<Product>,
        ),
      );
    } on NetworkException {
      emit(state.copyWith(status: ProductStatus.failure));
    }
  }

  void selectColor(int index) => emit(state.copyWith(colorIndex: index));

  void setQuantity(int quantity) =>
      emit(state.copyWith(quantity: quantity.clamp(1, 10)));
}
