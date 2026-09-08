import 'dart:math';
import 'package:flutter/painting.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

class Star {
  double x;
  double y;
  final double speed;
  final double size;
  final double alpha;
  final double twinkleSpeed;
  final bool hasCrossGlint;
  final Color tint;
  double _twinklePhase;

  static final Paint _sharedStarPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _sharedSpikePaint = Paint()..strokeWidth = 0.9;

  Star({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.alpha,
    required this.twinkleSpeed,
    required this.hasCrossGlint,
    required this.tint,
    required double twinklePhase,
  }) : _twinklePhase = twinklePhase;

  factory Star.random(Random rng) {
    final isSpecial = rng.nextDouble() < 0.12;
    final tintColor = rng.nextDouble() < 0.4
        ? const Color(0xFF7DD3FC) // Cyan tint
        : (rng.nextDouble() < 0.7
            ? const Color(0xFFFDE68A) // Gold tint
            : const Color(0xFFE9D5FF)); // Violet tint

    return Star(
      x: rng.nextDouble() * GameConfig.designWidth,
      y: rng.nextDouble() * (GameConfig.horizonY - 10),
      speed: 8 + rng.nextDouble() * 24,
      size: isSpecial
          ? 1.8 + rng.nextDouble() * 1.4
          : 0.6 + rng.nextDouble() * 1.1,
      alpha: isSpecial
          ? 0.8 + rng.nextDouble() * 0.2
          : 0.25 + rng.nextDouble() * 0.6,
      twinkleSpeed: 1.2 + rng.nextDouble() * 3.5,
      twinklePhase: rng.nextDouble() * pi * 2,
      hasCrossGlint: isSpecial,
      tint: tintColor,
    );
  }

  void update(double dt) {
    _twinklePhase += dt * twinkleSpeed;
  }

  void render(Canvas canvas) {
    final currentAlpha =
        (alpha * (0.55 + 0.45 * sin(_twinklePhase))).clamp(0.0, 1.0);
    _sharedStarPaint.color = tint.withValues(alpha: currentAlpha);

    canvas.drawCircle(Offset(x, y), size, _sharedStarPaint);

    if (hasCrossGlint && currentAlpha > 0.65) {
      final spikeLen = size * 2.8 * currentAlpha;
      _sharedSpikePaint.color = tint.withValues(alpha: currentAlpha * 0.5);
      canvas.drawLine(
        Offset(x - spikeLen, y),
        Offset(x + spikeLen, y),
        _sharedSpikePaint,
      );
      canvas.drawLine(
        Offset(x, y - spikeLen),
        Offset(x, y + spikeLen),
        _sharedSpikePaint,
      );
    }
  }
}
