// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Plume';

  @override
  String get tabDiscover => 'Descubrir';

  @override
  String get tabSearch => 'Buscar';

  @override
  String get tabWishlist => 'Favoritos';

  @override
  String get tabCart => 'Bolsa';

  @override
  String get tabProfile => 'Perfil';

  @override
  String get errorTitle => 'Algo salió mal';

  @override
  String get errorMessage =>
      'No pudimos conectar con la tienda. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get retry => 'Reintentar';

  @override
  String get skip => 'Omitir';

  @override
  String get next => 'Siguiente';

  @override
  String get getStarted => 'Empezar';

  @override
  String get onboardingTitle1 => 'Equipo que te encantará';

  @override
  String get onboardingBody1 =>
      'Audio, wearables y accesorios elegidos por quienes los usan.';

  @override
  String get onboardingTitle2 => 'Paga en segundos';

  @override
  String get onboardingBody2 =>
      'Direcciones guardadas, códigos promocionales y pago en un toque.';

  @override
  String get onboardingTitle3 => 'Sigue cada paso';

  @override
  String get onboardingBody3 =>
      'Seguimiento en vivo desde nuestro almacén hasta tu puerta.';

  @override
  String greetingMorning(String name) {
    return 'Buenos días, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Buenas tardes, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Buenas noches, $name';
  }

  @override
  String get discoverHeadline => 'Encuentra tu próximo favorito';

  @override
  String get searchHint => 'Buscar productos, marcas…';

  @override
  String get collectionLabel => 'COLECCIÓN';

  @override
  String get shopNow => 'Comprar';

  @override
  String get promoSave10 => '\$10 de descuento en pedidos de más de \$50';

  @override
  String promoUseCode(String code) {
    return 'Usa el código $code al pagar';
  }

  @override
  String promoCopied(String code) {
    return '$code copiado al portapapeles';
  }

  @override
  String get copyCode => 'Copiar código';

  @override
  String get shopByCategory => 'Comprar por categoría';

  @override
  String get trendingNow => 'Tendencias';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get dealsTitle => 'Ofertas';

  @override
  String get newArrivals => 'Novedades y más vendidos';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos',
      one: '1 artículo',
    );
    return '$_temp0';
  }

  @override
  String get addToWishlist => 'Guardar en favoritos';

  @override
  String get removeFromWishlist => 'Quitar de favoritos';

  @override
  String percentOff(int percent) {
    return '$percent% DTO';
  }

  @override
  String get badgeNew => 'NUEVO';

  @override
  String get decreaseQuantity => 'Reducir cantidad';

  @override
  String get increaseQuantity => 'Aumentar cantidad';

  @override
  String get productNotFoundTitle => 'Producto no disponible';

  @override
  String get productNotFoundMessage =>
      'Este producto ya no está en nuestro catálogo.';

  @override
  String get backToShop => 'Volver a la tienda';

  @override
  String get dragToTilt => 'Arrastra para inclinar';

  @override
  String colorLabel(String name) {
    return 'Color: $name';
  }

  @override
  String get readMore => 'Leer más';

  @override
  String get readLess => 'Mostrar menos';

  @override
  String get reviewsTitle => 'Reseñas';

  @override
  String reviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reseñas',
      one: '1 reseña',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'hace $days días',
      one: 'ayer',
    );
    return '$_temp0';
  }

  @override
  String get youMayAlsoLike => 'También te puede gustar';

  @override
  String get freeShippingOver75 =>
      'Envío estándar gratis en pedidos de más de \$75';

  @override
  String get freeReturns => 'Devoluciones gratis durante 30 días';

  @override
  String get inStock => 'En stock, se envía hoy';

  @override
  String lowStock(int count) {
    return 'Solo quedan $count';
  }

  @override
  String addedToCart(String name) {
    return '$name añadido a tu bolsa';
  }

  @override
  String get viewCart => 'Ver bolsa';

  @override
  String addToCartWithPrice(String price) {
    return 'Añadir · $price';
  }

  @override
  String get clear => 'Borrar';

  @override
  String get filters => 'Filtros';

  @override
  String get allCategories => 'Todo';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
      zero: 'Sin resultados',
    );
    return '$_temp0';
  }

  @override
  String get noResultsTitle => 'Sin coincidencias';

  @override
  String get noResultsMessage => 'Prueba otra búsqueda o ajusta los filtros.';

  @override
  String get clearFilters => 'Quitar filtros';

  @override
  String get maxPrice => 'Precio máximo';

  @override
  String get anyPrice => 'Cualquiera';

  @override
  String get onSaleOnly => 'Solo ofertas';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get sortFeatured => 'Destacados';

  @override
  String get sortPriceLow => 'Precio: menor a mayor';

  @override
  String get sortPriceHigh => 'Precio: mayor a menor';

  @override
  String get sortRating => 'Mejor valorados';

  @override
  String get reset => 'Restablecer';

  @override
  String get applyFilters => 'Ver resultados';

  @override
  String get wishlistEmptyTitle => 'Aún no has guardado nada';

  @override
  String get wishlistEmptyMessage =>
      'Toca el corazón en lo que te guste y te esperará aquí.';

  @override
  String get startShopping => 'Empezar a comprar';

  @override
  String get cartTitle => 'Tu bolsa';

  @override
  String get cartEmptyTitle => 'Tu bolsa está vacía';

  @override
  String get cartEmptyMessage =>
      'Hay cosas buenas esperando. Busquemos algo que te encante.';

  @override
  String get freeShippingUnlocked => 'Tienes envío gratis';

  @override
  String freeShippingRemaining(String amount) {
    return 'Añade $amount más para envío gratis';
  }

  @override
  String removedFromCart(String name) {
    return '$name eliminado';
  }

  @override
  String get undo => 'Deshacer';

  @override
  String get remove => 'Eliminar';

  @override
  String get promoTitle => 'Código promocional';

  @override
  String get promoHint => 'Introduce un código, p. ej. SAVE10';

  @override
  String get apply => 'Aplicar';

  @override
  String get promoInvalid => 'Ese código no es válido';

  @override
  String promoShortfall(String amount) {
    return 'Añade $amount más para usar este código';
  }

  @override
  String get removePromo => 'Quitar código';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Descuento';

  @override
  String discountWithCode(String code) {
    return 'Descuento ($code)';
  }

  @override
  String get shipping => 'Envío';

  @override
  String get free => 'Gratis';

  @override
  String estimatedTax(int rate) {
    return 'Impuestos estimados ($rate%)';
  }

  @override
  String get total => 'Total';

  @override
  String get checkout => 'Pagar';

  @override
  String get stepAddress => 'Dirección';

  @override
  String get stepDelivery => 'Entrega';

  @override
  String get stepPayment => 'Pago';

  @override
  String get stepReview => 'Revisar';

  @override
  String get continueLabel => 'Continuar';

  @override
  String placeOrder(String total) {
    return 'Realizar pedido · $total';
  }

  @override
  String get fieldRequired => 'Obligatorio';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get addressLine1 => 'Dirección';

  @override
  String get addressLine2 => 'Piso, puerta (opcional)';

  @override
  String get city => 'Ciudad';

  @override
  String get postalCode => 'Código postal';

  @override
  String get country => 'País';

  @override
  String get shippingStandard => 'Estándar';

  @override
  String get shippingExpress => 'Exprés';

  @override
  String arrivesBy(String date) {
    return 'Llega el $date';
  }

  @override
  String standardShippingPrice(String price) {
    return '$price\nGratis desde \$75';
  }

  @override
  String businessDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días hábiles',
      one: '1 día hábil',
    );
    return '$_temp0';
  }

  @override
  String get cardNumber => 'Número de tarjeta';

  @override
  String get cardNumberInvalid => 'Revisa el número de tarjeta';

  @override
  String get cardHolder => 'Titular de la tarjeta';

  @override
  String get expiry => 'Caducidad (MM/AA)';

  @override
  String get expiryInvalid => 'Introduce una fecha futura';

  @override
  String get cvv => 'CVV';

  @override
  String get cvvInvalid => '3 o 4 dígitos';

  @override
  String get testCardHint =>
      'Modo de prueba. Usa 4242 4242 4242 4242. Las tarjetas que terminan en 0002 se rechazan.';

  @override
  String get edit => 'Editar';

  @override
  String get processingPayment => 'Procesando el pago…';

  @override
  String get paymentDeclined => 'Tu tarjeta fue rechazada. Prueba con otra.';

  @override
  String get orderConfirmedTitle => '¡Pedido confirmado!';

  @override
  String orderConfirmedMessage(String id, String date) {
    return 'El pedido $id está en camino. Debería llegar el $date.';
  }

  @override
  String get trackOrder => 'Seguir pedido';

  @override
  String get continueShopping => 'Seguir comprando';

  @override
  String get ordersTitle => 'Pedidos';

  @override
  String get ordersEmptyTitle => 'Aún no hay pedidos';

  @override
  String get ordersEmptyMessage =>
      'Cuando hagas un pedido, podrás seguirlo aquí.';

  @override
  String get orderNotFound => 'Pedido no encontrado';

  @override
  String get statusPlaced => 'Pedido realizado';

  @override
  String get statusPacked => 'Empaquetado';

  @override
  String get statusShipped => 'Enviado';

  @override
  String get statusOutForDelivery => 'En reparto';

  @override
  String get statusDelivered => 'Entregado';

  @override
  String estimatedDelivery(String date) {
    return 'Entrega estimada $date';
  }

  @override
  String get deliveringTo => 'Entrega en';

  @override
  String get receipt => 'Recibo';

  @override
  String paidWith(String last4) {
    return 'Pagado con la tarjeta terminada en $last4';
  }

  @override
  String get statOrders => 'Pedidos';

  @override
  String get statSaved => 'Guardados';

  @override
  String get statSpent => 'Gastado';

  @override
  String get recentOrder => 'Pedido reciente';

  @override
  String get updatesTitle => 'Actualizaciones';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get cancel => 'Cancelar';

  @override
  String get badgeNewUpdate => 'Nueva';

  @override
  String get noPatch => 'Sin parche';

  @override
  String patchNumber(int number) {
    return 'Parche #$number';
  }

  @override
  String get appearance => 'Apariencia';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get orderUpdates => 'Estado de pedidos';

  @override
  String get orderUpdatesBody => 'Avisos de envío y entrega';

  @override
  String get offers => 'Ofertas';

  @override
  String get offersBody => 'Códigos promocionales y novedades';

  @override
  String get developer => 'Desarrollador';

  @override
  String get simulateOffline => 'Simular un error de red';

  @override
  String get simulateOfflineBody =>
      'La próxima petición a la tienda fallará para que veas los estados de error.';

  @override
  String get simulateOfflineArmed =>
      'La próxima petición fallará. Desliza para actualizar en Descubrir.';

  @override
  String get madeWithShorebird =>
      'Plume · Actualizada al instante con Shorebird';

  @override
  String get dismiss => 'Cerrar';

  @override
  String get install => 'Instalar';

  @override
  String get restart => 'Reiniciar';

  @override
  String get updateAvailableTitle => 'Actualización disponible';

  @override
  String get updateAvailableBody =>
      'Hay una nueva versión de Plume lista para descargar.';

  @override
  String get updateDownloading => 'Descargando actualización…';

  @override
  String get updateDownloadingBody => 'Solo tarda unos segundos.';

  @override
  String get updateReadyTitle => 'Reinicia para actualizar';

  @override
  String get updateReadyBody =>
      'La actualización está instalada. Cierra y vuelve a abrir Plume para usarla.';

  @override
  String get updateChecking => 'Buscando actualizaciones…';

  @override
  String get updateCheckingBody => 'Consultando a Shorebird el último parche.';

  @override
  String get upToDateTitle => 'Estás al día';

  @override
  String get upToDateBody => 'Tienes la última versión.';

  @override
  String lastChecked(String time) {
    return 'Última comprobación a las $time';
  }

  @override
  String get updateFailedTitle => 'La actualización falló';

  @override
  String get updateFailedBody =>
      'No pudimos descargar la actualización. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get updaterUnavailableTitle =>
      'Actualizaciones no disponibles en esta versión';

  @override
  String get updaterUnavailableBody =>
      'Compila con `shorebird release` o `shorebird preview` para activar las actualizaciones. Las versiones de depuración y `flutter run` no incluyen el actualizador de Shorebird.';

  @override
  String get checkForUpdates => 'Buscar actualizaciones';

  @override
  String get releaseVersion => 'Versión';

  @override
  String get runningPatch => 'Parche en uso';

  @override
  String get nextLaunchPatch => 'En el próximo inicio';

  @override
  String get howItWorks => 'Cómo funcionan las actualizaciones al instante';

  @override
  String get howStep1Title => 'Publicar';

  @override
  String get howStep1Body =>
      '`shorebird release` compila la app que va a las tiendas.';

  @override
  String get howStep2Title => 'Parchear';

  @override
  String get howStep2Body =>
      'Corrige un error en Dart y ejecuta `shorebird patch`. Sin revisión de la tienda.';

  @override
  String get howStep3Title => 'Actualizar';

  @override
  String get howStep3Body =>
      'La app descarga el parche y lo usa en el próximo inicio.';

  @override
  String get restartTitle => 'Reinicia Plume';

  @override
  String get restartBody =>
      'La actualización se aplica la próxima vez que se abra Plume.';

  @override
  String get restartStep1 => 'Abre el selector de apps';

  @override
  String get restartStep2 => 'Desliza Plume para cerrarla';

  @override
  String get restartStep3 => 'Toca Plume para abrirla de nuevo';

  @override
  String get gotIt => 'Entendido';
}
