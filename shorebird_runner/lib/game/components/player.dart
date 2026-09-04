import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Curves, Colors;
import 'package:flutter/painting.dart';
import 'package:shorebird_runner/game/utils/audio_service.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

enum PlayerSkin { blueBird, goldPhoenix, emeraldFalcon, violetRaven }

extension PlayerSkinDetails on PlayerSkin {
  String get displayName {
    switch (this) {
      case PlayerSkin.blueBird:
        return 'Shorebird Dev';
      case PlayerSkin.goldPhoenix:
        return 'Frontend Ninja';
      case PlayerSkin.emeraldFalcon:
        return 'Fullstack Hero';
      case PlayerSkin.violetRaven:
        return 'Bug Hunter';
    }
  }

  String get roleTitle {
    switch (this) {
      case PlayerSkin.blueBird:
        return 'CodePush Specialist';
      case PlayerSkin.goldPhoenix:
        return 'UI / Flutter Architect';
      case PlayerSkin.emeraldFalcon:
        return 'Fullstack Hacker';
      case PlayerSkin.violetRaven:
        return 'QA Bug Terminator';
    }
  }

  String get emoji {
    switch (this) {
      case PlayerSkin.blueBird:
        return '👨‍💻';
      case PlayerSkin.goldPhoenix:
        return '🧑‍💻';
      case PlayerSkin.emeraldFalcon:
        return '⚡';
      case PlayerSkin.violetRaven:
        return '👾';
    }
  }
}

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

/// The player character — an animated 3D human developer seen from behind,
/// sprinting down the 3-lane production highway with alternating running legs,
/// running shoes, hoodie with code emblem, over-ear cyber headphones,
/// a laptop gripped in hand, and footstep neon dash sparks.
class Player extends Component {
  int currentLane;
  int _targetLane;
  double _laneProgress = 1.0;
  int _moveDirection = 0; // -1 left, +1 right

  final PlayerSkin skin;

  double _runPhase = 0.0;
  final List<_DashSpark> _particles = [];
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
    return _moveDirection * bankAmount * 0.32;
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

    _runPhase += dt * 14.0; // Rapid running stride cadence

