import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/app/router.dart';
import 'package:plume/app/shell.dart';
import 'package:plume/core/money.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/core/widgets/widgets.dart';
import 'package:plume/data/models/user.dart';
import 'package:plume/features/orders/orders_cubit.dart';
import 'package:plume/features/orders/view/orders_page.dart';
import 'package:plume/features/updates/update_cubit.dart';
import 'package:plume/features/wishlist/wishlist_cubit.dart';
import 'package:plume/l10n/l10n.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    const user = User.demo;
    final orders = context.watch<OrdersCubit>().state.orders;
    final saved = context.select<WishlistCubit, int>((c) => c.state.length);
    final update = context.watch<UpdateCubit>().state;
    final spent = orders.fold(0, (sum, o) => sum + o.total.cents);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, AppShell.contentInset(context)),
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Entrance(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AuroraBackground(
                    colors: const [Palette.ink, Palette.violet, Palette.iris],
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.white,
                                child: Text(
                                  user.initials,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Palette.violet,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(color: Colors.white),
                                    ),
                                    Text(
                                      user.email,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              _Stat(
                                value: '${orders.length}',
                                label: l10n.statOrders,
                              ),
                              _Stat(value: '$saved', label: l10n.statSaved),
                              _Stat(
                                value: Money.cents(spent).format(locale),
                                label: l10n.statSpent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (orders.isNotEmpty) ...[
            SectionHeaderPadding(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.recentOrder,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(Routes.orders),
                    child: Text(l10n.seeAll),
                  ),
                ],
              ),
            ),
            Entrance(index: 1, child: OrderTile(order: orders.first)),
          ],
          const SizedBox(height: 20),
          _MenuGroup(
            children: [
              _MenuTile(
                icon: Icons.receipt_long_rounded,
                title: l10n.ordersTitle,
                onTap: () => context.push(Routes.orders),
              ),
              _MenuTile(
                icon: Icons.system_update_rounded,
                title: l10n.updatesTitle,
                trailing: _UpdateBadge(state: update),
                onTap: () => context.push(Routes.updates),
              ),
              _MenuTile(
                icon: Icons.settings_rounded,
                title: l10n.settingsTitle,
                onTap: () => context.push(Routes.settings),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SectionHeaderPadding extends StatelessWidget {
  const SectionHeaderPadding({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.only(top: 24, bottom: 8), child: child);
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            child: Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _UpdateBadge extends StatelessWidget {
  const _UpdateBadge({required this.state});

  final UpdateState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final highlight =
        state.phase == UpdatePhase.available ||
        state.phase == UpdatePhase.readyToRestart;
    final label = switch (state.phase) {
      UpdatePhase.available => l10n.badgeNewUpdate,
      UpdatePhase.readyToRestart => l10n.restart,
      _ =>
        state.currentPatch == null
            ? l10n.noPatch
            : l10n.patchNumber(state.currentPatch!),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: highlight ? Palette.brandGradient : null,
        color: highlight
            ? null
            : Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: highlight ? Colors.white : null,
        ),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: 64),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    const tint = Palette.violet;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: tint),
      ),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
    );
  }
}
