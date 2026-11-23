# Plume demo script

Release 1.0.0 of Plume ships with a real checkout bug. This script shows it
to an audience, fixes it, and delivers the fix with a Shorebird patch, all in
about five minutes and without an app store review.

It works the same on stage and on a client call (share your phone screen with
QuickTime on iOS or `scrcpy` on Android).

## The bug

Marketing is running a `SAVE10` campaign: **$10 off orders over $50**. The
banner on Discover advertises it. When a customer applies the code, the bag
takes off **$0.10** instead of $10.

The promotions service sends fixed amounts in dollars (`"amount": 10`), but
the app stores money in cents. `PriceCalculator` converts the minimum order
correctly and forgets to convert the discount:

```dart
// lib/features/cart/domain/price_calculator.dart
final minimum = Money.fromMajor(promotion.minSubtotal); // dollars -> cents ✅
...
case PromotionKind.fixed:
  discount = Money.cents(promotion.amount.toInt());     // 10 cents ❌
```

Percentage codes (`WELCOME15`) and `FREESHIP` work. Only the campaign
everyone is using is broken, which is what makes it a good demo: a bug like
this costs real money, and nobody wants to wait days for a store review to
fix it.

## One-time setup

1. Install the [Shorebird CLI](https://docs.shorebird.dev/getting-started/)
   and run `shorebird login`.
2. From this directory, create the Shorebird app:

   ```sh
   shorebird init
   ```

   This adds `shorebird.yaml` (with your `app_id`) and lists it under
   `flutter: assets:` in `pubspec.yaml`.
3. In `shorebird.yaml`, turn off background updates so the in-app banner
   drives the update where the audience can see it:

   ```yaml
   auto_update: false
   ```

4. Create the release (the one with the bug) and install it on your device:

   ```sh
   shorebird release android   # or: shorebird release ios
   shorebird preview           # installs the release on a connected device
   ```

## Running the demo

**1. Show the app.** Swipe through onboarding to Discover. There's no
sign-in, so you're straight into the store. Show off Discover: the carousel,
the tilting product art, the wishlist heart and the add-to-bag animation.
Mention that this is a real release build, the same
binary you would ship to the stores.

**2. Hit the bug.** Tap the `SAVE10` banner to copy the code, open
**Nomad Daypack 22L** ($129) and add it to the bag. In the bag, paste
`SAVE10` and tap **Apply**. The summary shows:

```
Discount (SAVE10)   −$0.10
```

Ask the audience how long this fix would take to reach customers without
Shorebird.

**3. Fix it.** Search the project for `TODO(Demo)`. In
`lib/features/cart/domain/price_calculator.dart`:

```diff
           case PromotionKind.fixed:
-            discount = Money.cents(promotion.amount.toInt());
+            discount = Money.fromMajor(promotion.amount);
```

Optionally, prove the fix: in
`test/features/cart/price_calculator_test.dart`, delete the `skip:` line on
`fixed promotions take their amount in dollars`, then run `flutter test`.

**4. Patch.** Ship the fix:

```sh
shorebird patch android
```

**5. Update on the device.** Bring Plume back to the foreground (or open
**Profile → App updates** and tap **Check for updates**). The banner slides in
with **Update available**. Tap **Install**, then **Restart** and follow the
steps: close Plume from the app switcher and reopen it.

**6. Show the fix.** App updates now shows **Running patch: Patch #1**, and
the bag (it kept your items) shows:

```
Discount (SAVE10)   −$10.00
```

Point out that only the Dart code changed and the app store was never
involved.

## Repeating the demo

The patch goes to every install of release 1.0.0+1. To show the bug again:

1. Roll the patch back in the [Shorebird console](https://console.shorebird.dev).
   Otherwise a fresh install downloads it again.
2. Uninstall Plume from the phone. This clears the downloaded patch.
3. Reinstall the release. A copy of the release APK is on the phone: open
   **Files → Downloads → plume-1.0.0+1.apk** and tap **Install**. From a Mac,
   `shorebird preview` does the same.
4. Undo the fix in your working copy, so the next patch you make is the fix
   again.

## Extra beats

- **Payment errors:** at checkout, the card `4000 0000 0000 0002` is
  declined. `4242 4242 4242 4242` succeeds.
- **Live tracking:** after placing an order, **Track order** shows the
  courier moving. Each status lasts 45 seconds, so it arrives in about
  three minutes.
- **Error states:** Settings → Developer → **Simulate a network error**,
  then pull to refresh on Discover.
- **Localisation:** Settings → Language → Español. A copy fix is another
  easy patch to demo.
