import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/app/dependencies.dart';
import 'package:plume/app/router.dart';
import 'package:plume/core/theme/app_theme.dart';
import 'package:plume/data/repositories/settings_repository.dart';
import 'package:plume/features/cart/cubit/cart_cubit.dart';
import 'package:plume/features/orders/orders_cubit.dart';
import 'package:plume/features/settings/settings_cubit.dart';
import 'package:plume/features/updates/update_banner.dart';
import 'package:plume/features/updates/update_cubit.dart';
import 'package:plume/features/wishlist/wishlist_cubit.dart';
import 'package:plume/l10n/l10n.dart';

class App extends StatefulWidget {
  const App({
    required this.dependencies,
    this.initialLocation = Routes.splash,
    super.key,
  });

  final AppDependencies dependencies;

  /// Where the router starts; a deep link is honoured once signed in.
  final String initialLocation;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppDependencies d = widget.dependencies;
  late final _settings = SettingsCubit(d.settings);
  late final _cart = CartCubit(
    cartRepository: d.cart,
    promotionRepository: d.promotions,
    analytics: d.analytics,
  );
  late final _wishlist = WishlistCubit(d.wishlist, d.analytics);
  late final _orders = OrdersCubit(d.orders, d.analytics);
  late final _updates = UpdateCubit(
    updater: d.updater,
    logger: d.logger,
    analytics: d.analytics,
  );
  late final _launch = LaunchGate();
  late final GoRouter _router = buildRouter(
    settings: _settings,
    launch: _launch,
    analytics: d.analytics,
    crashReporter: d.crashReporter,
    initialLocation: widget.initialLocation,
  );
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    unawaited(_restore());
    _lifecycle = AppLifecycleListener(
      onResume: () => unawaited(_updates.check(silent: true)),
    );
  }

  Future<void> _restore() async {
    await _settings.load();
    // Never awaited: an update check must not hold up the UI.
    unawaited(_updates.initialize());
    await Future.wait([_cart.load(), _wishlist.load(), _orders.load()]);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _router.dispose();
    _launch.dispose();
    unawaited(_settings.close());
    unawaited(_cart.close());
    unawaited(_wishlist.close());
    unawaited(_orders.close());
    unawaited(_updates.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: d),
        RepositoryProvider.value(value: d.catalog),
        RepositoryProvider.value(value: d.analytics),
        RepositoryProvider.value(value: d.api),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _settings),
          BlocProvider.value(value: _cart),
          BlocProvider.value(value: _wishlist),
          BlocProvider.value(value: _orders),
          BlocProvider.value(value: _updates),
        ],
        child: BlocBuilder<SettingsCubit, AppSettings>(
          buildWhen: (a, b) =>
              a.themeMode != b.themeMode || a.localeCode != b.localeCode,
          builder: (context, settings) => MaterialApp.router(
            onGenerateTitle: (context) => context.l10n.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            routerConfig: _router,
            builder: (context, child) => UpdateBanner(
              router: _router,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