    // Spawn footstep cyber sparks on ground
    final pos = worldPosition;
    final stride = sin(_runPhase);
    if (stride.abs() > 0.85) {
      final footX = pos.dx + (stride > 0 ? 12.0 : -12.0);
      final sparkColor = _getAuraColor();
      _particles.add(_DashSpark(Offset(footX, pos.dy + 32), _rng, sparkColor));
    }

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
    _drawRunningDeveloper(canvas);
  }

  void _drawShadow(Canvas canvas) {
    final pos = worldPosition;
    final shadowY = pos.dy + 34;
    final stepBounce = sin(_runPhase * 2).abs() * 3.0;
    final shadowScale = (1.0 - stepBounce * 0.03).clamp(0.8, 1.2);

    final shadowPaint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: 0.58)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pos.dx, shadowY),
        width: 46 * shadowScale,
        height: 16 * shadowScale,
      ),
      shadowPaint,
    );
  }

  void _drawParticles(Canvas canvas) {
    for (final p in _particles) {
      p.render(canvas);
    }
  }

  void _drawRunningDeveloper(Canvas canvas) {
    final pos = worldPosition;
    final stepBounce = sin(_runPhase * 2).abs() * 4.0;
    final shoulderTorque = sin(_runPhase) * 0.04;
    final center = Offset(pos.dx, pos.dy - stepBounce);
    final roll = rollAngle;
    const size = GameConfig.playerNearSize; // 54

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(roll + shoulderTorque);

    // Subtle developer neon aura
    final glowPaint = Paint()
      ..color = _getAuraColor().withValues(alpha: 0.25)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(const Offset(0, 4), size * 0.72, glowPaint);

    // Render developer parts from back to front
    _drawLegs(canvas, size);
    _drawTorso(canvas, size);
    _drawHeadAndHeadphones(canvas, size);
    _drawArmsAndLaptop(canvas, size);

    canvas.restore();
  }

  void _drawLegs(Canvas canvas, double size) {
    final stride = sin(_runPhase); // -1.0 to +1.0
    final r = size * 0.5;

    final pantsPaint = Paint()
      ..shader = LinearGradient(
        colors: _getPantsColors(),
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(-r, 0, r * 2, r * 1.5))
      ..style = PaintingStyle.fill;

    final shoeAura = _getAuraColor();

    // Left Leg
    final leftStride = stride;
    final leftHipX = -r * 0.32;
    final leftHipY = r * 0.35;
    final leftKneeX = leftHipX - leftStride * 2.5;
    final leftKneeY = leftHipY + r * 0.45;
    final leftFootX = leftHipX - leftStride * r * 0.28;
    final leftFootY = leftHipY + r * 0.85 + leftStride * r * 0.22;

    final leftLegPath = Path()
      ..moveTo(leftHipX - 5, leftHipY)
      ..lineTo(leftHipX + 5, leftHipY)
      ..lineTo(leftKneeX + 4.5, leftKneeY)
      ..lineTo(leftFootX + 4, leftFootY - 4)
      ..lineTo(leftFootX - 4, leftFootY - 4)
      ..lineTo(leftKneeX - 4.5, leftKneeY)
      ..close();
    canvas.drawPath(leftLegPath, pantsPaint);
    _drawSneaker(canvas, Offset(leftFootX, leftFootY), shoeAura, leftStride);

    // Right Leg
    final rightStride = -stride;
    final rightHipX = r * 0.32;
    final rightHipY = r * 0.35;
    final rightKneeX = rightHipX - rightStride * 2.5;
    final rightKneeY = rightHipY + r * 0.45;
    final rightFootX = rightHipX - rightStride * r * 0.28;
    final rightFootY = rightHipY + r * 0.85 + rightStride * r * 0.22;

    final rightLegPath = Path()
      ..moveTo(rightHipX - 5, rightHipY)
      ..lineTo(rightHipX + 5, rightHipY)
      ..lineTo(rightKneeX + 4.5, rightKneeY)
      ..lineTo(rightFootX + 4, rightFootY - 4)
      ..lineTo(rightFootX - 4, rightFootY - 4)
      ..lineTo(rightKneeX - 4.5, rightKneeY)
      ..close();
    canvas.drawPath(rightLegPath, pantsPaint);
    _drawSneaker(canvas, Offset(rightFootX, rightFootY), shoeAura, rightStride);
  }

  void _drawSneaker(
      Canvas canvas, Offset footPos, Color soleColor, double stride) {
    canvas.save();
    canvas.translate(footPos.dx, footPos.dy);

    // Shoe body
    final shoeRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-7, -5, 14, 8),
      const Radius.circular(3),
    );
    final shoePaint = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawRRect(shoeRect, shoePaint);

    // Heel tab
    final heelPaint = Paint()..color = const Color(0xFF64748B);
    canvas.drawRect(const Rect.fromLTWH(-5, -6, 10, 3), heelPaint);

    // Glowing Sole
    final solePaint = Paint()..color = soleColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8, 2, 16, 3.5),
        const Radius.circular(1.5),
      ),
      solePaint,
    );

    // Sole neon glow flare
    final soleGlow = Paint()
      ..color = soleColor.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(const Offset(0, 3.5), 5, soleGlow);

    canvas.restore();
  }

  List<Color> _getPantsColors() {
    return const [
      Color(0xFF1E293B), // Slate 800
      Color(0xFF0F172A), // Slate 900
      Color(0xFF020617), // Slate 950
    ];
  }

  void _drawTorso(Canvas canvas, double size) {
    final r = size * 0.5;

    // Hoodie Body
    final hoodiePath = Path()
      ..moveTo(-r * 0.52, -r * 0.32) // Left shoulder
      ..lineTo(r * 0.52, -r * 0.32) // Right shoulder
      ..lineTo(r * 0.38, r * 0.40) // Right hip
      ..lineTo(-r * 0.38, r * 0.40) // Left hip
      ..close();

    final List<Color> colors = _getHoodieColors();

    final hoodiePaint = Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(-r * 0.6, -r * 0.4, r * 1.2, r * 0.9))
      ..style = PaintingStyle.fill;

    canvas.drawPath(hoodiePath, hoodiePaint);

    // Hoodie fabric crease / pocket seam at waist
    final seamPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(-r * 0.30, r * 0.26),
      Offset(r * 0.30, r * 0.26),
      seamPaint,
    );

    // Folded Hood at the neck
    final hoodCollarPath = Path()
      ..moveTo(-r * 0.34, -r * 0.30)
      ..cubicTo(-r * 0.20, -r * 0.12, r * 0.20, -r * 0.12, r * 0.34, -r * 0.30)
      ..cubicTo(
          r * 0.20, -r * 0.22, -r * 0.20, -r * 0.22, -r * 0.34, -r * 0.30);

    final hoodCollarPaint = Paint()
      ..color = colors.last.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    canvas.drawPath(hoodCollarPath, hoodCollarPaint);

    // Glowing Developer Emblem on Back of Hoodie
    _drawDeveloperEmblem(canvas, r);
  }

  void _drawDeveloperEmblem(Canvas canvas, double r) {
    final emblemCenter = Offset(0, -r * 0.04);
    final aura = _getAuraColor();

    // Emblem Badge Circle / Hexagon
    final badgePaint = Paint()
      ..color = const Color(0xFF030712).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(emblemCenter, r * 0.24, badgePaint);

    final borderPaint = Paint()
      ..color = aura
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(emblemCenter, r * 0.24, borderPaint);

    // Glow aura behind emblem
    final emblemGlow = Paint()
      ..color = aura.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(emblemCenter, r * 0.24, emblemGlow);

    // Draw Shorebird 🐤 / Code brackets on the badge
    if (skin == PlayerSkin.blueBird) {
      // Shorebird Bird Silhouette on cyan hoodie
      final birdPath = Path()
        ..moveTo(emblemCenter.dx - 4, emblemCenter.dy + 3)
        ..cubicTo(emblemCenter.dx - 6, emblemCenter.dy, emblemCenter.dx - 2,
            emblemCenter.dy - 4, emblemCenter.dx + 3, emblemCenter.dy - 4)
        ..lineTo(emblemCenter.dx + 6, emblemCenter.dy - 2) // beak
        ..lineTo(emblemCenter.dx + 2, emblemCenter.dy)
        ..cubicTo(emblemCenter.dx + 4, emblemCenter.dy + 4, emblemCenter.dx,
            emblemCenter.dy + 4, emblemCenter.dx - 4, emblemCenter.dy + 3);
      final birdPaint = Paint()
        ..color = const Color(0xFF00FFCC)
        ..style = PaintingStyle.fill;
      canvas.drawPath(birdPath, birdPaint);
    } else {
      // Code brackets < / >
      final codePaint = Paint()
        ..color = aura
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;

      // '<'
      canvas.drawLine(Offset(emblemCenter.dx - 5, emblemCenter.dy - 3),
          Offset(emblemCenter.dx - 8, emblemCenter.dy), codePaint);
      canvas.drawLine(Offset(emblemCenter.dx - 8, emblemCenter.dy),
          Offset(emblemCenter.dx - 5, emblemCenter.dy + 3), codePaint);

      // '/'
      canvas.drawLine(Offset(emblemCenter.dx - 1, emblemCenter.dy + 4),
          Offset(emblemCenter.dx + 1, emblemCenter.dy - 4), codePaint);

      // '>'
      canvas.drawLine(Offset(emblemCenter.dx + 5, emblemCenter.dy - 3),
          Offset(emblemCenter.dx + 8, emblemCenter.dy), codePaint);
      canvas.drawLine(Offset(emblemCenter.dx + 8, emblemCenter.dy),
          Offset(emblemCenter.dx + 5, emblemCenter.dy + 3), codePaint);
    }
  }

  List<Color> _getHoodieColors() {
    switch (skin) {
      case PlayerSkin.blueBird:
        return const [
          Color(0xFF0284C7), // Sky 600
          Color(0xFF0369A1), // Sky 700
          Color(0xFF0C4A6E), // Sky 900
        ];
      case PlayerSkin.goldPhoenix:
        return const [
          Color(0xFFF59E0B), // Amber 500
          Color(0xFFD97706), // Amber 600
          Color(0xFF78350F), // Amber 900
        ];
      case PlayerSkin.emeraldFalcon:
        return const [
          Color(0xFF10B981), // Emerald 500
          Color(0xFF059669), // Emerald 600
          Color(0xFF064E3B), // Emerald 900
        ];
      case PlayerSkin.violetRaven:
        return const [
          Color(0xFF8B5CF6), // Purple 500
          Color(0xFF7C3AED), // Purple 600
          Color(0xFF4C1D95), // Purple 900
        ];
    }
  }

  void _drawHeadAndHeadphones(Canvas canvas, double size) {
    final r = size * 0.5;
    final headCenter = Offset(0, -r * 0.58);
    final headRadius = r * 0.28;

    // Head / Hair (seen from back)
    final hairPaint = Paint()
      ..color = const Color(0xFF1C1917) // Dark espresso / charcoal hair
      ..style = PaintingStyle.fill;
    canvas.drawCircle(headCenter, headRadius, hairPaint);

    // Hair texture highlights
    final hairHighlight = Paint()
      ..color = const Color(0xFF44403C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCircle(center: headCenter, radius: headRadius - 1.5),
      pi * 1.1,
      pi * 0.8,
      false,
      hairHighlight,
    );

    // Over-ear Cyber Headphones
    final aura = _getAuraColor();

    // Headband
    final bandPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: headCenter, radius: headRadius + 2.0),
      pi * 1.12,
      pi * 0.76,
      false,
      bandPaint,
    );

    // Headband neon trim
    final bandTrimPaint = Paint()
      ..color = aura
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: headCenter, radius: headRadius + 2.0),
      pi * 1.18,
      pi * 0.64,
      false,
      bandTrimPaint,
    );

    // Left Ear Cup
    final leftCupRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(-headRadius - 2.5, headCenter.dy + 1),
        width: 6.5,
        height: 14,
      ),
      const Radius.circular(3),
    );
    final cupPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(leftCupRect, cupPaint);

    final cupGlow = Paint()
      ..color = aura
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawRRect(leftCupRect, cupGlow);

    // Right Ear Cup
    final rightCupRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(headRadius + 2.5, headCenter.dy + 1),
        width: 6.5,
        height: 14,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(rightCupRect, cupPaint);
    canvas.drawRRect(rightCupRect, cupGlow);
  }

  void _drawArmsAndLaptop(Canvas canvas, double size) {
    final r = size * 0.5;
    final stride = sin(_runPhase);
    final colors = _getHoodieColors();

    final sleevePaint = Paint()
      ..color = colors.first
      ..style = PaintingStyle.fill;

    final skinPaint = Paint()
      ..color = const Color(0xFFFBBF24); // Hand skin tone

    // Left Arm (Swings in counter-phase to left leg)
    final leftArmSwing = -stride * r * 0.22;
    final leftShoulder = Offset(-r * 0.50, -r * 0.28);
    final leftHand = Offset(-r * 0.62, r * 0.05 + leftArmSwing);

    final leftArmPath = Path()
      ..moveTo(leftShoulder.dx, leftShoulder.dy)
      ..lineTo(leftShoulder.dx - 8, leftShoulder.dy + 6)
      ..lineTo(leftHand.dx, leftHand.dy)
      ..lineTo(leftHand.dx + 7, leftHand.dy + 2)
      ..lineTo(leftShoulder.dx + 4, leftShoulder.dy + 12)
      ..close();
    canvas.drawPath(leftArmPath, sleevePaint);
    canvas.drawCircle(leftHand, 4.0, skinPaint); // Left fist

    // Right Arm (Holding Developer Laptop / Device)
    final rightArmSwing = stride * r * 0.12;
    final rightShoulder = Offset(r * 0.50, -r * 0.28);
    final rightHand = Offset(r * 0.52, r * 0.02 + rightArmSwing);

    final rightArmPath = Path()
      ..moveTo(rightShoulder.dx, rightShoulder.dy)
      ..lineTo(rightShoulder.dx + 8, rightShoulder.dy + 6)
      ..lineTo(rightHand.dx + 6, rightHand.dy)
      ..lineTo(rightHand.dx - 2, rightHand.dy + 6)
      ..lineTo(rightShoulder.dx - 4, rightShoulder.dy + 12)
      ..close();
    canvas.drawPath(rightArmPath, sleevePaint);
    canvas.drawCircle(rightHand, 4.0, skinPaint); // Right hand gripping laptop

    // Glowing Cyber Laptop held in right hand
    _drawLaptop(canvas, Offset(rightHand.dx + 8, rightHand.dy - 6));
  }

  void _drawLaptop(Canvas canvas, Offset laptopPos) {
    canvas.save();
    canvas.translate(laptopPos.dx, laptopPos.dy);
    canvas.rotate(0.25); // Angled forward under the arm

    // Laptop Clamshell Lid
    final lidRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-8, -12, 16, 12),
      const Radius.circular(2),
    );
    final lidPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(lidRect, lidPaint);

    // Glowing Shorebird / Flutter Sticker on laptop lid
    final stickerPaint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(0, -6), 2.5, stickerPaint);

    // Glowing Laptop Screen Edge / Code Glow
    final screenEdge = Paint()
      ..color = const Color(0xFF00FF88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(-7, 0), const Offset(7, 0), screenEdge);

    final screenGlow = Paint()
      ..color = const Color(0xFF00FF88).withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(const Offset(0, 0), 4, screenGlow);

    canvas.restore();
  }
}

class _DashSpark {
  Offset pos;
  final Offset vel;
  double life = 1.0;
  final Color color;

  _DashSpark(this.pos, Random rng, this.color)
      : vel = Offset(
          (rng.nextDouble() - 0.5) * 24,
          15 + rng.nextDouble() * 30,
        );

  void update(double dt) {
    pos = Offset(pos.dx + vel.dx * dt, pos.dy + vel.dy * dt);
    life = (life - dt * 4.2).clamp(0.0, 1.0);
  }

  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color.withValues(alpha: life * 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(pos, 2.8 * life, paint);
  }
}
