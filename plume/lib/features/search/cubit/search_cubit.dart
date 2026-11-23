import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plume/core/logging/analytics.dart';
import 'package:plume/data/models/models.dart';
import 'package:plume/data/repositories/catalog_repository.dart';
import 'package:plume/data/sources/catalog_api.dart';

enum SearchStatus { loading, ready, failure }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.loading,
    this.text = '',
    this.categoryId,
    this.maxPriceCents,
    this.onSaleOnly = false,
    this.sort = ProductSort.featured,
    this.categories = const [],
    this.results = const [],
  });

  static const priceCeilingCents = 35000;

  final SearchStatus status;
  final String text;
  final String? categoryId;
  final int? maxPriceCents;
  final bool onSaleOnly;
  final ProductSort sort;
  final List<Category> categories;
  final List<Product> results;

  int get activeFilterCount =>
      (maxPriceCents != null ? 1 : 0) +
      (onSaleOnly ? 1 : 0) +
      (sort != ProductSort.featured ? 1 : 0);

  ProductQuery get query => ProductQuery(
    text: text,
    categoryId: categoryId,
    maxPriceCents: maxPriceCents,
    onSaleOnly: onSaleOnly,
    sort: sort,
  );

  SearchState copyWith({
    SearchStatus? status,
    String? text,
    String? Function()? categoryId,
    int? Function()? maxPriceCents,
    bool? onSaleOnly,
    ProductSort? sort,
    List<Category>? categories,
    List<Product>? results,
  }) => SearchState(
    status: status ?? this.status,
    text: text ?? this.text,
    categoryId: categoryId != null ? categoryId() : this.categoryId,
    maxPriceCents: maxPriceCents != null ? maxPriceCents() : this.maxPriceCents,
    onSaleOnly: onSaleOnly ?? this.onSaleOnly,
    sort: sort ?? this.sort,
    categories: categories ?? this.categories,
    results: results ?? this.results,
  );

  @override
  List<Object?> get props => [
    status,
    text,
    categoryId,
    maxPriceCents,
    onSaleOnly,
    sort,
    categories,
    results,
  ];
}

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(
    this._catalog,
    this._analytics, {
    String? categoryId,
    this.debounce = const Duration(milliseconds: 280),
  }) : super(SearchState(categoryId: categoryId));

  final CatalogRepository _catalog;
  final Analytics _analytics;
  final Duration debounce;
  Timer? _debounce;
  int _generation = 0;

  Future<void> init() async {
    try {
      emit(state.copyWith(categories: await _catalog.categories()));
    } on NetworkException {
      // Categories are optional; search still works without the chips.
    }
    await _run();
  }

  void setText(String text) {
    emit(state.copyWith(text: text));
    _debounce?.cancel();
    _debounce = Timer(debounce, () {
      if (text.trim().isNotEmpty) {
        _analytics.event('search', {'query': text.trim()});
      }
      unawaited(_run());
    });
  }

  Future<void> setCategory(String? id) {
    emit(state.copyWith(categoryId: () => id));
    return _run();
  }

  Future<void> applyFilters({
    required int? maxPriceCents,
    required bool onSaleOnly,
    required ProductSort sort,
  }) {
    emit(
      state.copyWith(
        maxPriceCents: () => maxPriceCents,
        onSaleOnly: onSaleOnly,
        sort: sort,
      ),
    );
    return _run();
  }

  Future<void> clearFilters() => applyFilters(
    maxPriceCents: null,
    onSaleOnly: false,
    sort: ProductSort.featured,
  );

  Future<void> retry() => _run();

  Future<void> _run() async {
    final generation = ++_generation;
    emit(state.copyWith(status: SearchStatus.loading));
    try {
      final results = await _catalog.search(state.query);
      // Drop responses that a newer query has superseded.
      if (generation != _generation || isClosed) return;
      emit(state.copyWith(status: SearchStatus.ready, results: results));
    } on NetworkException {
      if (generation != _generation || isClosed) return;
      emit(state.copyWith(status: SearchStatus.failure));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
