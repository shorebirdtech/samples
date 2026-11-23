import 'package:material_ui/material_ui.dart';
import 'package:plume/data/models/product.dart';

class PriceTag extends StatelessWidget {
  const PriceTag({required this.product, this.large = false, super.key});

  final Product product;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final style = large
        ? theme.textTheme.headlineSmall
        : theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 8,
      children: [
        Text(product.price.format(locale), style: style),
        if (product.isOnSale)
          Text(
            product.compareAtPrice!.format(locale),
            style:
                (large
                        ? theme.textTheme.titleMedium
                        : theme.textTheme.bodySmall)
                    ?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.45,
                      ),
                    ),
          ),
      ],
    );
  }
}
