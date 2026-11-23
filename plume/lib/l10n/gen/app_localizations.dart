import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Plume'**
  String get appName;

  /// No description provided for @tabDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get tabDiscover;

  /// No description provided for @tabSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tabSearch;

  /// No description provided for @tabWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get tabWishlist;

  /// No description provided for @tabCart.
  ///
  /// In en, this message translates to:
  /// **'Bag'**
  String get tabCart;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t reach the store. Check your connection and try again.'**
  String get errorMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Gear you\'ll love'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Audio, wearables and everyday carry, picked by people who use them.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Checkout in seconds'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Saved addresses, smart promo codes and one-tap payment.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Track every step'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Live order tracking from our warehouse to your door.'**
  String get onboardingBody3;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String greetingMorning(String name);

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String greetingAfternoon(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String greetingEvening(String name);

  /// No description provided for @discoverHeadline.
  ///
  /// In en, this message translates to:
  /// **'Find your next favourite'**
  String get discoverHeadline;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products, brands…'**
  String get searchHint;

  /// No description provided for @collectionLabel.
  ///
  /// In en, this message translates to:
  /// **'COLLECTION'**
  String get collectionLabel;

  /// No description provided for @shopNow.
  ///
  /// In en, this message translates to:
  /// **'Shop now'**
  String get shopNow;

  /// No description provided for @promoSave10.
  ///
  /// In en, this message translates to:
  /// **'\$10 off orders over \$50'**
  String get promoSave10;

  /// No description provided for @promoUseCode.
  ///
  /// In en, this message translates to:
  /// **'Use code {code} at checkout'**
  String promoUseCode(String code);

  /// No description provided for @promoCopied.
  ///
  /// In en, this message translates to:
  /// **'{code} copied to clipboard'**
  String promoCopied(String code);

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCode;

  /// No description provided for @shopByCategory.
  ///
  /// In en, this message translates to:
  /// **'Shop by category'**
  String get shopByCategory;

  /// No description provided for @trendingNow.
  ///
  /// In en, this message translates to:
  /// **'Trending now'**
  String get trendingNow;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @dealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get dealsTitle;

  /// No description provided for @newArrivals.
  ///
  /// In en, this message translates to:
  /// **'New & bestselling'**
  String get newArrivals;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// No description provided for @addToWishlist.
  ///
  /// In en, this message translates to:
  /// **'Save to wishlist'**
  String get addToWishlist;

  /// No description provided for @removeFromWishlist.
  ///
  /// In en, this message translates to:
  /// **'Remove from wishlist'**
  String get removeFromWishlist;

  /// No description provided for @percentOff.
  ///
  /// In en, this message translates to:
  /// **'{percent}% OFF'**
  String percentOff(int percent);

  /// No description provided for @badgeNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get badgeNew;

  /// No description provided for @decreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get decreaseQuantity;

  /// No description provided for @increaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get increaseQuantity;

  /// No description provided for @productNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Product unavailable'**
  String get productNotFoundTitle;

  /// No description provided for @productNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This product is no longer in our catalog.'**
  String get productNotFoundMessage;

  /// No description provided for @backToShop.
  ///
  /// In en, this message translates to:
  /// **'Back to shop'**
  String get backToShop;

  /// No description provided for @dragToTilt.
  ///
  /// In en, this message translates to:
  /// **'Drag to tilt'**
  String get dragToTilt;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Colour: {name}'**
  String colorLabel(String name);

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @readLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get readLess;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTitle;

  /// No description provided for @reviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 review} other{{count} reviews}}'**
  String reviewCount(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{yesterday} other{{days} days ago}}'**
  String daysAgo(int days);

  /// No description provided for @youMayAlsoLike.
  ///
  /// In en, this message translates to:
  /// **'You may also like'**
  String get youMayAlsoLike;

  /// No description provided for @freeShippingOver75.
  ///
  /// In en, this message translates to:
  /// **'Free standard shipping on orders over \$75'**
  String get freeShippingOver75;

  /// No description provided for @freeReturns.
  ///
  /// In en, this message translates to:
  /// **'Free 30-day returns'**
  String get freeReturns;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In stock, ships today'**
  String get inStock;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Only {count} left'**
  String lowStock(int count);

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'{name} added to your bag'**
  String addedToCart(String name);

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View bag'**
  String get viewCart;

  /// No description provided for @addToCartWithPrice.
  ///
  /// In en, this message translates to:
  /// **'Add to bag · {price}'**
  String addToCartWithPrice(String price);

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// No description provided for @resultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{1 result} other{{count} results}}'**
  String resultCount(int count);

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches'**
  String get noResultsTitle;

  /// No description provided for @noResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or loosen your filters.'**
  String get noResultsMessage;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @maxPrice.
  ///
  /// In en, this message translates to:
  /// **'Max price'**
  String get maxPrice;

  /// No description provided for @anyPrice.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get anyPrice;

  /// No description provided for @onSaleOnly.
  ///
  /// In en, this message translates to:
  /// **'On sale only'**
  String get onSaleOnly;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get sortFeatured;

  /// No description provided for @sortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get sortPriceLow;

  /// No description provided for @sortPriceHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get sortPriceHigh;

  /// No description provided for @sortRating.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get sortRating;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get applyFilters;

  /// No description provided for @wishlistEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get wishlistEmptyTitle;

  /// No description provided for @wishlistEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on anything you like and it\'ll wait for you here.'**
  String get wishlistEmptyMessage;

  /// No description provided for @startShopping.
  ///
  /// In en, this message translates to:
  /// **'Start shopping'**
  String get startShopping;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Your bag'**
  String get cartTitle;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your bag is empty'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Good things are waiting. Let\'s find something you\'ll love.'**
  String get cartEmptyMessage;

  /// No description provided for @freeShippingUnlocked.
  ///
  /// In en, this message translates to:
  /// **'You\'ve unlocked free shipping'**
  String get freeShippingUnlocked;

  /// No description provided for @freeShippingRemaining.
  ///
  /// In en, this message translates to:
  /// **'Add {amount} more for free shipping'**
  String freeShippingRemaining(String amount);

  /// No description provided for @removedFromCart.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String removedFromCart(String name);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @promoTitle.
  ///
  /// In en, this message translates to:
  /// **'Promo code'**
  String get promoTitle;

  /// No description provided for @promoHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a code, e.g. SAVE10'**
  String get promoHint;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @promoInvalid.
  ///
  /// In en, this message translates to:
  /// **'That code isn\'t valid'**
  String get promoInvalid;

  /// No description provided for @promoShortfall.
  ///
  /// In en, this message translates to:
  /// **'Add {amount} more to use this code'**
  String promoShortfall(String amount);

  /// No description provided for @removePromo.
  ///
  /// In en, this message translates to:
  /// **'Remove code'**
  String get removePromo;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @discountWithCode.
  ///
  /// In en, this message translates to:
  /// **'Discount ({code})'**
  String discountWithCode(String code);

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @estimatedTax.
  ///
  /// In en, this message translates to:
  /// **'Estimated tax ({rate}%)'**
  String estimatedTax(int rate);

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @stepAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get stepAddress;

  /// No description provided for @stepDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get stepDelivery;

  /// No description provided for @stepPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get stepPayment;

  /// No description provided for @stepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get stepReview;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order · {total}'**
  String placeOrder(String total);

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @addressLine1.
  ///
  /// In en, this message translates to:
  /// **'Street address'**
  String get addressLine1;

  /// No description provided for @addressLine2.
  ///
  /// In en, this message translates to:
  /// **'Apartment, suite (optional)'**
  String get addressLine2;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get postalCode;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @shippingStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get shippingStandard;

  /// No description provided for @shippingExpress.
  ///
  /// In en, this message translates to:
  /// **'Express'**
  String get shippingExpress;

  /// No description provided for @arrivesBy.
  ///
  /// In en, this message translates to:
  /// **'Arrives by {date}'**
  String arrivesBy(String date);

  /// No description provided for @standardShippingPrice.
  ///
  /// In en, this message translates to:
  /// **'{price}\nFree over \$75'**
  String standardShippingPrice(String price);

  /// No description provided for @businessDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 business day} other{{days} business days}}'**
  String businessDays(int days);

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get cardNumber;

  /// No description provided for @cardNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Check the card number'**
  String get cardNumberInvalid;

  /// No description provided for @cardHolder.
  ///
  /// In en, this message translates to:
  /// **'Name on card'**
  String get cardHolder;

  /// No description provided for @expiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry (MM/YY)'**
  String get expiry;

  /// No description provided for @expiryInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a future date'**
  String get expiryInvalid;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @cvvInvalid.
  ///
  /// In en, this message translates to:
  /// **'3 or 4 digits'**
  String get cvvInvalid;

  /// No description provided for @testCardHint.
  ///
  /// In en, this message translates to:
  /// **'Test mode. Use 4242 4242 4242 4242. Cards ending in 0002 are declined.'**
  String get testCardHint;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @processingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing payment…'**
  String get processingPayment;

  /// No description provided for @paymentDeclined.
  ///
  /// In en, this message translates to:
  /// **'Your card was declined. Try another card.'**
  String get paymentDeclined;

  /// No description provided for @orderConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed!'**
  String get orderConfirmedTitle;

  /// No description provided for @orderConfirmedMessage.
  ///
  /// In en, this message translates to:
  /// **'Order {id} is on its way. It should arrive by {date}.'**
  String orderConfirmedMessage(String id, String date);

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track order'**
  String get trackOrder;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue shopping'**
  String get continueShopping;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @ordersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmptyTitle;

  /// No description provided for @ordersEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'When you place an order, you can track it here.'**
  String get ordersEmptyMessage;

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get orderNotFound;

  /// No description provided for @statusPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get statusPlaced;

  /// No description provided for @statusPacked.
  ///
  /// In en, this message translates to:
  /// **'Packed'**
  String get statusPacked;

  /// No description provided for @statusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get statusShipped;

  /// No description provided for @statusOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery'**
  String get statusOutForDelivery;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @estimatedDelivery.
  ///
  /// In en, this message translates to:
  /// **'Estimated delivery {date}'**
  String estimatedDelivery(String date);

  /// No description provided for @deliveringTo.
  ///
  /// In en, this message translates to:
  /// **'Delivering to'**
  String get deliveringTo;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @paidWith.
  ///
  /// In en, this message translates to:
  /// **'Paid with card ending {last4}'**
  String paidWith(String last4);

  /// No description provided for @statOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get statOrders;

  /// No description provided for @statSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get statSaved;

  /// No description provided for @statSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get statSpent;

  /// No description provided for @recentOrder.
  ///
  /// In en, this message translates to:
  /// **'Recent order'**
  String get recentOrder;

  /// No description provided for @updatesTitle.
  ///
  /// In en, this message translates to:
  /// **'App updates'**
  String get updatesTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @badgeNewUpdate.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get badgeNewUpdate;

  /// No description provided for @noPatch.
  ///
  /// In en, this message translates to:
  /// **'No patch'**
  String get noPatch;

  /// No description provided for @patchNumber.
  ///
  /// In en, this message translates to:
  /// **'Patch #{number}'**
  String patchNumber(int number);

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @orderUpdates.
  ///
  /// In en, this message translates to:
  /// **'Order updates'**
  String get orderUpdates;

  /// No description provided for @orderUpdatesBody.
  ///
  /// In en, this message translates to:
  /// **'Shipping and delivery alerts'**
  String get orderUpdatesBody;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @offersBody.
  ///
  /// In en, this message translates to:
  /// **'Promo codes and new arrivals'**
  String get offersBody;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @simulateOffline.
  ///
  /// In en, this message translates to:
  /// **'Simulate a network error'**
  String get simulateOffline;

  /// No description provided for @simulateOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'The next request to the store fails, so you can see error states.'**
  String get simulateOfflineBody;

  /// No description provided for @simulateOfflineArmed.
  ///
  /// In en, this message translates to:
  /// **'The next request will fail. Pull to refresh on Discover to see it.'**
  String get simulateOfflineArmed;

  /// No description provided for @madeWithShorebird.
  ///
  /// In en, this message translates to:
  /// **'Plume · Updated over the air with Shorebird'**
  String get madeWithShorebird;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @install.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'A new version of Plume is ready to download.'**
  String get updateAvailableBody;

  /// No description provided for @updateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading update…'**
  String get updateDownloading;

  /// No description provided for @updateDownloadingBody.
  ///
  /// In en, this message translates to:
  /// **'This only takes a few seconds.'**
  String get updateDownloadingBody;

  /// No description provided for @updateReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart to update'**
  String get updateReadyTitle;

  /// No description provided for @updateReadyBody.
  ///
  /// In en, this message translates to:
  /// **'The update is installed. Close and reopen Plume to use it.'**
  String get updateReadyBody;

  /// No description provided for @updateChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates…'**
  String get updateChecking;

  /// No description provided for @updateCheckingBody.
  ///
  /// In en, this message translates to:
  /// **'Asking Shorebird for the latest patch.'**
  String get updateCheckingBody;

  /// No description provided for @upToDateTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re up to date'**
  String get upToDateTitle;

  /// No description provided for @upToDateBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re running the latest version.'**
  String get upToDateBody;

  /// No description provided for @lastChecked.
  ///
  /// In en, this message translates to:
  /// **'Last checked at {time}'**
  String lastChecked(String time);

  /// No description provided for @updateFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailedTitle;

  /// No description provided for @updateFailedBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t download the update. Check your connection and try again.'**
  String get updateFailedBody;

  /// No description provided for @updaterUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Updates unavailable in this build'**
  String get updaterUnavailableTitle;

  /// No description provided for @updaterUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Build with `shorebird release` or `shorebird preview` to enable over-the-air updates. Debug builds and `flutter run` don\'t include the Shorebird updater.'**
  String get updaterUnavailableBody;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @releaseVersion.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get releaseVersion;

  /// No description provided for @runningPatch.
  ///
  /// In en, this message translates to:
  /// **'Running patch'**
  String get runningPatch;

  /// No description provided for @nextLaunchPatch.
  ///
  /// In en, this message translates to:
  /// **'On next launch'**
  String get nextLaunchPatch;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How over-the-air updates work'**
  String get howItWorks;

  /// No description provided for @howStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get howStep1Title;

  /// No description provided for @howStep1Body.
  ///
  /// In en, this message translates to:
  /// **'`shorebird release` builds the app that goes to the stores.'**
  String get howStep1Body;

  /// No description provided for @howStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Patch'**
  String get howStep2Title;

  /// No description provided for @howStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Fix a bug in Dart, then run `shorebird patch`. No store review.'**
  String get howStep2Body;

  /// No description provided for @howStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get howStep3Title;

  /// No description provided for @howStep3Body.
  ///
  /// In en, this message translates to:
  /// **'The app downloads the patch and runs it on the next launch.'**
  String get howStep3Body;

  /// No description provided for @restartTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart Plume'**
  String get restartTitle;

  /// No description provided for @restartBody.
  ///
  /// In en, this message translates to:
  /// **'The update runs the next time Plume starts.'**
  String get restartBody;

  /// No description provided for @restartStep1.
  ///
  /// In en, this message translates to:
  /// **'Open the app switcher'**
  String get restartStep1;

  /// No description provided for @restartStep2.
  ///
  /// In en, this message translates to:
  /// **'Swipe Plume away to close it'**
  String get restartStep2;

  /// No description provided for @restartStep3.
  ///
  /// In en, this message translates to:
  /// **'Tap Plume to open it again'**
  String get restartStep3;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
