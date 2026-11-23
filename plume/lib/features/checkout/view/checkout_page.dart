import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/app/router.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/core/widgets/widgets.dart';
import 'package:plume/data/models/models.dart';
import 'package:plume/data/repositories/order_repository.dart';
import 'package:plume/features/cart/cubit/cart_cubit.dart';
import 'package:plume/features/cart/domain/price_calculator.dart';
import 'package:plume/features/cart/view/order_summary_card.dart';
import 'package:plume/features/checkout/widgets/card_preview.dart';
import 'package:plume/features/checkout/widgets/input_formatters.dart';
import 'package:plume/features/orders/orders_cubit.dart';
import 'package:plume/l10n/l10n.dart';

enum CheckoutStep { address, delivery, payment, review }

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  CheckoutStep _step = CheckoutStep.address;
  ShippingMethod _shipping = ShippingMethod.standard;
  final _addressForm = GlobalKey<FormState>();
  final _paymentForm = GlobalKey<FormState>();

  final _name = TextEditingController(text: User.demo.name);
  late final _line1 = TextEditingController(text: _lastAddress?.line1 ?? '');
  late final _line2 = TextEditingController(text: _lastAddress?.line2 ?? '');
  late final _city = TextEditingController(text: _lastAddress?.city ?? '');
  late final _postal = TextEditingController(
    text: _lastAddress?.postalCode ?? '',
  );
  late final _country = TextEditingController(
    text: _lastAddress?.country ?? 'United States',
  );
  final _cardNumber = TextEditingController();
  final _cardHolder = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  final _cvvFocus = FocusNode();

  Address? get _lastAddress {
    final orders = context.read<OrdersCubit>().state.orders;
    return orders.isEmpty ? null : orders.first.address;
  }

  @override
  void initState() {
    super.initState();
    for (final controller in [_cardNumber, _cardHolder, _expiry, _cvv]) {
      controller.addListener(() => setState(() {}));
    }
    _cvvFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _line1,
      _line2,
      _city,
      _postal,
      _country,
      _cardNumber,
      _cardHolder,
      _expiry,
      _cvv,
    ]) {
      controller.dispose();
    }
    _cvvFocus.dispose();
    super.dispose();
  }

  Address get _address => Address(
    fullName: _name.text.trim(),
    line1: _line1.text.trim(),
    line2: _line2.text.trim(),
    city: _city.text.trim(),
    postalCode: _postal.text.trim(),
    country: _country.text.trim(),
  );

  PaymentCard get _card => PaymentCard(
    holder: _cardHolder.text.trim(),
    number: _cardNumber.text,
    expiry: _expiry.text,
  );

  void _continue() {
    FocusScope.of(context).unfocus();
    final valid = switch (_step) {
      CheckoutStep.address => _addressForm.currentState!.validate(),
      CheckoutStep.payment => _paymentForm.currentState!.validate(),
      _ => true,
    };
    if (!valid) {
      unawaited(HapticFeedback.heavyImpact());
      return;
    }
    if (_step == CheckoutStep.review) {
      unawaited(_placeOrder());
      return;
    }
    setState(() => _step = CheckoutStep.values[_step.index + 1]);
  }

  void _back() {
    if (_step == CheckoutStep.address) {
      context.pop();
    } else {
      setState(() => _step = CheckoutStep.values[_step.index - 1]);
    }
  }

  Future<void> _placeOrder() async {
    final cart = context.read<CartCubit>();
    final orders = context.read<OrdersCubit>();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final summary = const PriceCalculator().calculate(
      items: cart.state.items,
      promotion: cart.state.promotion,
      shippingMethod: _shipping,
    );
    final order = await orders.place(
      items: cart.state.items,
      summary: summary,
      address: _address,
      shippingMethod: _shipping,
      card: _card,
    );
    if (order == null) {
      unawaited(HapticFeedback.heavyImpact());
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Palette.coral,
          content: Text(
            orders.state.paymentError == PaymentError.declined
                ? l10n.paymentDeclined
                : l10n.errorMessage,
          ),
        ),
      );
      return;
    }
    unawaited(HapticFeedback.heavyImpact());
    await cart.clear();
    router.go(Routes.orderConfirmed(order.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cart = context.watch<CartCubit>().state;
    final placing = context.select<OrdersCubit, bool>(
      (c) => c.state.placeStatus == PlaceOrderStatus.placing,
    );
    final summary = const PriceCalculator().calculate(
      items: cart.items,
      promotion: cart.promotion,
      shippingMethod: _shipping,
    );
    final locale = Localizations.localeOf(context).toLanguageTag();
    final titles = [
      l10n.stepAddress,
      l10n.stepDelivery,
      l10n.stepPayment,
      l10n.stepReview,
    ];

    return PopScope(
      canPop: _step == CheckoutStep.address && !placing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !placing) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: placing ? null : _back,
            icon: Icon(
              _step == CheckoutStep.address
                  ? Icons.close_rounded
                  : Icons.arrow_back_rounded,
            ),
          ),
          title: Text(l10n.checkout),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                _Stepper(current: _step.index, titles: titles),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: Motion.of(context, Motion.medium),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0.08, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: switch (_step) {
                        CheckoutStep.address => _addressStep(l10n),
                        CheckoutStep.delivery => _deliveryStep(l10n, locale),
                        CheckoutStep.payment => _paymentStep(l10n),
                        CheckoutStep.review => _reviewStep(
                          l10n,
                          cart.items,
                          summary,
                        ),
                      },
                    ),
                  ),
                ),
              ],
            ),
            if (placing) const _PlacingOverlay(),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: Palette.brandGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
              ),
              onPressed: placing || cart.isEmpty ? null : _continue,
              child: Text(
                _step == CheckoutStep.review
                    ? l10n.placeOrder(summary.total.format(locale))
                    : l10n.continueLabel,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _addressStep(AppLocalizations l10n) {
    String? required(String? value) =>
        (value ?? '').trim().isEmpty ? l10n.fieldRequired : null;
    return Form(
      key: _addressForm,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
            decoration: InputDecoration(labelText: l10n.fullName),
            validator: required,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _line1,
            autofillHints: const [AutofillHints.streetAddressLine1],
            decoration: InputDecoration(labelText: l10n.addressLine1),
            validator: required,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _line2,
            autofillHints: const [AutofillHints.streetAddressLine2],
            decoration: InputDecoration(labelText: l10n.addressLine2),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _city,
                  autofillHints: const [AutofillHints.addressCity],
                  decoration: InputDecoration(labelText: l10n.city),
                  validator: required,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _postal,
                  autofillHints: const [AutofillHints.postalCode],
                  decoration: InputDecoration(labelText: l10n.postalCode),
                  validator: required,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _country,
            autofillHints: const [AutofillHints.countryName],
            decoration: InputDecoration(labelText: l10n.country),
            validator: required,
          ),
        ],
      ),
    );
  }

  Widget _deliveryStep(AppLocalizations l10n, String locale) {
    final format = DateFormat.MMMEd(locale);
    final now = DateTime.now();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final (index, method) in ShippingMethod.values.indexed)
          Entrance(
            index: index,
            child: _DeliveryOption(
              selected: method == _shipping,
              icon: method == ShippingMethod.express
                  ? Icons.bolt_rounded
                  : Icons.local_shipping_rounded,
              title: method == ShippingMethod.express
                  ? l10n.shippingExpress
                  : l10n.shippingStandard,
              subtitle: l10n.arrivesBy(
                format.format(now.add(Duration(days: method.days))),
              ),
              price: method == ShippingMethod.standard
                  ? l10n.standardShippingPrice(method.price.format(locale))
                  : method.price.format(locale),
              onTap: () => setState(() => _shipping = method),
            ),
          ),
      ],
    );
  }

  Widget _paymentStep(AppLocalizations l10n) {
    return Form(
      key: _paymentForm,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CardPreview(
            card: _card,
            cvv: _cvv.text,
            showBack: _cvvFocus.hasFocus,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _cardNumber,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.creditCardNumber],
            inputFormatters: [CardNumberFormatter()],
            decoration: InputDecoration(
              labelText: l10n.cardNumber,
              prefixIcon: const Icon(Icons.credit_card_rounded),
            ),
            validator: (value) =>
                passesLuhn(_card.digits) ? null : l10n.cardNumberInvalid,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _cardHolder,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.creditCardName],
            decoration: InputDecoration(labelText: l10n.cardHolder),
            validator: (value) =>
                (value ?? '').trim().isEmpty ? l10n.fieldRequired : null,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiry,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.creditCardExpirationDate],
                  inputFormatters: [ExpiryFormatter()],
                  decoration: InputDecoration(labelText: l10n.expiry),
                  validator: (value) =>
                      isValidExpiry(value ?? '', DateTime.now())
                      ? null
                      : l10n.expiryInvalid,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cvv,
                  focusNode: _cvvFocus,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  autofillHints: const [AutofillHints.creditCardSecurityCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: InputDecoration(labelText: l10n.cvv),
                  validator: (value) =>
                      (value ?? '').length >= 3 ? null : l10n.cvvInvalid,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.lock_rounded, size: 16, color: Palette.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.testCardHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reviewStep(
    AppLocalizations l10n,
    List<CartItem> items,
    OrderSummary summary,
  ) {
    final theme = Theme.of(context);
    final card = _card;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final (index, item) in items.indexed)
          Entrance(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 52,
                    child: ProductArt(
                      icon: item.product.icon,
                      color: item.color.color,
                      borderRadius: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${item.quantity} × ${item.product.name}',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    item.lineTotal.format(
                      Localizations.localeOf(context).toLanguageTag(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        _ReviewTile(
          icon: Icons.place_rounded,
          title: _address.fullName,
          subtitle: _address.singleLine,
          onEdit: () => setState(() => _step = CheckoutStep.address),
        ),
        _ReviewTile(
          icon: Icons.local_shipping_rounded,
          title: _shipping == ShippingMethod.express
              ? l10n.shippingExpress
              : l10n.shippingStandard,
          subtitle: l10n.businessDays(_shipping.days),
          onEdit: () => setState(() => _step = CheckoutStep.delivery),
        ),
        _ReviewTile(
          icon: Icons.credit_card_rounded,
          title: '${card.brand.label} •••• ${card.last4}',
          subtitle: card.holder,
          onEdit: () => setState(() => _step = CheckoutStep.payment),
        ),
        const SizedBox(height: 12),
        OrderSummaryCard(summary: summary),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.current, required this.titles});

  final int current;
  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Row(
        children: [
          for (var i = 0; i < titles.length; i++) ...[
            Expanded(
              child: Semantics(
                selected: i == current,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: i <= current ? 1 : 0),
                        duration: Motion.of(context, Motion.slow),
                        curve: Motion.emphasized,
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value,
                          minHeight: 5,
                          color: Palette.violet,
                          backgroundColor: theme.colorScheme.surfaceContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      titles[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: i == current
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: i <= current
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.45,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i < titles.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _DeliveryOption extends StatelessWidget {
  const _DeliveryOption({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final String price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Semantics(
        selected: selected,
        inMutuallyExclusiveGroup: true,
        child: Pressable(
          onTap: onTap,
          child: AnimatedContainer(
            duration: Motion.of(context, Motion.medium),
            curve: Motion.emphasized,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? Palette.violet
                    : theme.colorScheme.outlineVariant,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: Motion.of(context, Motion.medium),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? Palette.violet
                        : theme.colorScheme.surfaceContainer,
                  ),
                  child: Icon(
                    icon,
                    color: selected
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      Text(subtitle, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Text(
                  price,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onEdit,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(icon, color: Palette.violet),
          title: Text(title),
          subtitle: Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: TextButton(
            onPressed: onEdit,
            child: Text(context.l10n.edit),
          ),
        ),
      ),
    );
  }
}

/// Blocks the screen with a pulsing lock while the payment is processed.
class _PlacingOverlay extends StatelessWidget {
  const _PlacingOverlay();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: ColoredBox(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.85),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox.square(
                dimension: 72,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  color: Palette.violet,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.l10n.processingPayment,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
