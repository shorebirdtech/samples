import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plume/core/storage/key_value_store.dart';
import 'package:plume/core/widgets/widgets.dart';
import 'package:plume/features/catalog/widgets/product_card.dart';
import 'package:plume/features/catalog/widgets/wishlist_button.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import '../helpers/pump_app.dart';

/// A bottom navigation tab, whose label may carry a badge count.
Finder _tab(String label) =>
    find.bySemanticsLabel(RegExp('^$label(, \\d+)?\$'));

void main() {
  testWidgets('first launch: onboarding, then Discover', (tester) async {
    await tester.pumpPlume(store: InMemoryStore());

    expect(find.text("Gear you'll love"), findsOneWidget);
    // The white text relies on the dark backdrop filling the screen.
    expect(
      tester.getSize(find.byType(AuroraBackground)),
      tester.view.physicalSize / tester.view.devicePixelRatio,
    );
    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Checkout in seconds'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Find your next favourite'), findsOneWidget);
    expect(find.textContaining('Alex'), findsWidgets);
  });

  testWidgets('shop, apply a promo code, check out and track the order', (
    tester,
  ) async {
    await tester.pumpPlume(store: onboardedStore());

    await tester.tapVisible(find.text('Bags'));
    await tester.tapVisible(find.text('Nomad Daypack 22L'));
    expect(find.text('Colour: Charcoal'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Olive'));
    await tester.pumpAndSettle();
    expect(find.text('Colour: Olive'), findsOneWidget);

    await tester.tap(find.textContaining('Add to bag'));
    await tester.pumpAndSettle();
    expect(find.text('Nomad Daypack 22L added to your bag'), findsOneWidget);

    await tester.tap(find.text('View bag'));
    await tester.pumpAndSettle();
    expect(find.text('Your bag'), findsOneWidget);
    expect(find.text('Olive'), findsOneWidget);
    expect(find.text("You've unlocked free shipping"), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'nope');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text("That code isn't valid"), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'SAVE10');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('Discount (SAVE10)'), findsOneWidget);

    await tester.tapVisible(find.text('Checkout'));

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsWidgets);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Street address'),
      '1 Analytical Way',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'City'),
      'Lisbon',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Postal code'),
      '1000',
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Express'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Card number'),
      '4000000000000002',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name on card'),
      'Ada Lovelace',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Expiry (MM/YY)'),
      '1299',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'CVV'), '123');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Visa •••• 0002'), findsOneWidget);
    await tester.tap(find.textContaining('Place order'));
    await tester.pumpAndSettle();
    expect(
      find.text('Your card was declined. Try another card.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Edit').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Card number'),
      '4242424242424242',
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Place order'));
    await tester.pumpAndSettle();

    expect(find.text('Order confirmed!'), findsOneWidget);
    await tester.tap(find.text('Track order'));
    await tester.pumpAndSettle();
    expect(find.text('Order placed'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Paid with card ending 4242'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('1 × Nomad Daypack 22L'), findsOneWidget);

    // Leave the tracking page so its ticker stops before the test ends.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('every tab and secondary screen renders', (tester) async {
    await tester.pumpPlume(store: onboardedStore());

    for (final tab in ['Search', 'Wishlist', 'Bag', 'Profile', 'Discover']) {
      await tester.tap(_tab(tab));
      await tester.pumpAndSettle();
    }

    await tester.tap(_tab('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'zzzz');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Nothing matches'), findsOneWidget);

    await tester.tap(_tab('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(find.text('Ajustes'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('App updates'));
    await tester.pumpAndSettle();
    expect(find.text('Updates unavailable in this build'), findsOneWidget);
    expect(find.text('1.0.0 (1)'), findsOneWidget);
  });

  testWidgets('a patch can be installed from the update banner', (
    tester,
  ) async {
    final updater = MockUpdater();
    when(() => updater.isAvailable).thenReturn(true);
    when(updater.readCurrentPatch).thenAnswer((_) async => null);
    when(updater.readNextPatch).thenAnswer((_) async => null);
    when(updater.checkForUpdate).thenAnswer((_) async => UpdateStatus.outdated);
    when(updater.update).thenAnswer((_) async {
      when(updater.readNextPatch)
          .thenAnswer((_) async => const Patch(number: 1));
    });

    await tester.pumpPlume(store: onboardedStore(), updater: updater);
    expect(find.text('Update available'), findsOneWidget);

    await tester.tap(find.text('Install'));
    await tester.pumpAndSettle();
    expect(find.text('Restart to update'), findsWidgets);

    await tester.tap(find.text('Restart').first);
    await tester.pumpAndSettle();
    expect(find.text('Restart Plume'), findsOneWidget);
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Restart to update').first);
    await tester.pumpAndSettle();
    expect(find.text('On next launch'), findsOneWidget);
    expect(find.text('Patch #1'), findsOneWidget);
  });

  testWidgets('wishlist saves products from a card', (tester) async {
    await tester.pumpPlume(store: onboardedStore());
    await tester.scrollUntilVisible(
      find.text('Trending now'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    final card = find.byType(ProductCard).first;
    await tester.tap(
      find.descendant(of: card, matching: find.byType(WishlistButton)),
    );
    await tester.pumpAndSettle();
    await tester.tap(_tab('Wishlist'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductCard), findsOneWidget);
  });

  testWidgets('a deep link survives the onboarding gate', (tester) async {
    await tester.pumpPlume(store: InMemoryStore(), initialLocation: '/orders');
    expect(find.text("Gear you'll love"), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('No orders yet'), findsOneWidget);
  });
}
