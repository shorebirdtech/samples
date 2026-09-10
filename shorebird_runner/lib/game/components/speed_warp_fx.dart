import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:shorebird_runner/game/components/perspective_helper.dart';

/// High-speed hyperdrive warp streaks and dynamic electric speed lines.
/// Zero-allocation rendering with pooled static Paint objects.
/// Activates dynamically as speed escalates or during Hot Reload booster phases.
class SpeedWarpFx extends Component {
  static const int _maxLines = 14;
  final List<_WarpStreak> _streaks = [];
  final Random _rng = Random(77);

  static final Paint _streakPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  static final Paint _corePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xFFFFFFFF);

  bool isHotReload = false;
  double speedMultiplier = 1.0;

  @override
  Future<void> onLoad() async {
    for (int i = 0; i < _maxLines; i++) {
      _streaks.add(_WarpStreak.random(_rng));
    }
  }

  @override
  void update(double dt) {
    final intensity =
        (isHotReload ? 2.2 : (speedMultiplier - 0.95) * 1.5).clamp(0.0, 2.5);

    if (intensity <= 0.05) return;

    for (int i = 0; i < _streaks.length; i++) {
      _streaks[i].update(dt * intensity, _rng);
    }
  }

  @override
  void render(Canvas canvas) {
    final intensity =
        (isHotReload ? 2.2 : (speedMultiplier - 0.95) * 1.5).clamp(0.0, 2.5);

    if (intensity <= 0.05) return;

    final alpha = (intensity * 0.45).clamp(0.0, 0.85);

    for (int i = 0; i < _streaks.length; i++) {
      final s = _streaks[i];
      if (s.depth < 0.08 || s.depth > 1.05) continue;

      final p1 = PerspectiveHelper.fractionalLanePosition(s.laneFrac, s.depth);
      final tailDepth = (s.depth - s.length).clamp(0.02, 1.0);
      final p0 =
          PerspectiveHelper.fractionalLanePosition(s.laneFrac, tailDepth);

      final strokeW = (1.5 + s.depth * 3.5).clamp(1.0, 5.0);
      final lineAlpha =
          (alpha * s.alphaScale * (s.depth * 1.2)).clamp(0.0, 0.95);

      final streakColor = isHotReload
          ? (s.isGold ? const Color(0xFFFFD700) : const Color(0xFFFF007F))
          : const Color(0xFF00E5FF);

      _streakPaint
        ..color = streakColor.withValues(alpha: lineAlpha * 0.5)
        ..strokeWidth = strokeW * 1.8;
      canvas.drawLine(p0, p1, _streakPaint);

      _corePaint
        ..color = const Color(0xFFFFFFFF).withValues(alpha: lineAlpha)
        ..strokeWidth = strokeW * 0.7;
      canvas.drawLine(p0, p1, _corePaint);
    }
  }
}

class _WarpStreak {
  double laneFrac;
  double depth;
  double length;
  double speed;
  double alphaScale;
  bool isGold;

  _WarpStreak({
    required this.laneFrac,
    required this.depth,
    required this.length,
    required this.speed,
    required this.alphaScale,
    required this.isGold,
  });

  factory _WarpStreak.random(Random rng) {
    final isLeft = rng.nextBool();
    final laneFrac = isLeft
        ? -0.35 - rng.nextDouble() * 0.45
        : 2.35 + rng.nextDouble() * 0.45;

    return _WarpStreak(
      laneFrac: laneFrac,
      depth: rng.nextDouble(),
      length: 0.08 + rng.nextDouble() * 0.12,
      speed: 1.2 + rng.nextDouble() * 1.8,
      alphaScale: 0.6 + rng.nextDouble() * 0.4,
      isGold: rng.nextBool(),
    );
  }

  void update(double step, Random rng) {
    depth += step * speed;
    if (depth > 1.1) {
      depth = 0.02;
      final isLeft = rng.nextBool();
      laneFrac = isLeft
          ? -0.35 - rng.nextDouble() * 0.45
          : 2.35 + rng.nextDouble() * 0.45;
      length = 0.08 + rng.nextDouble() * 0.12;
      speed = 1.2 + rng.nextDouble() * 1.8;
      isGold = rng.nextBool();
    }
  }
}
