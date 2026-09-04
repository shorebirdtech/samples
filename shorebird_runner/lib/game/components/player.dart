import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Curves;
import 'package:flutter/painting.dart';
import 'package:shorebird_runner/game/utils/audio_service.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

enum PlayerSkin { blueBird, goldPhoenix, emeraldFalcon, violetRaven }

/// Perspective helper: maps normalized depth t (0=horizon, 1=near player)
/// and lane index to a canvas position and scale factor.
class PerspectiveHelper {
  const PerspectiveHelper._();

  static Offset lanePosition(int lane, double t) {
    final tPow = pow(t, 1.6).toDouble();
    final nearX = GameConfig.nearLaneX[lane];
    final farX = GameConfig.farLaneX[lane];
    final x = farX + (nearX - farX) * tPow;
    final y =
        GameConfig.horizonY + (GameConfig.nearY - GameConfig.horizonY) * tPow;
    return Offset(x, y);
  }

  static double scaleAtDepth(double t) {
    final tPow = pow(t, 1.6).toDouble();
    return GameConfig.horizonSizeMultiplier +
        (1.0 - GameConfig.horizonSizeMultiplier) * tPow;
  }
}

/// The player character — stylized 3D bird with banking roll tilt,
/// grounded perspective shadow, and dual thruster particle trail.
class Player extends Component {
  int currentLane;
  int _targetLane;
  double _laneProgress = 1.0;
  int _moveDirection = 0; // -1 left, +1 right

  final PlayerSkin skin;

  double _bobPhase = 0;
  double _thrustPhase = 0;

  final List<_ThrusterParticle> _particles = [];
  final Random _rng = Random();

  Player({
    this.currentLane = 1,
    this.skin = PlayerSkin.blueBird,
  }) : _targetLane = 1;

  void moveLeft() {
    if (_targetLane > 0) {
      currentLane = _targetLane;
      _targetLane = _targetLane - 1;
      _laneProgress = 0;
      _moveDirection = -1;
      AudioService.playSwitch();
    }
  }

  void moveRight() {
    if (_targetLane < GameConfig.laneCount - 1) {
      currentLane = _targetLane;
      _targetLane = _targetLane + 1;
      _laneProgress = 0;
      _moveDirection = 1;
      AudioService.playSwitch();
    }
  }

  Offset get worldPosition {
    if (_laneProgress >= 1.0) {
      return PerspectiveHelper.lanePosition(_targetLane, 1.0);
    }
    final from = PerspectiveHelper.lanePosition(currentLane, 1.0);
    final to = PerspectiveHelper.lanePosition(_targetLane, 1.0);
    final t = Curves.easeInOutCubic.transform(_laneProgress.clamp(0, 1));
    return Offset(from.dx + (to.dx - from.dx) * t, from.dy);
  }

  double get rollAngle {
    if (_laneProgress >= 1.0) return 0.0;
    final bankAmount = sin(_laneProgress * pi);
    return _moveDirection * bankAmount * 0.38;
  }

  @override
  void update(double dt) {
    if (_laneProgress < 1.0) {
      _laneProgress =
          (_laneProgress + dt / GameConfig.laneChangeDuration).clamp(0, 1);
      if (_laneProgress >= 1.0) {
        currentLane = _targetLane;
        _moveDirection = 0;
      }
    }

    _bobPhase += dt * 3.5;
    _thrustPhase += dt * 10.0;

    // Thruster particles
    final pos = worldPosition;
    final bob = sin(_bobPhase) * 4;
    final roll = rollAngle;
    const wingSpan = 22.0;

    final leftX = pos.dx - cos(roll) * wingSpan;
    final leftY = pos.dy + bob - sin(roll) * wingSpan + 14;
    final rightX = pos.dx + cos(roll) * wingSpan;
    final rightY = pos.dy + bob + sin(roll) * wingSpan + 14;

    final particleColor = _getAuraColor();

    _particles
        .add(_ThrusterParticle(Offset(leftX, leftY), _rng, particleColor));
    _particles
        .add(_ThrusterParticle(Offset(rightX, rightY), _rng, particleColor));

    for (final p in _particles) {
      p.update(dt);
    }
    _particles.removeWhere((p) => p.life <= 0);
  }

  Color _getAuraColor() {
    switch (skin) {
      case PlayerSkin.blueBird:
        return const Color(GameConfig.colorCyan);
      case PlayerSkin.goldPhoenix:
        return const Color(GameConfig.colorAmber);
      case PlayerSkin.emeraldFalcon:
        return const Color(GameConfig.colorGreen);
      case PlayerSkin.violetRaven:
        return const Color(GameConfig.colorPurple);
    }
  }

  @override
  void render(Canvas canvas) {
    _drawShadow(canvas);
    _drawParticles(canvas);
    _drawBird(canvas);
  }

