import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Renders a 3-layer parallax starfield scrolling at different speeds,
/// creating a deep-space feel behind the runway.
class Starfield extends Component {
  static final _rng = Random(42);

  final List<_Star> _stars = [];
  static const int _count = 150;

  @override
  Future<void> onLoad() async {
    for (int i = 0; i < _count; i++) {
      _stars.add(_Star.random(_rng));
    }
  }

  @override
  void update(double dt) {
    for (final star in _stars) {
      star.update(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    for (final star in _stars) {
      star.render(canvas);
    }
  }
}

class _Star {
  double x;
  double y;
  final double speed;
  final double size;
  final double alpha;
  final double twinkleSpeed;
  double _twinklePhase;

  _Star({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.alpha,
    required this.twinkleSpeed,
    required double twinklePhase,
  }) : _twinklePhase = twinklePhase;

  factory _Star.random(Random rng) {
    return _Star(
      x: rng.nextDouble() * 800,
      y: rng.nextDouble() * 240, // only in upper sky area
      speed: 10 + rng.nextDouble() * 30,
      size: 0.5 + rng.nextDouble() * 2.0,
      alpha: 0.3 + rng.nextDouble() * 0.7,
      twinkleSpeed: 1 + rng.nextDouble() * 3,
      twinklePhase: rng.nextDouble() * pi * 2,
    );
  }

  void update(double dt) {
    _twinklePhase += dt * twinkleSpeed;
  }

  void render(Canvas canvas) {
    final currentAlpha =
        (alpha * (0.6 + 0.4 * sin(_twinklePhase))).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = _colorForAlpha(currentAlpha)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), size, paint);
  }

  Color _colorForAlpha(double a) {
    final v = (a * 255).round();
    // Slightly blue-tinted white for space feel
    return Color.fromARGB(v, 180, 220, 255);
  }
}
