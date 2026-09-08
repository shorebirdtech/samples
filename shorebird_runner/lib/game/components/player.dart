import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/animation.dart' show Curves;
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
    return fractionalLanePosition(lane.toDouble(), t);
  }

  static Offset fractionalLanePosition(double laneFrac, double t) {
    final tPow = pow(t, 1.6).toDouble();
    final clampedLane =
        laneFrac.clamp(0.0, (GameConfig.laneCount - 1).toDouble());
    final leftIdx = clampedLane.floor();
    final rightIdx = min(leftIdx + 1, GameConfig.laneCount - 1);
    final frac = clampedLane - leftIdx;

    final farX = GameConfig.farLaneX[leftIdx] +
        (GameConfig.farLaneX[rightIdx] - GameConfig.farLaneX[leftIdx]) * frac;
    final nearX = GameConfig.nearLaneX[leftIdx] +
        (GameConfig.nearLaneX[rightIdx] - GameConfig.nearLaneX[leftIdx]) * frac;
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
/// Zero blur passes for steady 120 FPS.
class Player extends Component {
  int currentLane;
  int _targetLane;
  double _laneProgress = 1.0;
  int _moveDirection = 0; // -1 left, +1 right

  final PlayerSkin skin;

  double _runPhase = 0.0;
  final List<_DashSpark> _particles = [];
  final Random _rng = Random();

  // Jump state
  bool _isJumping = false;
  double _jumpTime = 0.0;
  static const double _jumpDuration = 0.62;
  double _landingSquish = 0.0;

  // Slide state
  bool _isSliding = false;
  double _slideTime = 0.0;
  static const double _slideDuration = 0.65;

  // Invincibility / Hot Reload state
  double _invincibleTimer = 0.0;

  bool get isJumping => _isJumping;
  bool get isSliding => _isSliding;
  bool get isInvincible => _invincibleTimer > 0;

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

  void jump() {
    if (!_isJumping && !_isSliding) {
      _isJumping = true;
      _jumpTime = 0.0;
      AudioService.playJump();
    }
  }

  void slide() {
    if (!_isSliding) {
      if (_isJumping) {
        _isJumping = false;
        _jumpTime = 0.0;
      }
      _isSliding = true;
      _slideTime = 0.0;
      AudioService.playSlide();
    }
  }

  void triggerHotReload(double duration) {
    _invincibleTimer = duration;
    AudioService.playPowerUp();
  }

  double get jumpOffsetY {
    if (!_isJumping) return 0.0;
    final t = (_jumpTime / _jumpDuration).clamp(0.0, 1.0);
    return -sin(t * pi) * 78.0;
  }

  Offset get worldPosition {
    final baseOffset = () {
      if (_laneProgress >= 1.0) {
        return PerspectiveHelper.lanePosition(_targetLane, 1.0);
      }
      final from = PerspectiveHelper.lanePosition(currentLane, 1.0);
      final to = PerspectiveHelper.lanePosition(_targetLane, 1.0);
      final t = Curves.easeInOutCubic.transform(_laneProgress.clamp(0, 1));
      return Offset(from.dx + (to.dx - from.dx) * t, from.dy);
    }();

    return Offset(baseOffset.dx, baseOffset.dy + jumpOffsetY);
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

    // Update Jump
    if (_isJumping) {
      _jumpTime += dt;
      if (_jumpTime >= _jumpDuration) {
        _isJumping = false;
        _jumpTime = 0.0;
        _landingSquish = 1.0;
        final pos = worldPosition;
        for (int i = 0; i < 6; i++) {
          if (_particles.length < 24) {
            _particles.add(_DashSpark(
                Offset(pos.dx + (_rng.nextDouble() - 0.5) * 24, pos.dy + 34),
                _rng,
                _getAuraColor()));
          }
        }
      }
    }

    if (_landingSquish > 0) {
      _landingSquish = (_landingSquish - dt * 6.0).clamp(0.0, 1.0);
    }

    // Update Slide
    if (_isSliding) {
      _slideTime += dt;
      final pos = worldPosition;
      if (_particles.length < 24) {
        _particles.add(_DashSpark(
            Offset(pos.dx + (_rng.nextDouble() - 0.5) * 26, pos.dy + 30),
            _rng,
            const Color(0xFFFFB300)));
      }
      if (_slideTime >= _slideDuration) {
        _isSliding = false;
        _slideTime = 0.0;
      }
    }

    // Update Invincible / Hot Reload timer
    if (_invincibleTimer > 0) {
      _invincibleTimer = max(0.0, _invincibleTimer - dt);
      final pos = worldPosition;
      if (_particles.length < 24) {
        _particles.add(_DashSpark(
            Offset(pos.dx + (_rng.nextDouble() - 0.5) * 36,
                pos.dy + (_rng.nextDouble() - 0.5) * 30),
            _rng,
            const Color(0xFFFFD700)));
      }
    }

    _runPhase += dt * 14.0;

    // Spawn footstep cyber sparks on ground
    if (!_isJumping && !_isSliding) {
      final pos = worldPosition;
      final stride = sin(_runPhase);
      if (stride.abs() > 0.85 && _particles.length < 24) {
        final footX = pos.dx + (stride > 0 ? 12.0 : -12.0);
        final sparkColor = _getAuraColor();
        _particles.add(_DashSpark(Offset(footX, pos.dy + 32), _rng, sparkColor));
      }
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
    final groundPos = () {
      if (_laneProgress >= 1.0) {
        return PerspectiveHelper.lanePosition(_targetLane, 1.0);
      }
      final from = PerspectiveHelper.lanePosition(currentLane, 1.0);
      final to = PerspectiveHelper.lanePosition(_targetLane, 1.0);
      final t = Curves.easeInOutCubic.transform(_laneProgress.clamp(0, 1));
      return Offset(from.dx + (to.dx - from.dx) * t, from.dy);
    }();

    final shadowY = groundPos.dy + 34;
    final stepBounce = sin(_runPhase * 2).abs() * 3.0;

    final jumpT = _isJumping
        ? sin((_jumpTime / _jumpDuration).clamp(0.0, 1.0) * pi)
        : 0.0;
    final shadowScale =
        (1.0 - stepBounce * 0.03 - jumpT * 0.45).clamp(0.40, 1.2);
    final shadowAlpha = (0.58 - jumpT * 0.38).clamp(0.15, 0.58);

    // Multi-ring concentric soft shadow (hardware accelerated, zero blur pass)
    final shadowCenter = Offset(groundPos.dx, shadowY);
    canvas.drawOval(
      Rect.fromCenter(
        center: shadowCenter,
        width: 52 * shadowScale,
        height: 18 * shadowScale,
      ),
      Paint()..color = const Color(0xFF000000).withValues(alpha: shadowAlpha * 0.25),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: shadowCenter,
        width: 38 * shadowScale,
        height: 13 * shadowScale,
      ),
      Paint()..color = const Color(0xFF000000).withValues(alpha: shadowAlpha * 0.55),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: shadowCenter,
        width: 22 * shadowScale,
        height: 7 * shadowScale,
      ),
      Paint()..color = const Color(0xFF000000).withValues(alpha: shadowAlpha * 0.85),
    );
  }

  void _drawParticles(Canvas canvas) {
    for (final p in _particles) {
      p.render(canvas);
    }
  }

  void _drawRunningDeveloper(Canvas canvas) {
    final pos = worldPosition;
    final stepBounce =
        (_isJumping || _isSliding) ? 0.0 : sin(_runPhase * 2).abs() * 4.0;
    final shoulderTorque =
        (_isJumping || _isSliding) ? 0.0 : sin(_runPhase) * 0.04;
    final center = Offset(pos.dx, pos.dy - stepBounce);
    final roll = rollAngle;
    const size = GameConfig.playerNearSize; // 54

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(roll + shoulderTorque);

    // Landing Squash & Stretch
    if (_landingSquish > 0) {
      final squashX = 1.0 + _landingSquish * 0.28;
      final squashY = 1.0 - _landingSquish * 0.22;
      canvas.scale(squashX, squashY);
    }

    // Sliding Posture transform
    if (_isSliding) {
      canvas.translate(0, 14);
      canvas.scale(1.18, 0.58);
      canvas.rotate(-0.25);
    }

    // Jumping Posture transform
    if (_isJumping) {
      final t = (_jumpTime / _jumpDuration).clamp(0.0, 1.0);
      final leapTilt = (0.5 - t) * 0.35;
      canvas.rotate(leapTilt);
    }

    // Hot Reload invincibility energy shield
    if (isInvincible) {
      const shieldRadius = size * 0.88;
      final shieldPaint = Paint()
        ..shader = SweepGradient(
          colors: const [
            Color(0xFFFFD700),
            Color(0xFF00FFCC),
            Color(0xFFFF007F),
            Color(0xFFFFD700),
          ],
          transform: GradientRotation(_runPhase * 4),
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: shieldRadius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;
      canvas.drawCircle(const Offset(0, 2), shieldRadius, shieldPaint);

      // Outer aura ring
      canvas.drawCircle(
        const Offset(0, 2),
        shieldRadius + 4,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0,
      );

      // Orbiting Hexagonal Shield Nodes
      const nodeCount = 5;
      for (int i = 0; i < nodeCount; i++) {
        final nodeAngle = _runPhase * 3.5 + (i * 2 * pi / nodeCount);
        final nx = cos(nodeAngle) * (shieldRadius * 1.05);
        final ny = sin(nodeAngle) * (shieldRadius * 0.75) + 2;
        canvas.drawCircle(Offset(nx, ny), 5.5,
            Paint()..color = const Color(0xFF00FFCC).withValues(alpha: 0.35));
        canvas.drawCircle(Offset(nx, ny), 3.0,
            Paint()..color = const Color(0xFF00FFCC));
        canvas.drawCircle(Offset(nx, ny), 1.5,
            Paint()..color = const Color(0xFFFFFFFF));
      }
    }

    // Developer neon aura (concentric circles, zero blur overhead)
    final aura = _getAuraColor();
    final auraAlpha = isInvincible ? 0.35 : 0.16;
    canvas.drawCircle(const Offset(0, 4), size * 0.90,
        Paint()..color = aura.withValues(alpha: auraAlpha * 0.4));
    canvas.drawCircle(const Offset(0, 4), size * 0.65,
        Paint()..color = aura.withValues(alpha: auraAlpha));

    _drawLegs(canvas, size);
    _drawTorso(canvas, size);
    _drawHeadAndHeadphones(canvas, size);
    _drawArmsAndLaptop(canvas, size);

    canvas.restore();
  }

  void _drawLegs(Canvas canvas, double size) {
    final stride = sin(_runPhase);
    final r = size * 0.5;
    final colors = _getPantsColors();

    final hipY = r * 0.12;
    final legLength = r * 0.62;

    final leftFootSwing = stride * legLength;
    final rightFootSwing = -stride * legLength;

    final leftLegPath = Path()
      ..moveTo(-r * 0.22, hipY)
      ..lineTo(-r * 0.26, hipY + legLength * 0.55 + leftFootSwing * 0.2)
      ..lineTo(-r * 0.24, hipY + legLength + leftFootSwing)
      ..lineTo(-r * 0.12, hipY + legLength + leftFootSwing)
      ..lineTo(-r * 0.14, hipY + legLength * 0.55 + leftFootSwing * 0.2)
      ..lineTo(-r * 0.10, hipY)
      ..close();

    final rightLegPath = Path()
      ..moveTo(r * 0.10, hipY)
      ..lineTo(r * 0.14, hipY + legLength * 0.55 + rightFootSwing * 0.2)
      ..lineTo(r * 0.12, hipY + legLength + rightFootSwing)
      ..lineTo(r * 0.24, hipY + legLength + rightFootSwing)
      ..lineTo(r * 0.26, hipY + legLength * 0.55 + rightFootSwing * 0.2)
      ..lineTo(r * 0.22, hipY)
      ..close();

    final legPaint = Paint()
      ..color = colors[1]
      ..style = PaintingStyle.fill;
    canvas.drawPath(leftLegPath, legPaint);
    canvas.drawPath(rightLegPath, legPaint);

    final seamPaint = Paint()
      ..color = colors[2]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(leftLegPath, seamPaint);
    canvas.drawPath(rightLegPath, seamPaint);

    _drawRunningShoe(
      canvas,
      Offset(-r * 0.18, hipY + legLength + leftFootSwing),
      isLeft: true,
      scale: size / 54.0,
    );
    _drawRunningShoe(
      canvas,
      Offset(r * 0.18, hipY + legLength + rightFootSwing),
      isLeft: false,
      scale: size / 54.0,
    );
  }

  void _drawRunningShoe(Canvas canvas, Offset pos,
      {required bool isLeft, required double scale}) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    final shoePaint = Paint()..color = const Color(0xFF0F172A);
    final shoeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, 0), width: 14 * scale, height: 6 * scale),
      Radius.circular(2 * scale),
    );
    canvas.drawRRect(shoeRect, shoePaint);

    final soleColor = _getAuraColor();
    final solePaint = Paint()
      ..color = soleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * scale;
    canvas.drawLine(
      Offset(-6 * scale, 2.5 * scale),
      Offset(6 * scale, 2.5 * scale),
      solePaint,
    );

    // Sole neon glow flare (concentric)
    canvas.drawCircle(const Offset(0, 3.5), 7,
        Paint()..color = soleColor.withValues(alpha: 0.22));
    canvas.drawCircle(const Offset(0, 3.5), 4,
        Paint()..color = soleColor.withValues(alpha: 0.75));

    canvas.restore();
  }

  List<Color> _getPantsColors() {
    return const [
      Color(0xFF1E293B),
      Color(0xFF0F172A),
      Color(0xFF020617),
    ];
  }

  void _drawTorso(Canvas canvas, double size) {
    final r = size * 0.5;
    final colors = _getHoodieColors();

    final hoodieRect = Rect.fromCenter(
      center: Offset(0, -r * 0.08),
      width: r * 0.76,
      height: r * 0.72,
    );
    final hoodieRRect =
        RRect.fromRectAndRadius(hoodieRect, Radius.circular(r * 0.22));

    final hoodiePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [colors[0], colors[1], colors[2]],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(hoodieRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(hoodieRRect, hoodiePaint);

    final hoodCollarPath = Path()
      ..moveTo(-r * 0.32, -r * 0.40)
      ..quadraticBezierTo(0, -r * 0.22, r * 0.32, -r * 0.40)
      ..quadraticBezierTo(0, -r * 0.30, -r * 0.32, -r * 0.40)
      ..close();
    final hoodCollarPaint = Paint()
      ..color = colors[2]
      ..style = PaintingStyle.fill;
    canvas.drawPath(hoodCollarPath, hoodCollarPaint);

    _drawDeveloperEmblem(canvas, r);
  }

  void _drawDeveloperEmblem(Canvas canvas, double r) {
    final emblemCenter = Offset(0, -r * 0.04);
    final aura = _getAuraColor();

    final badgePaint = Paint()
      ..color = const Color(0xFF030712).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(emblemCenter, r * 0.24, badgePaint);

    final borderPaint = Paint()
      ..color = aura
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(emblemCenter, r * 0.24, borderPaint);

    // Multi-ring concentric glow behind emblem
    canvas.drawCircle(emblemCenter, r * 0.32,
        Paint()..color = aura.withValues(alpha: 0.18));
    canvas.drawCircle(emblemCenter, r * 0.26,
        Paint()..color = aura.withValues(alpha: 0.38));

    if (skin == PlayerSkin.blueBird) {
      final birdPath = Path()
        ..moveTo(emblemCenter.dx - 4, emblemCenter.dy + 3)
        ..cubicTo(emblemCenter.dx - 6, emblemCenter.dy, emblemCenter.dx - 2,
            emblemCenter.dy - 4, emblemCenter.dx + 3, emblemCenter.dy - 4)
        ..lineTo(emblemCenter.dx + 6, emblemCenter.dy - 2)
        ..lineTo(emblemCenter.dx + 2, emblemCenter.dy)
        ..cubicTo(emblemCenter.dx + 4, emblemCenter.dy + 4, emblemCenter.dx,
            emblemCenter.dy + 4, emblemCenter.dx - 4, emblemCenter.dy + 3);
      final birdPaint = Paint()
        ..color = const Color(0xFF00FFCC)
        ..style = PaintingStyle.fill;
      canvas.drawPath(birdPath, birdPaint);
    } else {
      final codePaint = Paint()
        ..color = aura
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(emblemCenter.dx - 5, emblemCenter.dy - 3),
          Offset(emblemCenter.dx - 8, emblemCenter.dy), codePaint);
      canvas.drawLine(Offset(emblemCenter.dx - 8, emblemCenter.dy),
          Offset(emblemCenter.dx - 5, emblemCenter.dy + 3), codePaint);

      canvas.drawLine(Offset(emblemCenter.dx - 1, emblemCenter.dy + 4),
          Offset(emblemCenter.dx + 1, emblemCenter.dy - 4), codePaint);

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
          Color(0xFF0284C7),
          Color(0xFF0369A1),
          Color(0xFF0C4A6E),
        ];
      case PlayerSkin.goldPhoenix:
        return const [
          Color(0xFFF59E0B),
          Color(0xFFD97706),
          Color(0xFF78350F),
        ];
      case PlayerSkin.emeraldFalcon:
        return const [
          Color(0xFF10B981),
          Color(0xFF059669),
          Color(0xFF064E3B),
        ];
      case PlayerSkin.violetRaven:
        return const [
          Color(0xFF8B5CF6),
          Color(0xFF7C3AED),
          Color(0xFF4C1D95),
        ];
    }
  }

  void _drawHeadAndHeadphones(Canvas canvas, double size) {
    final r = size * 0.5;
    final headCenter = Offset(0, -r * 0.58);
    final headRadius = r * 0.28;

    final hairPaint = Paint()
      ..color = const Color(0xFF1C1917)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(headCenter, headRadius, hairPaint);

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

    final aura = _getAuraColor();

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

    _drawCupEqualizer(canvas, Offset(-headRadius - 2.5, headCenter.dy + 1), aura);

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

  void _drawCupEqualizer(Canvas canvas, Offset center, Color color) {
    final eqPaint = Paint()
      ..color = color
      ..strokeWidth = 1.0;
    final h1 = (sin(_runPhase * 3) * 3).abs() + 2;
    final h2 = (cos(_runPhase * 2.5) * 4).abs() + 2;
    canvas.drawLine(Offset(center.dx - 1.5, center.dy - h1),
        Offset(center.dx - 1.5, center.dy + h1), eqPaint);
    canvas.drawLine(Offset(center.dx + 1.5, center.dy - h2),
        Offset(center.dx + 1.5, center.dy + h2), eqPaint);
  }

  void _drawArmsAndLaptop(Canvas canvas, double size) {
    final r = size * 0.5;
    final stride = sin(_runPhase);
    final colors = _getHoodieColors();

    final sleevePaint = Paint()
      ..color = colors.first
      ..style = PaintingStyle.fill;

    final skinPaint = Paint()
      ..color = const Color(0xFFFBBF24);

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
    canvas.drawCircle(leftHand, 4.0, skinPaint);

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
    canvas.drawCircle(rightHand, 4.0, skinPaint);

    _drawLaptop(canvas, Offset(rightHand.dx + 8, rightHand.dy - 6));
  }

  void _drawLaptop(Canvas canvas, Offset laptopPos) {
    canvas.save();
    canvas.translate(laptopPos.dx, laptopPos.dy);
    canvas.rotate(0.25);

    final lidRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-8, -12, 16, 12),
      const Radius.circular(2),
    );
    final lidPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(lidRect, lidPaint);

    final stickerPaint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(0, -6), 2.5, stickerPaint);

    final screenEdge = Paint()
      ..color = const Color(0xFF00FF88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(-7, 0), const Offset(7, 0), screenEdge);

    // Concentric screen glow (no blur)
    final screenGlowOuter = Paint()
      ..color = const Color(0xFF00FF88).withValues(alpha: 0.22);
    canvas.drawCircle(const Offset(0, 0), 7, screenGlowOuter);
    final screenGlowInner = Paint()
      ..color = const Color(0xFF00FF88).withValues(alpha: 0.65);
    canvas.drawCircle(const Offset(0, 0), 3.5, screenGlowInner);

    canvas.restore();
  }
}

class _DashSpark {
  Offset pos;
  final Offset vel;
  double life = 1.0;
  final Color color;

  static final Paint _sharedSparkOuter = Paint()..style = PaintingStyle.fill;
  static final Paint _sharedSparkInner = Paint()..style = PaintingStyle.fill;

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
    if (life <= 0) return;
    _sharedSparkOuter.color = color.withValues(alpha: life * 0.35);
    canvas.drawCircle(pos, 4.0 * life, _sharedSparkOuter);

    _sharedSparkInner.color = color.withValues(alpha: life * 0.90);
    canvas.drawCircle(pos, 1.8 * life, _sharedSparkInner);
  }
}
