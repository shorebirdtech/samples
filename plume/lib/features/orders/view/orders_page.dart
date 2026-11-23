import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/app/router.dart';
import 'package:plume/core/widgets/widgets.dart';
import 'package:plume/data/models/order.dart';
import 'package:plume/features/orders/orders_cubit.dart';
import 'package:plume/features/orders/view/order_status_chip.dart';
import 'package:plume/l10n/l10n.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final orders = context.select<OrdersCubit, List<Order>>(
      (c) => c.state.orders,
    );
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.profile),
        ),
        title: Text(l10n.ordersTitle),
      ),
      body: orders.isEmpty
          ? EmptyState(
              icon: Icons.receipt_long_rounded,
              title: l10n.ordersEmptyTitle,
              message: l10n.ordersEmptyMessage,
              action: FilledButton(
                onPressed: () => context.go(Routes.discover),
                child: Text(l10n.startShopping),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => Entrance(
                index: index,
                child: OrderTile(order: orders[index]),
              ),
            ),
    );
  }
}

class OrderTile extends StatelessWidget {
  const OrderTile({required this.order, super.key});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final l10n = context.l10n;
    return Pressable(
      scale: 0.98,
      semanticLabel: order.id,
      onTap: () => context.push(Routes.order(order.id)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(order.id, style: theme.textTheme.titleMedium),
                ),
                OrderStatusChip(status: order.statusAt(DateTime.now())),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormat.yMMMd(locale).format(order.placedAt)} · '
              '${l10n.itemCount(order.itemCount)} · '
              '${order.total.format(locale)}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: order.lines.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final line = order.lines[index];
                  return SizedBox.square(
                    dimension: 48,
                    child: ProductArt(
                      icon: line.icon,
                      color: Color(line.colorValue),
                      borderRadius: 12,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
