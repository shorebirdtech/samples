import 'package:material_ui/material_ui.dart';
import 'package:plume/core/theme/palette.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({required this.rating, this.size = 16, super.key});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${rating.toStringAsFixed(1)} / 5',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            Icon(
              rating >= i
                  ? Icons.star_rounded
                  : rating >= i - 0.5
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
              size: size,
              color: Palette.amber,
            ),
        ],
      ),
    );
  }
}
