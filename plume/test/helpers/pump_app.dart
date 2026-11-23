import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:plume/app/app.dart';
import 'package:plume/app/dependencies.dart';
import 'package:plume/core/logging/analytics.dart';
import 'package:plume/core/logging/crash_reporter.dart';
import 'package:plume/core/logging/logger.dart';
import 'package:plume/core/storage/key_value_store.dart';
import 'package:plume/data/repositories/repositories.dart';
import 'package:plume/data/sources/catalog_api.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class MockUpdater extends Mock implements ShorebirdUpdater;

/// Storage for a returning shopper who has finished onboarding.
InMemoryStore onboardedStore() => InMemoryStore({
  'settings.v1': '{"onboardingComplete":true,"themeMode":"light"}',
});

AppDependencies testDependencies({
  KeyValueStore? store,
  ShorebirdUpdater? updater,
}) {
  final kv = store ?? InMemoryStore();
  final logger = AppLogger(minLevel: LogLevel.error);
  final api = CatalogApi(latency: Duration.zero);
  final catalog = CatalogRepository(api);
  final fakeUpdater = updater ?? MockUpdater();
  if (updater == null) {
    when(() => fakeUpdater.isAvailable).thenReturn(false);
  }
  return AppDependencies(
    logger: logger,
    crashReporter: CrashReporter(logger),
    analytics: Analytics(logger),
    api: api,
    catalog: catalog,
    promotions: PromotionRepository(api),
    cart: CartRepository(kv, catalog),
    wishlist: WishlistRepository(kv),
    orders: OrderRepository(kv, latency: Duration.zero),
    settings: SettingsRepository(kv),
    updater: fakeUpdater,
  );
}

extension PumpApp on WidgetTester {
  /// Pumps the whole app on a phone-sized screen with animations disabled,
  /// the way a user with "reduce motion" would see it.
  Future<AppDependencies> pumpPlume({
    KeyValueStore? store,
    ShorebirdUpdater? updater,
    String? initialLocation,
  }) async {
    PackageInfo.setMockInitialValues(
      appName: 'Plume',
      packageName: 'dev.shorebird.plume',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(() {
      view.reset();
      platformDispatcher.clearAccessibilityFeaturesTestValue();
    });
    final dependencies = testDependencies(store: store, updater: updater);
    await pumpWidget(
      initialLocation == null
          ? App(dependencies: dependencies)
          : App(dependencies: dependencies, initialLocation: initialLocation),
    );
    await pumpAndSettle();
    return dependencies;
  }

  /// Taps the first widget matching [finder] after scrolling it to the middle
  /// of the screen, clear of the floating navigation bar.
  Future<void> tapVisible(Finder finder) async {
    await Scrollable.ensureVisible(element(finder.first), alignment: 0.5);
    await pumpAndSettle();
    await tap(finder.first);
    await pumpAndSettle();
  }
}
