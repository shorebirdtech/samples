import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plume/core/logging/analytics.dart';
import 'package:plume/data/repositories/catalog_repository.dart';
import 'package:plume/data/sources/catalog_api.dart';
import 'package:plume/features/search/cubit/search_cubit.dart';

class _MockAnalytics extends Mock implements Analytics;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CatalogApi api;

  SearchCubit build({String? category}) => SearchCubit(
    CatalogRepository(api),
    _MockAnalytics(),
    categoryId: category,
    debounce: Duration.zero,
  );

  setUp(() => api = CatalogApi(latency: Duration.zero));

  test('init loads categories and results for the initial category', () async {
    final cubit = build(category: 'bags');
    await cubit.init();
    expect(cubit.state.status, SearchStatus.ready);
    expect(cubit.state.categories, isNotEmpty);
    expect(cubit.state.results.every((p) => p.categoryId == 'bags'), isTrue);
    await cubit.close();
  });

  test('typing runs a debounced search', () async {
    final cubit = build();
    await cubit.init();
    cubit.setText('kettle');
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(cubit.state.results.single.id, 'brew-kettle');
    await cubit.close();
  });

  test('filters count and clear', () async {
    final cubit = build();
    await cubit.init();
    await cubit.applyFilters(
      maxPriceCents: 10000,
      onSaleOnly: true,
      sort: ProductSort.priceHighLow,
    );
    expect(cubit.state.activeFilterCount, 3);
    expect(cubit.state.results.every((p) => p.isOnSale), isTrue);
    await cubit.clearFilters();
    expect(cubit.state.activeFilterCount, 0);
    await cubit.close();
  });

  test('network failure then retry', () async {
    final cubit = build();
    // Fails the first product fetch, before anything is cached.
    api.failNextRequest = true;
    await cubit.retry();
    expect(cubit.state.status, SearchStatus.failure);
    await cubit.retry();
    expect(cubit.state.status, SearchStatus.ready);
    await cubit.close();
  });
}
