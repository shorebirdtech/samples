import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/app/router.dart';
import 'package:plume/app/shell.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/core/widgets/widgets.dart';
import 'package:plume/data/models/models.dart';
import 'package:plume/features/cart/cubit/cart_cubit.dart';
import 'package:plume/features/cart/domain/price_calculator.dart';
import 'package:plume/features/cart/view/order_summary_card.dart';
import 'package:plume/features/cart/view/promo_code_field.dart';
import 'package:plume/l10n/l10n.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<CartCubit>().state;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cartTitle),
        actions: [
          if (!state.isEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                child: Text(
                  l10n.itemCount(state.itemCount),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
        ],
      ),
      body: switch (state) {
        CartState(status: CartStatus.loading) => const Center(
          child: CircularProgressIndicator(),
        ),
        CartState(isEmpty: true) => EmptyState(
          icon: Icons.shopping_bag_rounded,
          title: l10n.cartEmptyTitle,
          message: l10n.cartEmptyMessage,
          action: FilledButton(
            onPressed: () => context.go(Routes.discover),
            child: Text(l10n.startShopping),
          ),
        ),
        _ => _CartContent(state: state),
      },
    );
  }
}

class _CartContent extends StatelessWidget {
  const _CartContent({required this.state});

  final CartState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summary = state.summary;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 4, 20, AppShell.contentInset(context)),
      children: [
        _FreeShippingMeter(summary: summary),
        const SizedBox(height: 16),
        for (final (index, item) in state.items.indexed)
          Entrance(
            key: ValueKey(item.key),
            index: index,
            child: _CartLine(item: item, index: index),
          ),
        const SizedBox(height: 12),
        Text(l10n.promoTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        const PromoCodeField(),
        const SizedBox(height: 20),
        OrderSummaryCard(summary: summary),
        const SizedBox(height: 16),
        _CheckoutButton(summary: summary),
      ],
    );
  }
}

class _FreeShippingMeter extends StatelessWidget {
  const _FreeShippingMeter({required this.summary});

  final OrderSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final threshold = PriceCalculator.freeShippingThreshold.cents;
    final progress =
        1 - (summary.freeShippingRemaining.cents / threshold).clamp(0.0, 1.0);
    final unlocked = summary.freeShippingRemaining.isZero;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: Motion.of(context, Motion.medium),
            child: Text(
              unlocked
                  ? l10n.freeShippingUnlocked
                  : l10n.freeShippingRemaining(
                      summary.freeShippingRemaining.format(locale),
                    ),
              key: ValueKey(unlocked),
              style: theme.textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) => TweenAnimationBuilder<double>(
              tween: Tween(end: progress),
              duration: Motion.of(context, Motion.slow),
              curve: Motion.emphasized,
              builder: (context, value, _) => SizedBox(
                height: 28,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Container(
                      height: 8,
                      width: constraints.maxWidth * value,
                      decoration: BoxDecoration(
                        gradient: Palette.brandGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Positioned(
                      left: (constraints.maxWidth - 28) * value,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: unlocked ? Palette.success : Palette.violet,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          unlocked
                              ? Icons.check_rounded
                              : Icons.local_shipping_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({required this.item, required this.index});

  final CartItem item;
  final int index;

  void _remove(BuildContext context) {
    final cubit = context.read<CartCubit>();
    final l10n = context.l10n;
    unawaited(HapticFeedback.mediumImpact());
    unawaited(cubit.remove(item));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.removedFromCart(item.product.name)),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => unawaited(cubit.restore(item, index)),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey('dismiss-${item.key}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _remove(context),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: Palette.coral,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
        ),
        child: Pressable(
          scale: 0.98,
          semanticLabel: item.product.name,
          onTap: () => context.push(Routes.product(item.product.id)),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 84,
                  child: ProductArt(
                    icon: item.product.icon,
                    color: item.color.color,
                    borderRadius: 12,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: item.color.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.colorName,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          QuantityStepper(
                            compact: true,
                            min: 0,
                            value: item.quantity,
                            onChanged: (quantity) => quantity == 0
                                ? _remove(context)
                                : unawaited(
                                    context.read<CartCubit>().setQuantity(
                                      item,
                                      quantity,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: FittedBox(
                                child: AnimatedMoney(
                                  item.lineTotal,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.remove,
                  onPressed: () => _remove(context),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  const _CheckoutButton({required this.summary});

  final OrderSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DecoratedBox(
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
        onPressed: () => context.push(Routes.checkout),
        child: Row(
          children: [
            Text(l10n.checkout),
            const Spacer(),
            Text(summary.total.format(locale)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    );
  }
}
