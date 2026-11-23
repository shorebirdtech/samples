import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/features/cart/cubit/cart_cubit.dart';
import 'package:plume/features/wishlist/wishlist_cubit.dart';
import 'package:plume/l10n/l10n.dart';

/// Hosts the five main tabs behind a floating, frosted navigation bar.
class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  static const barHeight = 68.0;

  /// Bottom padding scrollable tab content needs to clear the floating bar.
  static double contentInset(BuildContext context) =>
      barHeight + 28 + MediaQuery.paddingOf(context).bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: shell,
      bottomNavigationBar: _NavBar(
        index: shell.currentIndex,
        onSelect: (index) {
          unawaited(HapticFeedback.selectionClick());
          shell.goBranch(index, initialLocation: index == shell.currentIndex);
        },
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final cartCount = context.select<CartCubit, int>((c) => c.state.itemCount);
    final cartBump = context.select<CartCubit, DateTime?>(
      (c) => c.state.lastAddedAt,
    );
    final wishlistCount = context.select<WishlistCubit, int>(
      (c) => c.state.length,
    );
    final items = [
      (Icons.explore_outlined, Icons.explore_rounded, l10n.tabDiscover, 0),
      (Icons.search_rounded, Icons.saved_search_rounded, l10n.tabSearch, 0),
      (
        Icons.favorite_outline_rounded,
        Icons.favorite_rounded,
        l10n.tabWishlist,
        wishlistCount,
      ),
      (
        Icons.shopping_bag_outlined,
        Icons.shopping_bag_rounded,
        l10n.tabCart,
        cartCount,
      ),
      (Icons.person_outline_rounded, Icons.person_rounded, l10n.tabProfile, 0),
    ];

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: AppShell.barHeight,
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth / items.length;
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: Motion.of(context, Motion.medium),
                      curve: Motion.emphasized,
                      left: width * index + 8,
                      top: 8,
                      width: width - 16,
                      height: AppShell.barHeight - 16,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < items.length; i++)
                          Expanded(
                            child: _NavItem(
                              icon: items[i].$1,
                              selectedIcon: items[i].$2,
                              label: items[i].$3,
                              badge: items[i].$4,
                              bumpKey: i == 3 ? cartBump : null,
                              selected: i == index,
                              onTap: () => onSelect(i),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.badge,
    required this.selected,
    required this.onTap,
    this.bumpKey,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int badge;
  final bool selected;
  final VoidCallback onTap;
  final Object? bumpKey;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected
        ? scheme.onSurface
        : scheme.onSurface.withValues(alpha: 0.6);
    return Semantics(
      selected: selected,
      button: true,
      label: badge > 0 ? '$label, $badge' : label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: Center(
          child: Badge(
            isLabelVisible: badge > 0,
            backgroundColor: Palette.coral,
            label: _BumpingText(text: '$badge', bumpKey: bumpKey),
            child: AnimatedSwitcher(
              duration: Motion.of(context, Motion.fast),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                selected ? selectedIcon : icon,
                key: ValueKey(selected),
                color: color,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Springs bigger for a moment whenever [bumpKey] changes.
class _BumpingText extends StatelessWidget {
  const _BumpingText({required this.text, this.bumpKey});

  final String text;
  final Object? bumpKey;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(bumpKey),
      tween: Tween(begin: bumpKey == null ? 1 : 1.8, end: 1),
      duration: Motion.of(context, Motion.slow),
      curve: Motion.spring,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Text(text),
    );
  }
}
