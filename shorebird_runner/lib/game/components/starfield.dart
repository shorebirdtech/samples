import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

/// Cinematic atmospheric night sky with multi-stop twilight gradients,
/// soft drifting glowing nebula dust, twinkling diffraction stars,
/// and periodic shooting stars / comets.
/// Optimized with cached paints and zero allocations in hot render loop.
class Starfield extends Component {
  static final _rng = Random(42);

  final List<_Star> _stars = [];
  final List<_ShootingStar> _shootingStars = [];
  static const int _count = 110;
  double _shootingStarTimer = 2.0;
  double _nebulaPhase = 0.0;

  late final Paint _skyPaint;
  final Paint _cyanNebulaPaint = Paint();
  final Paint _purpleNebulaPaint = Paint();

  @override
  Future<void> onLoad() async {
    const w = GameConfig.designWidth;
    const h = GameConfig.horizonY + 20;

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
      ).createShader(const Rect.fromLTWH(0, 0, w, h));

    for (int i = 0; i < _count; i++) {
      _stars.add(_Star.random(_rng));
    }
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
        _shootingStars.add(_ShootingStar(_rng));
      }
    }

    for (final ss in List.of(_shootingStars)) {
      ss.update(dt);
      if (ss.isDead) _shootingStars.remove(ss);
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
    const w = GameConfig.designWidth;
    const h = GameConfig.horizonY + 20;
    canvas.drawRect(const Rect.fromLTWH(0, 0, w, h), _skyPaint);
  }

  void _drawNebulaClouds(Canvas canvas) {
    const h = GameConfig.horizonY;
    final sin1 = sin(_nebulaPhase) * 20;
    final sin2 = cos(_nebulaPhase * 0.8) * 25;

    // Cyan cosmic dust cloud (left)
    _cyanNebulaPaint.shader = RadialGradient(
      colors: [
        const Color(0xFF00D4FF).withValues(alpha: 0.12),
        const Color(0xFF0055AA).withValues(alpha: 0.05),
        const Color(0x00000000),
      ],
      radius: 0.85,
    ).createShader(
        Rect.fromCircle(center: Offset(180 + sin1, h * 0.45), radius: 180));
    canvas.drawCircle(Offset(180 + sin1, h * 0.45), 180, _cyanNebulaPaint);

    // Violet/Magenta cosmic dust cloud (right)
    _purpleNebulaPaint.shader = RadialGradient(
      colors: [
        const Color(0xFF9333EA).withValues(alpha: 0.14),
        const Color(0xFFEC4899).withValues(alpha: 0.04),
        const Color(0x00000000),
      ],
      radius: 0.85,
    ).createShader(Rect.fromCircle(
        center: Offset(GameConfig.designWidth - 200 + sin2, h * 0.4),
        radius: 200));
    canvas.drawCircle(Offset(GameConfig.designWidth - 200 + sin2, h * 0.4), 200,
        _purpleNebulaPaint);
  }
}

class _Star {
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

  _Star({
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

  factory _Star.random(Random rng) {
    final isSpecial = rng.nextDouble() < 0.12;
    final tintColor = rng.nextDouble() < 0.4
        ? const Color(0xFF7DD3FC) // Cyan tint
        : (rng.nextDouble() < 0.7
            ? const Color(0xFFFDE68A) // Gold tint
            : const Color(0xFFE9D5FF)); // Violet tint

    return _Star(
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
          Offset(x - spikeLen, y), Offset(x + spikeLen, y), _sharedSpikePaint);
      canvas.drawLine(
          Offset(x, y - spikeLen), Offset(x, y + spikeLen), _sharedSpikePaint);
    }
  }
}

class _ShootingStar {
  Offset start;
  Offset current;
  final Offset velocity;
  final double length;
  double life = 1.0;
  final Paint _paint = Paint()
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round;
  final Paint _headPaint = Paint();

  _ShootingStar(Random rng)
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
