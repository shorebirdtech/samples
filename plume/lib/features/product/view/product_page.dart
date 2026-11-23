import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/app/router.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/core/widgets/widgets.dart';
import 'package:plume/data/models/models.dart';
import 'package:plume/data/repositories/catalog_repository.dart';
import 'package:plume/features/cart/cubit/cart_cubit.dart';
import 'package:plume/features/catalog/widgets/price_tag.dart';
import 'package:plume/features/catalog/widgets/product_card.dart';
import 'package:plume/features/catalog/widgets/wishlist_button.dart';
import 'package:plume/features/product/cubit/product_cubit.dart';
import 'package:plume/features/product/widgets/fly_to_cart.dart';
import 'package:plume/features/product/widgets/reviews_section.dart';
import 'package:plume/features/product/widgets/tilt_art.dart';
import 'package:plume/l10n/l10n.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({required this.productId, this.heroTag, super.key});

  final String productId;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ProductCubit(
          context.read<CatalogRepository>(),
          productId,
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: ProductView(heroTag: heroTag),
    );
  }
}

class ProductView extends StatefulWidget {
  const ProductView({this.heroTag, super.key});

  final String? heroTag;

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  final GlobalKey<State<StatefulWidget>> _buttonKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _cartKey = GlobalKey();
  bool _expanded = false;

  Future<void> _addToCart(ProductState state) async {
    final product = state.product!;
    final cart = context.read<CartCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    unawaited(HapticFeedback.mediumImpact());
    await flyToCart(
      context: context,
      from: _buttonKey,
      to: _cartKey,
      icon: product.icon,
      color: state.color!.color,
    );
    await cart.add(
      product,
      colorName: state.color!.name,
      quantity: state.quantity,
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.addedToCart(product.name)),
          action: SnackBarAction(
            label: l10n.viewCart,
            onPressed: () => rootNavigatorKey.currentContext?.go(Routes.cart),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProductCubit>().state;
    final l10n = context.l10n;
    return Scaffold(
      body: switch (state.status) {
        ProductStatus.loading => _LoadingHero(heroTag: widget.heroTag),
        ProductStatus.failure => ErrorState(
          onRetry: () => unawaited(context.read<ProductCubit>().load()),
        ),
        ProductStatus.notFound => EmptyState(
          icon: Icons.search_off_rounded,
          title: l10n.productNotFoundTitle,
          message: l10n.productNotFoundMessage,
          action: FilledButton(
            onPressed: () => context.go(Routes.discover),
            child: Text(l10n.backToShop),
          ),
        ),
        ProductStatus.ready => _ProductBody(
          state: state,
          heroTag: widget.heroTag,
          cartKey: _cartKey,
          expanded: _expanded,
          onToggleExpanded: () => setState(() => _expanded = !_expanded),
        ),
      },
      bottomNavigationBar: state.status == ProductStatus.ready
          ? _AddToCartBar(
              key: _buttonKey,
              state: state,
              onAdd: () => unawaited(_addToCart(state)),
            )
          : null,
    );
  }
}

class _LoadingHero extends StatelessWidget {
  const _LoadingHero({this.heroTag});

  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    const skeleton = Skeleton(radius: 40);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: heroTag == null
                  ? skeleton
                  : Hero(tag: heroTag!, child: skeleton),
            ),
            const SizedBox(height: 24),
            const Skeleton(height: 28),
            const SizedBox(height: 12),
            const Skeleton(height: 18, width: 160),
          ],
        ),
      ),
    );
  }
}

class _ProductBody extends StatelessWidget {
  const _ProductBody({
    required this.state,
    required this.cartKey,
    required this.expanded,
    required this.onToggleExpanded,
    this.heroTag,
  });

