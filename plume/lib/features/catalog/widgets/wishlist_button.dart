import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/features/wishlist/wishlist_cubit.dart';
import 'package:plume/l10n/l10n.dart';

/// A heart that pops and throws sparks when a product is saved.
class WishlistButton extends StatefulWidget {
  const WishlistButton({
    required this.productId,
    this.size = 40,
    this.filledBackground = true,
    super.key,
  });

  final String productId;
  final double size;
  final bool filledBackground;

  @override
  State<WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<WishlistButton>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle(bool saved) {
    unawaited(HapticFeedback.mediumImpact());
    if (!saved && !Motion.reduced(context)) {
      _controller.forward(from: 0);
    }
    unawaited(context.read<WishlistCubit>().toggle(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    final saved = context.select<WishlistCubit, bool>(
      (c) => c.state.contains(widget.productId),
    );
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      toggled: saved,
      label: saved ? l10n.removeFromWishlist : l10n.addToWishlist,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => _toggle(saved),
        child: SizedBox.square(
          dimension: widget.size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              final pop = t == 0
                  ? 1.0
                  : 1 + 0.35 * math.sin(math.min(t * 2, 1) * math.pi);
              return CustomPaint(
                painter: _SparkPainter(t),
                child: Transform.scale(scale: pop, child: child),
              );
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.filledBackground
                    ? scheme.surface.withValues(alpha: 0.9)
                    : Colors.transparent,
              ),
              child: Icon(
                saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: widget.size * 0.55,
                color: saved ? Palette.coral : scheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t == 0 || t == 1) return;
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = Palette.coral.withValues(alpha: 1 - t)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.4;
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final direction = Offset(math.cos(angle), math.sin(angle));
      final start = center + direction * size.width * (0.4 + 0.3 * t);
      final end = center + direction * size.width * (0.5 + 0.45 * t);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(_SparkPainter oldDelegate) => oldDelegate.t != t;
}
