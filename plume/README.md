# 🛍️ Plume

Plume is a premium shopping app built to demo Shorebird code push at events
and on client calls. Release 1.0.0 ships with a realistic checkout bug, and
you fix it live with `shorebird patch`.

**[DEMO.md](DEMO.md) is the step-by-step script.**

## What's in the app

| Area | Highlights |
|---|---|
| Launch | Animated splash, three-step onboarding with parallax, then straight into the store (no sign-in) |
| Discover | Auto-advancing collection carousel, animated promo banner, categories, product rails, staggered grid, pull to refresh, skeleton loading |
| Product | Hero transition, drag-to-tilt 3D product art, colour variants, rating histogram, reviews, related products, "fly to bag" animation |
| Search | Debounced search, category chips, price/sale/sort filters in a bottom sheet |
| Bag | Swipe to remove with undo, quantity steppers, free-shipping meter, promo codes, animated totals |
| Checkout | Four-step flow, live card preview that flips for the CVV, Luhn and expiry validation, declined-card handling, confetti on success |
| Orders | Order history and live tracking with an animated route map and timeline |
| Profile | The demo shopper, stats, settings (theme, language, notifications) |
| App updates | In-app Shorebird panel: running patch, check, install, restart |

## Architecture

```
lib/
  app/          App widget, dependency wiring, router (go_router), tab shell
  core/         Money, theme and motion tokens, logging, storage, shared widgets
  data/         Models, the simulated store API, repositories
  features/     One folder per feature: cubits (flutter_bloc) and views
  l10n/         ARB files (English, Spanish) and generated localizations
```

- **State:** `flutter_bloc` cubits. App-wide state (cart, wishlist, orders,
  settings, updates) lives above the router, and screen state is
  scoped to each page.
- **Data:** repositories over `CatalogApi`, which serves bundled JSON with
  simulated latency. The app works with no network, apart from downloading
  patches. Swap `CatalogApi` for a real HTTP client to use a backend.
- **Money:** amounts are integer cents in a `Money` value type. One
  `PriceCalculator` produces the totals for the bag, checkout and receipt.
- **Persistence:** `SharedPreferencesAsync` behind a `KeyValueStore`
  interface, with an in-memory store for tests.
- **Navigation:** `go_router` with a stateful tab shell and redirects for
  the splash and onboarding. Deep links are kept through onboarding.
- **Updates:** `UpdateCubit` wraps `package:shorebird_code_push`. Checks run
  in the background at launch and on resume, and never block the UI.
- **Reliability:** errors go to `CrashReporter` through `FlutterError`,
  `PlatformDispatcher` and a `BlocObserver`, with breadcrumbs from the router.
  `Analytics` logs screens and events. Both are ready to point at a vendor SDK.
- **Accessibility:** semantics labels throughout, and every animation
  respects the system "reduce motion" setting.

## Running it

```sh
flutter pub get
flutter run
```

`flutter run` builds without the Shorebird engine, so App updates says that
updates are unavailable. Use `shorebird release` and `shorebird preview` to
try code push (see [DEMO.md](DEMO.md)).

Demo data:

- There's no sign-in: everyone shops as the demo shopper, Alex Morgan.
- Promo codes: `SAVE10` (the bug), `WELCOME15`, `FREESHIP`.
- Cards: `4242 4242 4242 4242` succeeds, and `4000 0000 0000 0002` is declined.

## App icon

The launcher icon is drawn by the same `PlumeFeatherPainter` as the in-app
logo. After changing it, regenerate the artwork and the platform icons:

```sh
flutter test tool/generate_app_icon.dart
dart run flutter_launcher_icons
```

## Tests

```sh
flutter test
```

The suite covers the pricing rules, cubits, repositories and formatters,
plus widget tests that walk through onboarding, shopping, checkout, order
tracking and installing a patch. One test is skipped on purpose: it checks
the `SAVE10` fix, and the demo patch removes the skip.
