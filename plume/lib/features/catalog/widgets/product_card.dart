import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/app/router.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/core/widgets/widgets.dart';
import 'package:plume/data/models/product.dart';
import 'package:plume/features/catalog/widgets/price_tag.dart';
import 'package:plume/features/catalog/widgets/wishlist_button.dart';
import 'package:plume/l10n/l10n.dart';

/// Hero tag shared by a product's card and its detail page.
String productHeroTag(String scope, String productId) =>
    'product-$scope-$productId';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.heroScope,
    this.width,
    super.key,
  });

  final Product product;

  /// Distinguishes the same product shown in two sections of one screen.
  final String heroScope;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tag = productHeroTag(heroScope, product.id);
    return Pressable(
      semanticLabel: product.name,
      onTap: () => context.push(Routes.product(product.id, hero: tag)),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fills whatever the rail or grid cell leaves after the text, so
            // the card never overflows at large text sizes.
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: tag,
                    child: ProductArt(
                      icon: product.icon,
                      color: product.colors.first.color,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: WishlistButton(productId: product.id, size: 36),
                  ),
                  if (product.isOnSale || product.isNew)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: ProductBadge(product: product),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.brand.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 1.2,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: PriceTag(product: product)),
                const Icon(Icons.star_rounded, size: 16, color: Palette.amber),
                const SizedBox(width: 2),
                Text(
                  product.rating.toStringAsFixed(1),
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductBadge extends StatelessWidget {
  const ProductBadge({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sale = product.isOnSale;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: sale ? Palette.coral : Palette.ink.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        sale ? l10n.percentOff(product.discountPercent) : l10n.badgeNew,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
