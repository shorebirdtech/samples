import 'dart:math';
import 'package:flutter/painting.dart';

class MagneticTrailParticle {
  Offset pos;
  final Offset velocity;
  final Color color;
  final double radius;
  double life = 1.0;

  MagneticTrailParticle(
    Offset origin,
    Random rng, {
    required double scale,
    bool isBooster = false,
    double dirX = 0.0,
  })  : pos = origin,
        velocity = Offset(
          dirX * (30 + rng.nextDouble() * 50),
          20 + rng.nextDouble() * 40,
        ),
        color = isBooster
            ? const Color(0xFFFFD700)
            : (rng.nextBool()
                ? const Color(0xFF00FFCC)
                : const Color(0xFFFFE066)),
        radius = (rng.nextDouble() * 2.5 + 2.0) * scale;

  void update(double dt) {
    pos += velocity * dt;
    life = (life - dt * 4.0).clamp(0.0, 1.0);
  }

  static final Paint _outerPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _innerPaint = Paint()..style = PaintingStyle.fill;

  void render(Canvas canvas) {
    if (life <= 0) return;
    _outerPaint.color = color.withValues(alpha: life * 0.35);
    canvas.drawCircle(pos, radius * life * 1.8, _outerPaint);

    _innerPaint.color = color.withValues(alpha: life * 0.90);
    canvas.drawCircle(pos, radius * life, _innerPaint);
  }
}
