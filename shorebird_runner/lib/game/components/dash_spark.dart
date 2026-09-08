import 'dart:math';
import 'package:flutter/painting.dart';

class DashSpark {
  Offset pos;
  final Offset vel;
  double life = 1.0;
  final Color color;

  static final Paint _sharedSparkOuter = Paint()..style = PaintingStyle.fill;
  static final Paint _sharedSparkInner = Paint()..style = PaintingStyle.fill;

  DashSpark(this.pos, Random rng, this.color)
      : vel = Offset(
          (rng.nextDouble() - 0.5) * 24,
          15 + rng.nextDouble() * 30,
        );

  void update(double dt) {
    pos = Offset(pos.dx + vel.dx * dt, pos.dy + vel.dy * dt);
    life = (life - dt * 4.2).clamp(0.0, 1.0);
  }

  void render(Canvas canvas) {
    if (life <= 0) return;
    _sharedSparkOuter.color = color.withValues(alpha: life * 0.35);
    canvas.drawCircle(pos, 4.0 * life, _sharedSparkOuter);

    _sharedSparkInner.color = color.withValues(alpha: life * 0.90);
    canvas.drawCircle(pos, 1.8 * life, _sharedSparkInner);
  }
}
