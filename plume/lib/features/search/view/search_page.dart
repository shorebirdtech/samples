import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/app/shell.dart';
import 'package:plume/core/logging/analytics.dart';
import 'package:plume/core/money.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/core/widgets/widgets.dart';
import 'package:plume/data/repositories/catalog_repository.dart';
import 'package:plume/features/discover/view/discover_page.dart';
import 'package:plume/features/search/cubit/search_cubit.dart';
import 'package:plume/l10n/l10n.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({this.initialCategoryId, super.key});

  final String? initialCategoryId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = SearchCubit(
          context.read<CatalogRepository>(),
          context.read<Analytics>(),
          categoryId: initialCategoryId,
        );
        unawaited(cubit.init());
        return cubit;
      },
      child: _CategorySync(
        categoryId: initialCategoryId,
        child: const SearchView(),
      ),
    );
  }
}

/// Applies a category passed in the URL after the page already exists, e.g.
/// tapping a category on Discover while the search tab is alive.
class _CategorySync extends StatefulWidget {
  const _CategorySync({required this.categoryId, required this.child});

  final String? categoryId;
  final Widget child;

  @override
  State<_CategorySync> createState() => _CategorySyncState();
}

class _CategorySyncState extends State<_CategorySync> {
  @override
  void didUpdateWidget(_CategorySync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoryId != oldWidget.categoryId &&
        widget.categoryId != null) {
      unawaited(context.read<SearchCubit>().setCategory(widget.categoryId));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = context.watch<SearchCubit>().state;
    final cubit = context.read<SearchCubit>();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: cubit.setText,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: l10n.searchHint,
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: state.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: l10n.clear,
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _controller.clear();
                                  cubit.setText('');
                                },
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Badge(
                    isLabelVisible: state.activeFilterCount > 0,
                    backgroundColor: Palette.violet,
                    label: Text('${state.activeFilterCount}'),
                    child: IconButton.filledTonal(
                      tooltip: l10n.filters,
                      iconSize: 24,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(54, 54),
                      ),
                      onPressed: () => unawaited(_openFilters(context, state)),
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _CategoryChip(
                    label: l10n.allCategories,
                    selected: state.categoryId == null,
                    onTap: () => unawaited(cubit.setCategory(null)),
                  ),
                  for (final category in state.categories)
                    _CategoryChip(
                      label: category.name,
                      color: category.color,
                      selected: state.categoryId == category.id,
                      onTap: () => unawaited(cubit.setCategory(category.id)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: Motion.of(context, Motion.fast),
                    child: Text(
                      l10n.resultCount(state.results.length),
                      key: ValueKey(state.results.length),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (state.status == SearchStatus.loading)
                    const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
            Expanded(child: _Results(state: state)),
          ],
        ),
      ),
    );
  }

  Future<void> _openFilters(BuildContext context, SearchState state) {
    final cubit = context.read<SearchCubit>();
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FilterSheet(state: state, cubit: cubit),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (state.status == SearchStatus.failure) {
      return ErrorState(
        onRetry: () => unawaited(context.read<SearchCubit>().retry()),
      );
    }
    if (state.status == SearchStatus.ready && state.results.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: l10n.noResultsTitle,
        message: l10n.noResultsMessage,
        action: state.activeFilterCount > 0
            ? OutlinedButton(
                onPressed: () =>
                    unawaited(context.read<SearchCubit>().clearFilters()),
                child: Text(l10n.clearFilters),
              )
            : null,
      );
    }
    return AnimatedSwitcher(
      duration: Motion.of(context, Motion.medium),
      child: CustomScrollView(
        key: ValueKey(state.results.map((p) => p.id).join()),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              AppShell.contentInset(context),
            ),
            sliver: ProductGrid(products: state.results, scope: 'search'),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = Palette.violet,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        selected: selected,
        button: true,
        child: Pressable(
          onTap: onTap,
          child: AnimatedContainer(
            duration: Motion.of(context, Motion.medium),
            curve: Motion.emphasized,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? color : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? color : theme.colorScheme.outlineVariant,
              ),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.state, required this.cubit});

  final SearchState state;
  final SearchCubit cubit;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late double _maxPrice =
      (widget.state.maxPriceCents ?? SearchState.priceCeilingCents).toDouble();
  late bool _onSale = widget.state.onSaleOnly;
  late ProductSort _sort = widget.state.sort;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final unlimited = _maxPrice >= SearchState.priceCeilingCents;
    final sorts = {
      ProductSort.featured: l10n.sortFeatured,
      ProductSort.priceLowHigh: l10n.sortPriceLow,
      ProductSort.priceHighLow: l10n.sortPriceHigh,
      ProductSort.rating: l10n.sortRating,
    };
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.filters, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(l10n.maxPrice, style: theme.textTheme.titleSmall),
                const Spacer(),
                Text(
                  unlimited
                      ? l10n.anyPrice
                      : Money.cents(_maxPrice.round()).format(locale),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Palette.violet,
                  ),
                ),
              ],
            ),
            Slider(
              value: _maxPrice,
              min: 5000,
              max: SearchState.priceCeilingCents.toDouble(),
              divisions: 30,
              onChanged: (value) => setState(() => _maxPrice = value),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.onSaleOnly),
              value: _onSale,
              onChanged: (value) => setState(() => _onSale = value),
            ),
            const SizedBox(height: 8),
            Text(l10n.sortBy, style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in sorts.entries)
                  ChoiceChip(
                    label: Text(entry.value),
                    selected: _sort == entry.key,
                    onSelected: (_) => setState(() => _sort = entry.key),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      unawaited(widget.cubit.clearFilters());
                      Navigator.pop(context);
                    },
                    child: Text(l10n.reset),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      unawaited(
                        widget.cubit.applyFilters(
                          maxPriceCents: unlimited ? null : _maxPrice.round(),
                          onSaleOnly: _onSale,
                          sort: _sort,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: Text(l10n.applyFilters),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
