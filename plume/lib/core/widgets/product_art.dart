import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:plume/core/widgets/app_icons.dart';

/// Product artwork: the product glyph on a soft tint of its colour.
///
/// Generated rather than photographed, so the app ships with no image assets
/// and every colour variant renders instantly.
class ProductArt extends StatelessWidget {
  const ProductArt({
    required this.icon,
    required this.color,
    this.borderRadius = 16,
    this.iconScale = 0.42,
    this.tilt = 0,
    super.key,
  });

  final String icon;
  final Color color;
  final double borderRadius;
  final double iconScale;

  /// Rotates the glyph slightly, for parallax in carousels.
  final double tilt;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = Color.lerp(
      color,
      isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF3F3F1),
      isDark ? 0.82 : 0.86,
    )!;
    // Very light products (cream, sand) need a darker glyph to stay visible.
    final hsl = HSLColor.fromColor(color);
    final glyph = hsl.lightness > 0.7
        ? hsl.withLightness(0.45).toColor()
        : color;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: ColoredBox(
        color: background,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest.shortestSide;
            return Center(
              child: Transform.rotate(
                angle: tilt * math.pi / 12,
                child: Icon(
                  AppIcons.of(icon),
                  size: size * iconScale,
                  color: glyph,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
