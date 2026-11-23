import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/app/shell.dart';
import 'package:plume/core/logging/analytics.dart';
import 'package:plume/core/logging/crash_reporter.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/features/cart/view/cart_page.dart';
import 'package:plume/features/checkout/view/checkout_page.dart';
import 'package:plume/features/checkout/view/order_confirmed_page.dart';
import 'package:plume/features/discover/view/collection_page.dart';
import 'package:plume/features/discover/view/discover_page.dart';
import 'package:plume/features/launch/splash_page.dart';
import 'package:plume/features/onboarding/onboarding_page.dart';
import 'package:plume/features/orders/view/order_tracking_page.dart';
import 'package:plume/features/orders/view/orders_page.dart';
import 'package:plume/features/product/view/product_page.dart';
import 'package:plume/features/profile/profile_page.dart';
import 'package:plume/features/search/view/search_page.dart';
import 'package:plume/features/settings/settings_cubit.dart';
import 'package:plume/features/settings/settings_page.dart';
import 'package:plume/features/updates/updates_page.dart';
import 'package:plume/features/wishlist/wishlist_page.dart';

/// Holds the splash screen until its intro animation has played.
class LaunchGate extends ChangeNotifier {
  bool _done = false;

  bool get done => _done;

  void complete() {
    if (_done) return;
    _done = true;
    notifyListeners();
  }
}

abstract final class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const discover = '/discover';
  static const search = '/search';
  static const wishlist = '/wishlist';
  static const cart = '/cart';
  static const profile = '/profile';
  static const checkout = '/checkout';
  static const orders = '/orders';
  static const settings = '/settings';
  static const updates = '/updates';

  static String product(String id, {String? hero}) => Uri(
    path: '/product/$id',
    queryParameters: hero == null ? null : {'hero': hero},
  ).toString();

  static String collection(String id) => '/collection/$id';
  static String order(String id) => '/orders/$id';
  static String orderConfirmed(String id) => '/order-confirmed/$id';
  static String searchCategory(String id) => '/search?category=$id';
}

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter buildRouter({
  required SettingsCubit settings,
  required LaunchGate launch,
  required Analytics analytics,
  required CrashReporter crashReporter,
  String initialLocation = Routes.splash,
}) {
  final refresh = _StreamListenable([settings.stream], launch);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: refresh,
    observers: [_ScreenObserver(analytics, crashReporter)],
    redirect: (context, state) {
      final location = state.matchedLocation;
      const gates = {Routes.splash, Routes.onboarding};
      // A deep link that arrives during launch is carried through the
      // splash and onboarding gates as `from`, then honoured.
      final from = gates.contains(location)
          ? state.uri.queryParameters['from']
          : state.uri.toString();
      String? gate(String path) => location == path
          ? null
          : Uri(
              path: path,
              queryParameters: from == null ? null : {'from': from},
            ).toString();

      if (!launch.done) return gate(Routes.splash);
      if (!settings.state.onboardingComplete) return gate(Routes.onboarding);
      return gates.contains(location) ? (from ?? Routes.discover) : null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        pageBuilder: (context, state) =>
            _fade(state, SplashPage(onFinished: launch.complete)),
      ),
      GoRoute(
        path: Routes.onboarding,
        pageBuilder: (context, state) => _fade(state, const OnboardingPage()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          _branch(Routes.discover, const DiscoverPage()),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.search,
                builder: (context, state) => SearchPage(
                  initialCategoryId: state.uri.queryParameters['category'],
                ),
              ),
            ],
          ),
          _branch(Routes.wishlist, const WishlistPage()),
          _branch(Routes.cart, const CartPage()),
          _branch(Routes.profile, const ProfilePage()),
        ],
      ),
      GoRoute(
        path: '/product/:id',
        pageBuilder: (context, state) => _zoom(
          state,
          ProductPage(
            productId: state.pathParameters['id']!,
            heroTag: state.uri.queryParameters['hero'],
          ),
        ),
      ),
      GoRoute(
        path: '/collection/:id',
        builder: (context, state) =>
            CollectionPage(collectionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.checkout,
        pageBuilder: (context, state) => _slideUp(state, const CheckoutPage()),
      ),
      GoRoute(
        path: '/order-confirmed/:id',
        pageBuilder: (context, state) => _fade(
          state,
          OrderConfirmedPage(orderId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: Routes.orders,
        builder: (context, state) => const OrdersPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                OrderTrackingPage(orderId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: Routes.updates,
        builder: (context, state) => const UpdatesPage(),
      ),
    ],
    errorBuilder: (context, state) => const _NotFoundPage(),
  );
}

StatefulShellBranch _branch(String path, Widget page) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (context, state) => page)],
);

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      transitionDuration: Motion.page,
      child: child,
      transitionsBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );

CustomTransitionPage<void> _zoom(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      transitionDuration: Motion.page,
      reverseTransitionDuration: Motion.medium,
      child: child,
      transitionsBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Motion.emphasized,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );

CustomTransitionPage<void> _slideUp(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      transitionDuration: Motion.page,
      child: child,
      transitionsBuilder: (context, animation, _, child) => SlideTransition(
        position: Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Motion.emphasized)),
        child: child,
      ),
    );

class _StreamListenable extends ChangeNotifier {
  _StreamListenable(List<Stream<Object?>> streams, Listenable other) {
    _subscriptions = [
      for (final stream in streams) stream.listen((_) => notifyListeners()),
    ];
    _other = other..addListener(notifyListeners);
  }

  late final List<StreamSubscription<Object?>> _subscriptions;
  late final Listenable _other;

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _other.removeListener(notifyListeners);
    super.dispose();
  }
}

class _ScreenObserver extends NavigatorObserver {
  _ScreenObserver(this._analytics, this._crashReporter);

  final Analytics _analytics;
  final CrashReporter _crashReporter;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    if (name == null) return;
    _analytics.screen(name);
    _crashReporter.breadcrumb('open $name');
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Center(
      child: TextButton(
        onPressed: () => context.go(Routes.discover),
        child: const Icon(Icons.home_rounded, size: 48),
      ),
    ),
  );
}
