import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:shorebird_runner/game/components/shooting_star.dart';
import 'package:shorebird_runner/game/components/star.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

/// Cinematic atmospheric night sky with multi-stop twilight gradients,
/// soft drifting glowing nebula dust, twinkling diffraction stars,
/// and periodic shooting stars / comets.
/// Dynamically fills 100% of the screen width and height down to horizon.
class Starfield extends Component {
  static final _rng = Random(42);

  final List<Star> _stars = [];
  final List<ShootingStar> _shootingStars = [];
  static const int _count = 120;
  double _shootingStarTimer = 2.0;
  double _nebulaPhase = 0.0;

  late Paint _skyPaint;
  final Paint _cyanNebulaPaint = Paint();
  final Paint _purpleNebulaPaint = Paint();

  @override
  Future<void> onLoad() async {
    _rebuildSkyPaint();
    _repopulateStars();
  }

  void _rebuildSkyPaint() {
    final w = GameConfig.designWidth;
    final h = GameConfig.horizonY + 20;

    _skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF030712),
          Color(0xFF070E20),
          Color(0xFF0E1A38),
          Color(0xFF1A1236),
          Color(0xFF140D26),
        ],
        stops: [0.0, 0.35, 0.65, 0.88, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Pre-cache nebula radial shaders centered at Offset.zero so render requires 0 allocations
    _cyanNebulaPaint.shader = RadialGradient(
      colors: [
        const Color(0xFF00D4FF).withValues(alpha: 0.12),
        const Color(0xFF0055AA).withValues(alpha: 0.05),
        const Color(0x00000000),
      ],
      radius: 0.85,
    ).createShader(
      Rect.fromCircle(center: Offset.zero, radius: 180),
    );

    _purpleNebulaPaint.shader = RadialGradient(
      colors: [
        const Color(0xFF9333EA).withValues(alpha: 0.14),
        const Color(0xFFEC4899).withValues(alpha: 0.04),
        const Color(0x00000000),
      ],
      radius: 0.85,
    ).createShader(
      Rect.fromCircle(center: Offset.zero, radius: 200),
    );
  }

  void _repopulateStars() {
    _stars.clear();
    for (int i = 0; i < _count; i++) {
      _stars.add(Star.random(_rng));
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _rebuildSkyPaint();
  }

  @override
  void update(double dt) {
    _nebulaPhase += dt * 0.15;

    for (final star in _stars) {
      star.update(dt);
    }

    // Spawn shooting stars periodically
    _shootingStarTimer -= dt;
    if (_shootingStarTimer <= 0) {
      _shootingStarTimer = 3.5 + _rng.nextDouble() * 4.5;
      if (_shootingStars.length < 3) {
        _shootingStars.add(ShootingStar(_rng));
      }
    }

    // Zero-allocation backwards loop for shooting stars
    for (int i = _shootingStars.length - 1; i >= 0; i--) {
      final ss = _shootingStars[i];
      ss.update(dt);
      if (ss.isDead) {
        _shootingStars.removeAt(i);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    _drawSkyGradient(canvas);
    _drawNebulaClouds(canvas);

    for (final star in _stars) {
      star.render(canvas);
    }

    for (final ss in _shootingStars) {
      ss.render(canvas);
    }
  }

  void _drawSkyGradient(Canvas canvas) {
    final w = GameConfig.designWidth;
    final h = GameConfig.horizonY + 20;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _skyPaint);
  }

  void _drawNebulaClouds(Canvas canvas) {
    final w = GameConfig.designWidth;
    final h = GameConfig.horizonY;
    final sin1 = sin(_nebulaPhase) * 20;
    final sin2 = cos(_nebulaPhase * 0.8) * 25;

    // Cyan cosmic dust cloud (left) - translated with zero allocations
    canvas.save();
    canvas.translate(w * 0.25 + sin1, h * 0.45);
    canvas.drawCircle(Offset.zero, 180, _cyanNebulaPaint);
    canvas.restore();

    // Violet/Magenta cosmic dust cloud (right) - translated with zero allocations
    canvas.save();
    canvas.translate(w * 0.75 + sin2, h * 0.4);
    canvas.drawCircle(Offset.zero, 200, _purpleNebulaPaint);
    canvas.restore();
  }
}