  final ProductState state;
  final String? heroTag;
  final GlobalKey cartKey;
  final bool expanded;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final product = state.product!;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final cubit = context.read<ProductCubit>();
    final art = TiltArt(icon: product.icon, color: state.color!.color);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: theme.scaffoldBackgroundColor,
          leadingWidth: 64,
          leading: const _CircleBack(),
          actions: [
            _CartIcon(key: cartKey),
            Padding(
              padding: const EdgeInsets.only(right: 12, left: 4),
              child: WishlistButton(productId: product.id),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.list(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: heroTag == null ? art : Hero(tag: heroTag!, child: art),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  l10n.dragToTilt,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Entrance(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.brand.toUpperCase(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              letterSpacing: 1.4,
                              color: Palette.violet,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.name,
                            style: theme.textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                    if (product.isOnSale || product.isNew)
                      ProductBadge(product: product),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Entrance(
                index: 1,
                child: Row(
                  children: [
                    RatingStars(rating: product.rating),
                    const SizedBox(width: 8),
                    Text(
                      '${product.rating} · '
                      '${l10n.reviewCount(product.reviewCount)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Entrance(
                index: 2,
                child: PriceTag(product: product, large: true),
              ),
              const SizedBox(height: 24),
              Entrance(
                index: 3,
                child: Text(
                  l10n.colorLabel(state.color!.name),
                  style: theme.textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 12),
              Entrance(
                index: 3,
                child: Wrap(
                  spacing: 14,
                  children: [
                    for (var i = 0; i < product.colors.length; i++)
                      _Swatch(
                        color: product.colors[i],
                        selected: i == state.colorIndex,
                        onTap: () => cubit.selectColor(i),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Entrance(
                index: 4,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final highlight in product.highlights)
                      Chip(
                        avatar: const Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: Palette.aqua,
                        ),
                        label: Text(highlight),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Entrance(
                index: 5,
                child: SmoothSize(
                  child: Text(
                    product.description,
                    maxLines: expanded ? null : 2,
                    overflow: expanded ? null : TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onToggleExpanded,
                  child: Text(expanded ? l10n.readLess : l10n.readMore),
                ),
              ),
              const SizedBox(height: 8),
              _DeliveryInfo(product: product),
              const SizedBox(height: 12),
            ],
          ),
        ),
        SliverToBoxAdapter(child: SectionHeader(title: l10n.reviewsTitle)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: ReviewsSection(
              product: product,
              reviews: state.reviews,
              histogram: state.ratingHistogram,
            ),
          ),
        ),
        if (state.related.isNotEmpty) ...[
          SliverToBoxAdapter(child: SectionHeader(title: l10n.youMayAlsoLike)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 290,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: state.related.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, index) => ProductCard(
                  product: state.related[index],
                  heroScope: 'related-${product.id}',
                  width: 168,
                ),
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _DeliveryInfo extends StatelessWidget {
  const _DeliveryInfo({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final rows = [
      (Icons.local_shipping_rounded, l10n.freeShippingOver75),
      (Icons.autorenew_rounded, l10n.freeReturns),
      (
        Icons.inventory_2_rounded,
        product.stock < 10 ? l10n.lowStock(product.stock) : l10n.inStock,
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (final (icon, label) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: Palette.violet),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(label, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final ProductColor color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      label: color.name,
      button: true,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          onTap();
        },
        child: AnimatedContainer(
          duration: Motion.of(context, Motion.medium),
          curve: Motion.spring,
          width: 44,
          height: 44,
          padding: EdgeInsets.all(selected ? 4 : 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Palette.violet : Colors.transparent,
              width: 2,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleBack extends StatelessWidget {
  const _CircleBack();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 12),
    // Centred: the app bar gives its leading slot a tight height.
    child: Center(
      child: IconButton.filledTonal(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () =>
            context.canPop() ? context.pop() : context.go(Routes.discover),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    ),
  );
}

class _CartIcon extends StatelessWidget {
  const _CartIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.select<CartCubit, int>((c) => c.state.itemCount);
    return IconButton.filledTonal(
      tooltip: context.l10n.tabCart,
      onPressed: () => context.go(Routes.cart),
      icon: Badge(
        isLabelVisible: count > 0,
        backgroundColor: Palette.coral,
        label: Text('$count'),
        child: const Icon(Icons.shopping_bag_outlined),
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({required this.state, required this.onAdd, super.key});

  final ProductState state;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final product = state.product!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        children: [
          QuantityStepper(
            value: state.quantity,
            onChanged: context.read<ProductCubit>().setQuantity,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: Palette.brandGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                ),
                onPressed: onAdd,
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: FittedBox(
                  child: Text(
                    l10n.addToCartWithPrice(
                      (product.price * state.quantity).format(locale),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
