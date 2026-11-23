import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/app/router.dart';
import 'package:plume/app/shell.dart';
import 'package:plume/core/widgets/widgets.dart';
import 'package:plume/data/models/models.dart';
import 'package:plume/data/repositories/catalog_repository.dart';
import 'package:plume/features/catalog/widgets/product_card.dart';
import 'package:plume/features/discover/cubit/discover_cubit.dart';
import 'package:plume/features/discover/widgets/collection_carousel.dart';
import 'package:plume/features/discover/widgets/promo_strip.dart';
import 'package:plume/l10n/l10n.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = DiscoverCubit(context.read<CatalogRepository>());
        unawaited(cubit.load());
        return cubit;
      },
      child: const DiscoverView(),
    );
  }
}

class DiscoverView extends StatelessWidget {
  const DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DiscoverCubit>().state;
    return Scaffold(
      body: switch (state.status) {
        DiscoverStatus.loading => const _DiscoverSkeleton(),
        DiscoverStatus.failure => ErrorState(
          onRetry: () => unawaited(context.read<DiscoverCubit>().load()),
        ),
        DiscoverStatus.ready => _DiscoverContent(state: state),
      },
    );
  }
}

class _DiscoverContent extends StatelessWidget {
  const _DiscoverContent({required this.state});

  final DiscoverState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RefreshIndicator(
      onRefresh: () => context.read<DiscoverCubit>().load(refresh: true),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _Header()),
          SliverToBoxAdapter(
            child: Entrance(
              index: 1,
              child: CollectionCarousel(collections: state.collections),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Entrance(
                index: 2,
                child: PromoStrip(code: 'SAVE10', message: l10n.promoSave10),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SectionHeader(title: l10n.shopByCategory)),
          SliverToBoxAdapter(child: _CategoryRow(categories: state.categories)),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: l10n.trendingNow,
              actionLabel: l10n.seeAll,
              onAction: () => context.go(Routes.search),
            ),
          ),
          SliverToBoxAdapter(
            child: _ProductRail(products: state.trending, scope: 'trending'),
          ),
          SliverToBoxAdapter(child: SectionHeader(title: l10n.dealsTitle)),
          SliverToBoxAdapter(
            child: _ProductRail(products: state.deals, scope: 'deals'),
          ),
          SliverToBoxAdapter(child: SectionHeader(title: l10n.newArrivals)),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              AppShell.contentInset(context),
            ),
            sliver: ProductGrid(
              products: state.newArrivals + state.bestsellers,
              scope: 'grid',
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final user = User.demo.firstName;
    final initials = User.demo.initials;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? l10n.greetingMorning(user)
        : hour < 18
        ? l10n.greetingAfternoon(user)
        : l10n.greetingEvening(user);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Entrance(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.discoverHeadline,
                          style: theme.textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                Pressable(
                  semanticLabel: l10n.tabProfile,
                  onTap: () => context.go(Routes.profile),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.surfaceContainer,
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Pressable(
              scale: 0.98,
              semanticLabel: l10n.searchHint,
              onTap: () => context.go(Routes.search),
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.searchHint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          return Entrance(
            index: index,
            offset: const Offset(0.3, 0),
            child: Pressable(
              semanticLabel: category.name,
              onTap: () => context.go(Routes.searchCategory(category.id)),
              child: Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Icon(
                      AppIcons.of(category.icon),
                      color: theme.colorScheme.onSurface,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(category.name, style: theme.textTheme.labelLarge),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductRail extends StatelessWidget {
  const _ProductRail({required this.products, required this.scope});

  final List<Product> products;
  final String scope;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) => Entrance(
          index: index,
          offset: const Offset(0.25, 0),
          child: ProductCard(
            product: products[index],
            heroScope: scope,
            width: 168,
          ),
        ),
      ),
    );
  }
}

/// A two-column sliver grid of product cards with a staggered entrance.
class ProductGrid extends StatelessWidget {
  const ProductGrid({required this.products, required this.scope, super.key});

  final List<Product> products;
  final String scope;

  @override
  Widget build(BuildContext context) {
    final unique = {for (final p in products) p.id: p}.values.toList();
    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisSpacing: 22,
        crossAxisSpacing: 16,
        childAspectRatio: 0.6,
      ),
      itemCount: unique.length,
      itemBuilder: (context, index) => Entrance(
        index: index,
        child: ProductCard(product: unique[index], heroScope: scope),
      ),
    );
  }
}

class _DiscoverSkeleton extends StatelessWidget {
  const _DiscoverSkeleton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const Skeleton(width: 140, height: 18),
          const SizedBox(height: 10),
          const Skeleton(width: 220, height: 32),
          const SizedBox(height: 20),
          const Skeleton(height: 54, radius: 18),
          const SizedBox(height: 20),
          const Skeleton(height: 220, radius: 30),
          const SizedBox(height: 24),
          Row(
            children: List.generate(
              4,
              (_) => const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Skeleton(width: 68, height: 68, radius: 22),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: Skeleton(height: 200)),
              SizedBox(width: 16),
              Expanded(child: Skeleton(height: 200)),
            ],
          ),
        ],
      ),
    );
  }
}
