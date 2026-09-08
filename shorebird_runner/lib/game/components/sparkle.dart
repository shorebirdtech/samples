import 'dart:math';
import 'package:flutter/painting.dart';

class Sparkle {
  Offset pos;
  final Offset velocity;
  final Color color;
  final double radius;
  double life = 1.0;

  Sparkle(Offset origin, Random rng, {bool isBooster = false})
      : pos = origin,
        velocity = Offset(
          (rng.nextDouble() - 0.5) * (isBooster ? 260 : 190),
          -rng.nextDouble() * (isBooster ? 220 : 170) - 40,
        ),
        color = isBooster
            ? (rng.nextBool()
                ? const Color(0xFFFFD700)
                : (rng.nextBool()
                    ? const Color(0xFFFF007F)
                    : const Color(0xFF00FFCC)))
            : (rng.nextBool()
                ? const Color(0xFF00E5FF)
                : const Color(0xFFFFD700)),
        radius = rng.nextDouble() * 3.5 + 2.0;

  void update(double dt) {
    pos += velocity * dt;
    life = (life - dt * 2.8).clamp(0.0, 1.0);
  }

  void render(Canvas canvas) {
    if (life <= 0) return;
    final outerPaint = Paint()
      ..color = color.withValues(alpha: life * 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, radius * life * 1.8, outerPaint);

    final innerPaint = Paint()
      ..color = color.withValues(alpha: life * 0.90)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, radius * life, innerPaint);
  }
}
