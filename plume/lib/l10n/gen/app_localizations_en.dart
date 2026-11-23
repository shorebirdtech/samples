// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Plume';

  @override
  String get tabDiscover => 'Discover';

  @override
  String get tabSearch => 'Search';

  @override
  String get tabWishlist => 'Wishlist';

  @override
  String get tabCart => 'Bag';

  @override
  String get tabProfile => 'Profile';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorMessage =>
      'We couldn\'t reach the store. Check your connection and try again.';

  @override
  String get retry => 'Try again';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get started';

  @override
  String get onboardingTitle1 => 'Gear you\'ll love';

  @override
  String get onboardingBody1 =>
      'Audio, wearables and everyday carry, picked by people who use them.';

  @override
  String get onboardingTitle2 => 'Checkout in seconds';

  @override
  String get onboardingBody2 =>
      'Saved addresses, smart promo codes and one-tap payment.';

  @override
  String get onboardingTitle3 => 'Track every step';

  @override
  String get onboardingBody3 =>
      'Live order tracking from our warehouse to your door.';

  @override
  String greetingMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String get discoverHeadline => 'Find your next favourite';

  @override
  String get searchHint => 'Search products, brands…';

  @override
  String get collectionLabel => 'COLLECTION';

  @override
  String get shopNow => 'Shop now';

  @override
  String get promoSave10 => '\$10 off orders over \$50';

  @override
  String promoUseCode(String code) {
    return 'Use code $code at checkout';
  }

  @override
  String promoCopied(String code) {
    return '$code copied to clipboard';
  }

  @override
  String get copyCode => 'Copy code';

  @override
  String get shopByCategory => 'Shop by category';

  @override
  String get trendingNow => 'Trending now';

  @override
  String get seeAll => 'See all';

  @override
  String get dealsTitle => 'Deals';

  @override
  String get newArrivals => 'New & bestselling';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get addToWishlist => 'Save to wishlist';

  @override
  String get removeFromWishlist => 'Remove from wishlist';

  @override
  String percentOff(int percent) {
    return '$percent% OFF';
  }

  @override
  String get badgeNew => 'NEW';

  @override
  String get decreaseQuantity => 'Decrease quantity';

  @override
  String get increaseQuantity => 'Increase quantity';

  @override
  String get productNotFoundTitle => 'Product unavailable';

  @override
  String get productNotFoundMessage =>
      'This product is no longer in our catalog.';

  @override
  String get backToShop => 'Back to shop';

  @override
  String get dragToTilt => 'Drag to tilt';

  @override
  String colorLabel(String name) {
    return 'Colour: $name';
  }

  @override
  String get readMore => 'Read more';

  @override
  String get readLess => 'Show less';

  @override
  String get reviewsTitle => 'Reviews';

  @override
  String reviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: 'yesterday',
    );
    return '$_temp0';
  }

  @override
  String get youMayAlsoLike => 'You may also like';

  @override
  String get freeShippingOver75 => 'Free standard shipping on orders over \$75';

  @override
  String get freeReturns => 'Free 30-day returns';

  @override
  String get inStock => 'In stock, ships today';

  @override
  String lowStock(int count) {
    return 'Only $count left';
  }

  @override
  String addedToCart(String name) {
    return '$name added to your bag';
  }

  @override
  String get viewCart => 'View bag';

  @override
  String addToCartWithPrice(String price) {
    return 'Add to bag · $price';
  }

  @override
  String get clear => 'Clear';

  @override
  String get filters => 'Filters';

  @override
  String get allCategories => 'All';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get noResultsTitle => 'Nothing matches';

  @override
  String get noResultsMessage =>
      'Try a different search or loosen your filters.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get maxPrice => 'Max price';

  @override
  String get anyPrice => 'Any';

  @override
  String get onSaleOnly => 'On sale only';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortFeatured => 'Featured';

  @override
  String get sortPriceLow => 'Price: low to high';

  @override
  String get sortPriceHigh => 'Price: high to low';

  @override
  String get sortRating => 'Top rated';

  @override
  String get reset => 'Reset';

  @override
  String get applyFilters => 'Show results';

  @override
  String get wishlistEmptyTitle => 'Nothing saved yet';

  @override
  String get wishlistEmptyMessage =>
      'Tap the heart on anything you like and it\'ll wait for you here.';

  @override
  String get startShopping => 'Start shopping';

  @override
  String get cartTitle => 'Your bag';

  @override
  String get cartEmptyTitle => 'Your bag is empty';

  @override
  String get cartEmptyMessage =>
      'Good things are waiting. Let\'s find something you\'ll love.';

  @override
  String get freeShippingUnlocked => 'You\'ve unlocked free shipping';

  @override
  String freeShippingRemaining(String amount) {
    return 'Add $amount more for free shipping';
  }

  @override
  String removedFromCart(String name) {
    return '$name removed';
  }

  @override
  String get undo => 'Undo';

  @override
  String get remove => 'Remove';

  @override
  String get promoTitle => 'Promo code';

  @override
  String get promoHint => 'Enter a code, e.g. SAVE10';

  @override
  String get apply => 'Apply';

  @override
  String get promoInvalid => 'That code isn\'t valid';

  @override
  String promoShortfall(String amount) {
    return 'Add $amount more to use this code';
  }

  @override
  String get removePromo => 'Remove code';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Discount';

  @override
  String discountWithCode(String code) {
    return 'Discount ($code)';
  }

  @override
  String get shipping => 'Shipping';

  @override
  String get free => 'Free';

  @override
  String estimatedTax(int rate) {
    return 'Estimated tax ($rate%)';
  }

  @override
  String get total => 'Total';

  @override
  String get checkout => 'Checkout';

  @override
  String get stepAddress => 'Address';

  @override
  String get stepDelivery => 'Delivery';

  @override
  String get stepPayment => 'Payment';

  @override
  String get stepReview => 'Review';

  @override
  String get continueLabel => 'Continue';

  @override
  String placeOrder(String total) {
    return 'Place order · $total';
  }

  @override
  String get fieldRequired => 'Required';

  @override
  String get fullName => 'Full name';

  @override
  String get addressLine1 => 'Street address';

  @override
  String get addressLine2 => 'Apartment, suite (optional)';

  @override
  String get city => 'City';

  @override
  String get postalCode => 'Postal code';

  @override
  String get country => 'Country';

  @override
  String get shippingStandard => 'Standard';

  @override
  String get shippingExpress => 'Express';

  @override
  String arrivesBy(String date) {
    return 'Arrives by $date';
  }

  @override
  String standardShippingPrice(String price) {
    return '$price\nFree over \$75';
  }

  @override
  String businessDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days business days',
      one: '1 business day',
    );
    return '$_temp0';
  }

  @override
  String get cardNumber => 'Card number';

  @override
  String get cardNumberInvalid => 'Check the card number';

  @override
  String get cardHolder => 'Name on card';

  @override
  String get expiry => 'Expiry (MM/YY)';

  @override
  String get expiryInvalid => 'Enter a future date';

  @override
  String get cvv => 'CVV';

  @override
  String get cvvInvalid => '3 or 4 digits';

  @override
  String get testCardHint =>
      'Test mode. Use 4242 4242 4242 4242. Cards ending in 0002 are declined.';

  @override
  String get edit => 'Edit';

  @override
  String get processingPayment => 'Processing payment…';

  @override
  String get paymentDeclined => 'Your card was declined. Try another card.';

  @override
  String get orderConfirmedTitle => 'Order confirmed!';

  @override
  String orderConfirmedMessage(String id, String date) {
    return 'Order $id is on its way. It should arrive by $date.';
  }

  @override
  String get trackOrder => 'Track order';

  @override
  String get continueShopping => 'Continue shopping';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get ordersEmptyTitle => 'No orders yet';

  @override
  String get ordersEmptyMessage =>
      'When you place an order, you can track it here.';

  @override
  String get orderNotFound => 'Order not found';

  @override
  String get statusPlaced => 'Order placed';

  @override
  String get statusPacked => 'Packed';

  @override
  String get statusShipped => 'Shipped';

  @override
  String get statusOutForDelivery => 'Out for delivery';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String estimatedDelivery(String date) {
    return 'Estimated delivery $date';
  }

  @override
  String get deliveringTo => 'Delivering to';

  @override
  String get receipt => 'Receipt';

  @override
  String paidWith(String last4) {
    return 'Paid with card ending $last4';
  }

  @override
  String get statOrders => 'Orders';

  @override
  String get statSaved => 'Saved';

  @override
  String get statSpent => 'Spent';

  @override
  String get recentOrder => 'Recent order';

  @override
  String get updatesTitle => 'App updates';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get badgeNewUpdate => 'New';

  @override
  String get noPatch => 'No patch';

  @override
  String patchNumber(int number) {
    return 'Patch #$number';
  }

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get notifications => 'Notifications';

  @override
  String get orderUpdates => 'Order updates';

  @override
  String get orderUpdatesBody => 'Shipping and delivery alerts';

  @override
  String get offers => 'Offers';

  @override
  String get offersBody => 'Promo codes and new arrivals';

  @override
  String get developer => 'Developer';

  @override
  String get simulateOffline => 'Simulate a network error';

  @override
  String get simulateOfflineBody =>
      'The next request to the store fails, so you can see error states.';

  @override
  String get simulateOfflineArmed =>
      'The next request will fail. Pull to refresh on Discover to see it.';

  @override
  String get madeWithShorebird => 'Plume · Updated over the air with Shorebird';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get install => 'Install';

  @override
  String get restart => 'Restart';

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String get updateAvailableBody =>
      'A new version of Plume is ready to download.';

  @override
  String get updateDownloading => 'Downloading update…';

  @override
  String get updateDownloadingBody => 'This only takes a few seconds.';

  @override
  String get updateReadyTitle => 'Restart to update';

  @override
  String get updateReadyBody =>
      'The update is installed. Close and reopen Plume to use it.';

  @override
  String get updateChecking => 'Checking for updates…';

  @override
  String get updateCheckingBody => 'Asking Shorebird for the latest patch.';

  @override
  String get upToDateTitle => 'You\'re up to date';

  @override
  String get upToDateBody => 'You\'re running the latest version.';

  @override
  String lastChecked(String time) {
    return 'Last checked at $time';
  }

  @override
  String get updateFailedTitle => 'Update failed';

  @override
  String get updateFailedBody =>
      'We couldn\'t download the update. Check your connection and try again.';

  @override
  String get updaterUnavailableTitle => 'Updates unavailable in this build';

  @override
  String get updaterUnavailableBody =>
      'Build with `shorebird release` or `shorebird preview` to enable over-the-air updates. Debug builds and `flutter run` don\'t include the Shorebird updater.';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get releaseVersion => 'Release';

  @override
  String get runningPatch => 'Running patch';

  @override
  String get nextLaunchPatch => 'On next launch';

  @override
  String get howItWorks => 'How over-the-air updates work';

  @override
  String get howStep1Title => 'Release';

  @override
  String get howStep1Body =>
      '`shorebird release` builds the app that goes to the stores.';

  @override
  String get howStep2Title => 'Patch';

  @override
  String get howStep2Body =>
      'Fix a bug in Dart, then run `shorebird patch`. No store review.';

  @override
  String get howStep3Title => 'Update';

  @override
  String get howStep3Body =>
      'The app downloads the patch and runs it on the next launch.';

  @override
  String get restartTitle => 'Restart Plume';

  @override
  String get restartBody => 'The update runs the next time Plume starts.';

  @override
  String get restartStep1 => 'Open the app switcher';

  @override
  String get restartStep2 => 'Swipe Plume away to close it';

  @override
  String get restartStep3 => 'Tap Plume to open it again';

  @override
  String get gotIt => 'Got it';
}
