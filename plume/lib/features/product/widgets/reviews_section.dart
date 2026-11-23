import 'package:material_ui/material_ui.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/core/widgets/widgets.dart';
import 'package:plume/data/models/models.dart';
import 'package:plume/l10n/l10n.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({
    required this.product,
    required this.reviews,
    required this.histogram,
    super.key,
  });

  final Product product;
  final List<Review> reviews;
  final List<int> histogram;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final total = histogram.fold(0, (a, b) => a + b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              children: [
                Text(
                  product.rating.toStringAsFixed(1),
                  style: theme.textTheme.displaySmall,
                ),
                RatingStars(rating: product.rating),
                const SizedBox(height: 4),
                Text(
                  l10n.reviewCount(product.reviewCount),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                children: [
                  for (var i = 0; i < 5; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 14,
                            child: Text(
                              '${5 - i}',
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _Bar(
                              value: total == 0 ? 0 : histogram[i] / total,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final review in reviews)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Palette.iris.withValues(alpha: 0.2),
                      child: Text(
                        review.author[0],
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Palette.iris,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        review.author,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      l10n.daysAgo(review.daysAgo),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                RatingStars(rating: review.rating.toDouble(), size: 14),
                const SizedBox(height: 6),
                Text(review.title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(review.body, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value),
        duration: Motion.of(context, Motion.slow * 2),
        curve: Motion.emphasized,
        builder: (context, v, _) => LinearProgressIndicator(
          value: v,
          minHeight: 7,
          color: Palette.amber,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        ),
      ),
    );
  }
}
