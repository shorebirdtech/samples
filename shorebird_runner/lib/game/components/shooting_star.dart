import 'dart:math';
import 'package:flutter/painting.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

class ShootingStar {
  Offset start;
  Offset current;
  final Offset velocity;
  final double length;
  double life = 1.0;
  final Paint _paint = Paint()
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round;
  final Paint _headPaint = Paint();

  ShootingStar(Random rng)
      : start = Offset(
          rng.nextDouble() * GameConfig.designWidth,
          rng.nextDouble() * 110,
        ),
        velocity = Offset(
          -220 - rng.nextDouble() * 260,
          130 + rng.nextDouble() * 120,
        ),
        length = 40 + rng.nextDouble() * 50,
        current = Offset.zero {
    current = start;
  }

  bool get isDead => life <= 0;

  void update(double dt) {
    current =
        Offset(current.dx + velocity.dx * dt, current.dy + velocity.dy * dt);
    life = (life - dt * 1.8).clamp(0.0, 1.0);
  }

  void render(Canvas canvas) {
    if (life <= 0) return;
    final dir = velocity / velocity.distance;
    final tail = Offset(current.dx - dir.dx * length * life,
        current.dy - dir.dy * length * life);

    _paint.shader = LinearGradient(
      colors: [
        const Color(0xFFFFFFFF).withValues(alpha: life),
        const Color(0xFF00D4FF).withValues(alpha: life * 0.6),
        const Color(0x00000000),
      ],
    ).createShader(Rect.fromPoints(current, tail));

    canvas.drawLine(current, tail, _paint);
    _headPaint.color = const Color(0xFFFFFFFF).withValues(alpha: life);
    canvas.drawCircle(current, 2.2 * life, _headPaint);
  }
}
