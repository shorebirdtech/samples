import 'package:plume/core/logging/analytics.dart';
import 'package:plume/core/logging/crash_reporter.dart';
import 'package:plume/core/logging/logger.dart';
import 'package:plume/core/storage/key_value_store.dart';
import 'package:plume/data/repositories/repositories.dart';
import 'package:plume/data/sources/catalog_api.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Everything the app needs, built once at startup. Tests build their own
/// with fakes and zero latency.
class AppDependencies {
  AppDependencies({
    required this.logger,
    required this.crashReporter,
    required this.analytics,
    required this.api,
    required this.catalog,
    required this.promotions,
    required this.cart,
    required this.wishlist,
    required this.orders,
    required this.settings,
    required this.updater,
  });

  factory AppDependencies.production() {
    final logger = AppLogger();
    final store = SharedPreferencesStore();
    final api = CatalogApi();
    final catalog = CatalogRepository(api);
    return AppDependencies(
      logger: logger,
      crashReporter: CrashReporter(logger),
      analytics: Analytics(logger),
      api: api,
      catalog: catalog,
      promotions: PromotionRepository(api),
      cart: CartRepository(store, catalog),
      wishlist: WishlistRepository(store),
      orders: OrderRepository(store),
      settings: SettingsRepository(store),
      updater: ShorebirdUpdater(),
    );
  }

  final AppLogger logger;
  final CrashReporter crashReporter;
  final Analytics analytics;
  final CatalogApi api;
  final CatalogRepository catalog;
  final PromotionRepository promotions;
  final CartRepository cart;
  final WishlistRepository wishlist;
  final OrderRepository orders;
  final SettingsRepository settings;
  final ShorebirdUpdater updater;
}