  void _drawShadow(Canvas canvas) {
    final pos = worldPosition;
    final shadowY = pos.dy + 24;
    final bob = sin(_bobPhase) * 4;
    final shadowScale = (1.0 - bob * 0.04).clamp(0.7, 1.2);

    final shadowPaint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pos.dx, shadowY),
        width: GameConfig.playerNearSize * 0.85 * shadowScale,
        height: 14 * shadowScale,
      ),
      shadowPaint,
    );
  }

  void _drawParticles(Canvas canvas) {
    for (final p in _particles) {
      p.render(canvas);
    }
  }

  void _drawBird(Canvas canvas) {
    final pos = worldPosition;
    final bob = sin(_bobPhase) * 4;
    final center = Offset(pos.dx, pos.dy + bob);
    const size = GameConfig.playerNearSize;
    final roll = rollAngle;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(roll);

    // Glowing aura
    final glowPaint = Paint()
      ..color = _getAuraColor().withValues(alpha: 0.35)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset.zero, size * 0.75, glowPaint);

    _drawWings(canvas, size * 0.55);
    _drawBody(canvas, size * 0.5);
    _drawBeak(canvas, size * 0.5);
    _drawGoggles(canvas, size * 0.5);

    canvas.restore();
  }

  void _drawBody(Canvas canvas, double r) {
    final bodyPath = Path()
      ..moveTo(0, -r * 1.35)
      ..cubicTo(r * 0.95, -r * 0.4, r * 0.75, r * 0.9, 0, r * 1.15)
      ..cubicTo(-r * 0.75, r * 0.9, -r * 0.95, -r * 0.4, 0, -r * 1.35);

    final List<Color> colors = _getBodyColors();

    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: colors,
        stops: const [0.0, 0.4, 0.8, 1.0],
        center: const Alignment(0, -0.35),
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r * 1.5))
      ..style = PaintingStyle.fill;

    canvas.drawPath(bodyPath, bodyPaint);

    final highlightPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(0, -r * 0.6), width: r * 0.5, height: r * 0.3),
      highlightPaint,
    );
  }

  List<Color> _getBodyColors() {
    switch (skin) {
      case PlayerSkin.blueBird:
        return const [
          Color(0xFF38BDF8),
          Color(GameConfig.colorCyan),
          Color(0xFF2563EB),
          Color(0xFF1E1B4B),
        ];
      case PlayerSkin.goldPhoenix:
        return const [
          Color(0xFFFFD166),
          Color(0xFFFFB347),
          Color(0xFFFF416C),
          Color(0xFF4A0E17),
        ];
      case PlayerSkin.emeraldFalcon:
        return const [
          Color(0xFF6EE7B7),
          Color(0xFF10B981),
          Color(0xFF047857),
          Color(0xFF064E3B),
        ];
      case PlayerSkin.violetRaven:
        return const [
          Color(0xFFC084FC),
          Color(0xFF8B5CF6),
          Color(0xFF6D28D9),
          Color(0xFF2E1065),
        ];
    }
  }

  void _drawWings(Canvas canvas, double r) {
    final wingThrust = sin(_thrustPhase) * 3;
    final List<Color> colors = _getWingColors();

    final wingPaint = Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r * 1.4))
      ..style = PaintingStyle.fill;

    final leftWing = Path()
      ..moveTo(-r * 0.35, -r * 0.2)
      ..cubicTo(-r * 1.6, -r * 0.3 + wingThrust, -r * 1.8, r * 0.3, -r * 0.45,
          r * 0.5)
      ..close();
    canvas.drawPath(leftWing, wingPaint);

    final rightWing = Path()
      ..moveTo(r * 0.35, -r * 0.2)
      ..cubicTo(
          r * 1.6, -r * 0.3 - wingThrust, r * 1.8, r * 0.3, r * 0.45, r * 0.5)
      ..close();
    canvas.drawPath(rightWing, wingPaint);
  }

  List<Color> _getWingColors() {
    switch (skin) {
      case PlayerSkin.blueBird:
        return const [Color(0xFF818CF8), Color(0xFF4338CA), Color(0xFF1E1B4B)];
      case PlayerSkin.goldPhoenix:
        return const [Color(0xFFFF8C42), Color(0xFFD90429), Color(0xFF3A0007)];
      case PlayerSkin.emeraldFalcon:
        return const [Color(0xFF34D399), Color(0xFF059669), Color(0xFF022C22)];
      case PlayerSkin.violetRaven:
        return const [Color(0xFFA78BFA), Color(0xFF5B21B6), Color(0xFF1E0741)];
    }
  }

  void _drawBeak(Canvas canvas, double r) {
    final beakPath = Path()
      ..moveTo(0, -r * 1.45)
      ..lineTo(r * 0.22, -r * 1.1)
      ..lineTo(-r * 0.22, -r * 1.1)
      ..close();

    final beakPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFAA00), Color(0xFFFF6600)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(-r * 0.25, -r * 1.5, r * 0.5, r * 0.45))
      ..style = PaintingStyle.fill;

    canvas.drawPath(beakPath, beakPaint);
  }

  void _drawGoggles(Canvas canvas, double r) {
    final visorRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(0, -r * 0.45), width: r * 0.95, height: r * 0.42),
      Radius.circular(r * 0.18),
    );

    final List<Color> colors =
        skin == PlayerSkin.blueBird || skin == PlayerSkin.emeraldFalcon
            ? const [Color(0xFF00F5D4), Color(0xFF00BBF9), Color(0xFF0A192F)]
            : const [Color(0xFFFFFFFF), Color(0xFFFFD166), Color(0xFF7F1D1D)];

    final visorPaint = Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(visorRect.outerRect)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(visorRect, visorPaint);

    final reflectPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(-r * 0.35, -r * 0.55),
      Offset(r * 0.1, -r * 0.55),
      reflectPaint,
    );
  }
}

class _ThrusterParticle {
  Offset pos;
  final Offset vel;
  double life = 1.0;
  final Color baseColor;

  _ThrusterParticle(this.pos, Random rng, this.baseColor)
      : vel = Offset(
          (rng.nextDouble() - 0.5) * 20,
          35 + rng.nextDouble() * 45,
        );

  void update(double dt) {
    pos = Offset(pos.dx + vel.dx * dt, pos.dy + vel.dy * dt);
    life = (life - dt * 4.5).clamp(0.0, 1.0);
  }

  void render(Canvas canvas) {
    final paint = Paint()
      ..color = baseColor.withValues(alpha: life * 0.75)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(pos, 3.5 * life, paint);
  }
}
