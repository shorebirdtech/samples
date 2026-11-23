import 'package:material_ui/material_ui.dart';
import 'package:plume/core/money.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/core/widgets/widgets.dart';
import 'package:plume/features/cart/domain/price_calculator.dart';
import 'package:plume/l10n/l10n.dart';

/// The itemised totals. Used in the cart, checkout and order receipt.
class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({required this.summary, super.key});

  final OrderSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _Row(label: l10n.subtotal, money: summary.subtotal),
          SmoothSize(
            child: summary.discount.isZero
                ? const SizedBox(width: double.infinity)
                : _Row(
                    label: summary.promotion == null
                        ? l10n.discount
                        : l10n.discountWithCode(summary.promotion!.code),
                    money: summary.discount,
                    prefix: '−',
                    color: Palette.success,
                  ),
          ),
          _Row(
            label: l10n.shipping,
            money: summary.shipping,
            freeLabel: l10n.free,
          ),
          _Row(
            label: l10n.estimatedTax(PriceCalculator.taxRatePercent),
            money: summary.tax,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            children: [
              Text(l10n.total, style: theme.textTheme.titleLarge),
              const Spacer(),
              AnimatedMoney(
                summary.total,
                style: theme.textTheme.headlineSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.money,
    this.prefix = '',
    this.color,
    this.freeLabel,
  });

  final String label;
  final Money money;
  final String prefix;
  final Color? color;

  /// Shown instead of a zero amount, e.g. "Free" for shipping.
  final String? freeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyLarge?.copyWith(color: color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color:
                    color ?? theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          if (freeLabel != null && money.isZero)
            Text(
              freeLabel!,
              style: style?.copyWith(
                color: Palette.success,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            AnimatedMoney(money, prefix: prefix, style: style),
        ],
      ),
    );
  }
}
