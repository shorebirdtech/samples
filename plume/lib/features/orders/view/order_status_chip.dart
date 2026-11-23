import 'package:material_ui/material_ui.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/data/models/order.dart';
import 'package:plume/l10n/l10n.dart';

extension OrderStatusX on OrderStatus {
  String label(AppLocalizations l10n) => switch (this) {
    OrderStatus.placed => l10n.statusPlaced,
    OrderStatus.packed => l10n.statusPacked,
    OrderStatus.shipped => l10n.statusShipped,
    OrderStatus.outForDelivery => l10n.statusOutForDelivery,
    OrderStatus.delivered => l10n.statusDelivered,
  };

  IconData get icon => switch (this) {
    OrderStatus.placed => Icons.receipt_rounded,
    OrderStatus.packed => Icons.inventory_2_rounded,
    OrderStatus.shipped => Icons.local_shipping_rounded,
    OrderStatus.outForDelivery => Icons.delivery_dining_rounded,
    OrderStatus.delivered => Icons.home_rounded,
  };

  Color get color =>
      this == OrderStatus.delivered ? Palette.success : Palette.violet;
}

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({required this.status, super.key});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          const SizedBox(width: 6),
          Text(
            status.label(context.l10n),
            style: TextStyle(
              color: status.color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
