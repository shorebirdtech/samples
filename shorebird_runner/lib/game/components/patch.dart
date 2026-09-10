import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:shorebird_runner/game/components/magnetic_trail_particle.dart';
import 'package:shorebird_runner/game/components/perspective_helper.dart';
import 'package:shorebird_runner/game/components/sparkle.dart';
import 'package:shorebird_runner/game/utils/audio_service.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

/// A glowing 3D Shorebird OTA Patch collectible.
/// Represents an instant code patch deployed by Shorebird (🐤)
/// to bypass App Store and Play Store review delays.
/// Features magnetic tractor-beam pull towards player during Hot Reload,
/// concentric soft glows, and pre-cached text rendering for 120 FPS performance.
class Patch extends Component {
  int lane;
  double laneFractional;
  double depth;
  final bool isHotReloadBooster;
  bool isCollected = false;
  bool hasTriggeredMiss = false;
  bool isBeingMagnetized = false;
  double _magnetLean = 0.0;
  double _collectAnimation = 0;
  double _spinPhase;
  double _pulsePhase;
  int totalPatches = 0;
  bool isInvincible = false;
  final Random _rng;

  final void Function(Offset pos)? onMissed;
  final List<Sparkle> _sparkles = [];
  final List<MagneticTrailParticle> _magnetParticles = [];

  static final TextPainter _staticChickPainter = TextPainter(
    text: const TextSpan(
      text: '🐤',
      style: TextStyle(fontSize: 24),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  Patch({
    required this.lane,
    required Random rng,
    this.isHotReloadBooster = false,
    this.onMissed,
  })  : _rng = rng,
        laneFractional = lane.toDouble(),
        depth = 0,
        _spinPhase = rng.nextDouble() * pi * 2,
        _pulsePhase = rng.nextDouble() * pi * 2;

  void attractTowards(int targetLane, double dt) {
    if (isCollected) return;
    isBeingMagnetized = true;

    final diff = targetLane - laneFractional;
    final pullSpeed = 4.8 + depth * 4.2;
    laneFractional += diff * (dt * pullSpeed).clamp(0.0, 1.0);
    _magnetLean = (diff * 0.38).clamp(-0.4, 0.4);

    if (diff.abs() < 0.06) {
      lane = targetLane;
    }

    if (_rng.nextDouble() < 0.6 && _magnetParticles.length < 20) {
      final pos = worldPosition;
      final scale = worldScale;
      _magnetParticles.add(
        MagneticTrailParticle(
          pos,
          _rng,
          scale: scale,
          isBooster: isHotReloadBooster,
          dirX: diff > 0 ? -1.0 : 1.0,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    if (!isCollected) {
      final speed =
          GameConfig.scrollSpeed(totalPatches, isInvincible: isInvincible);
      final forwardBoost = isBeingMagnetized ? 1.18 : 1.0;
      depth += dt * speed * 0.54 * forwardBoost;
      _spinPhase += dt * (isHotReloadBooster ? 4.8 : 3.6);
      _pulsePhase += dt * (isHotReloadBooster ? 7.0 : 5.0);

      if (!isBeingMagnetized) {
        _magnetLean *= (1.0 - dt * 5.0).clamp(0.0, 1.0);
      }

      for (final mp in _magnetParticles) {
        mp.update(dt);
      }
      _magnetParticles.removeWhere((mp) => mp.life <= 0);

      if (depth >= 1.04 && !hasTriggeredMiss) {
        hasTriggeredMiss = true;
        if (!isHotReloadBooster) {
          onMissed?.call(worldPosition);
        }
      }
    } else {
      _collectAnimation = (_collectAnimation + dt * 3.5).clamp(0, 1);
      for (final s in _sparkles) {
        s.update(dt);
      }
    }
  }

  bool get isPastPlayer => depth >= 1.06;
  bool get isDone => isCollected && _collectAnimation >= 1.0;

  Offset get worldPosition =>
      PerspectiveHelper.fractionalLanePosition(laneFractional, depth);
  double get worldScale => PerspectiveHelper.scaleAtDepth(depth);

  void collect() {
    if (isCollected) return;
    isCollected = true;
    if (isHotReloadBooster) {
      AudioService.playPowerUp();
    } else {
      AudioService.playPatch();
    }

    final pos = worldPosition;
    final rng = Random();
    final count = isHotReloadBooster ? 24 : 18;
    for (int i = 0; i < count; i++) {
      _sparkles.add(Sparkle(pos, rng, isBooster: isHotReloadBooster));
    }
  }

  @override
  void render(Canvas canvas) {
    if (isDone) return;

    if (isCollected) {
      _drawSparkles(canvas);
      return;
    }

    _drawMagnetParticles(canvas);

    final pos = worldPosition;
    final scale = worldScale;
    final size = (isHotReloadBooster
            ? GameConfig.patchNearSize * 1.15
            : GameConfig.patchNearSize) *
        scale;

    _drawShadow(canvas, pos, scale);
    if (isHotReloadBooster) {
      _drawHotReloadBooster(canvas, pos, scale, size);
    } else {
      _drawShorebirdPatch(canvas, pos, scale, size);
    }
  }

  static final Paint _shadowOuterPaint = Paint()
    ..color = const Color(0x28000000);
  static final Paint _shadowInnerPaint = Paint()
    ..color = const Color(0x66000000);
  static final Paint _magGlowOuterPaint = Paint();
  static final Paint _magGlowInnerPaint = Paint();
  static final Paint _fluxPaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _ambientGlowOuterPaint = Paint();
  static final Paint _ambientGlowInnerPaint = Paint();
  static final Paint _gyroRingPaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _badgeBorderPaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _boosterRingPaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _boltPaint = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.fill;
  static final Paint _boltBorderPaint = Paint()..style = PaintingStyle.stroke;

  static const Rect _unitRect = Rect.fromLTWH(-50, -50, 100, 100);
  static final RRect _unitRRect =
      RRect.fromRectAndRadius(_unitRect, const Radius.circular(19));

  static final Paint _frontBadgePaint = Paint()
    ..shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF00F0FF),
        Color(0xFF0088FF),
        Color(0xFF0D1B3A),
      ],
      stops: [0.0, 0.5, 1.0],
    ).createShader(_unitRect)
    ..style = PaintingStyle.fill;

  static final Paint _backBadgePaint = Paint()
    ..shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0088FF),
        Color(0xFF0055BB),
        Color(0xFF060D1E),
      ],
      stops: [0.0, 0.5, 1.0],
    ).createShader(_unitRect)
    ..style = PaintingStyle.fill;

  static final Paint _boosterCorePaint = Paint()
    ..shader = const LinearGradient(
      colors: [
        Color(0xFFFFEE00),
        Color(0xFFFF8800),
        Color(0xFFFF0055),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(_unitRect)
    ..style = PaintingStyle.fill;

  static const Rect _beamRect = Rect.fromLTWH(-8, -90, 16, 90);
  static final Paint _beamPaint = Paint()
    ..shader = const LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        Color(0x4D00E5FF),
        Color(0x0000E5FF),
      ],
    ).createShader(_beamRect);

  static final Path _reusableBoltPath = Path();

  void _drawShadow(Canvas canvas, Offset pos, double scale) {
    final shadowCenter = Offset(pos.dx, pos.dy + 8 * scale);
    final sw = GameConfig.patchNearSize * 0.95 * scale;
    final sh = 12 * scale;
    canvas.drawOval(
      Rect.fromCenter(
        center: shadowCenter,
        width: sw * 1.3,
        height: sh * 1.3,
      ),
      _shadowOuterPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: shadowCenter,
        width: sw,
        height: sh,
      ),
      _shadowInnerPaint,
    );
  }

  void _drawShorebirdPatch(
    Canvas canvas,
    Offset pos,
    double scale,
    double size,
  ) {
    final hoverBob = sin(_pulsePhase) * 5 * scale;
    final patchPos = Offset(pos.dx, pos.dy - 12 * scale + hoverBob);

    canvas.save();
    canvas.translate(patchPos.dx, patchPos.dy);
    if (_magnetLean.abs() > 0.01) {
      canvas.rotate(_magnetLean);
    }

    final cosSpin = cos(_spinPhase);
    final absCos = cosSpin.abs().clamp(0.12, 1.0);
    final isFront = cosSpin >= 0;

    // Radiant Golden/Cyan Magnetic Attraction Field
    if (isBeingMagnetized) {
      _magGlowOuterPaint.color =
          const Color(0xFFFFD700).withValues(alpha: 0.20 * scale);
      canvas.drawCircle(
        Offset.zero,
        size * 1.05,
        _magGlowOuterPaint,
      );
      _magGlowInnerPaint.color =
          const Color(0xFFFFD700).withValues(alpha: 0.45 * scale);
      canvas.drawCircle(
        Offset.zero,
        size * 0.75,
        _magGlowInnerPaint,
      );

      _fluxPaint
        ..color = const Color(0xFF00FFCC).withValues(alpha: 0.85 * scale)
        ..strokeWidth = 1.8 * scale;
      final fluxRadius = size * (0.85 + sin(_pulsePhase * 3) * 0.12);
      canvas.drawCircle(Offset.zero, fluxRadius, _fluxPaint);
    }

    // Vertical holographic light beam shooting into sky (scaled via canvas)
    canvas.save();
    canvas.scale(scale, scale);
    canvas.drawRect(
      _beamRect,
      _beamPaint,
    );
    canvas.restore();

    // 1. Radiant Cyan/Gold Ambient Glow
    _ambientGlowOuterPaint.color =
        const Color(0xFF00D4FF).withValues(alpha: 0.16 * scale);
    canvas.drawCircle(
      Offset.zero,
      size * 0.85,
      _ambientGlowOuterPaint,
    );
    _ambientGlowInnerPaint.color =
        const Color(0xFF00D4FF).withValues(alpha: 0.38 * scale);
    canvas.drawCircle(
      Offset.zero,
      size * 0.58,
      _ambientGlowInnerPaint,
    );

    // Concentric Holographic Gyroscope Orbiting Rings
    _gyroRingPaint
      ..color = const Color(0xFF00FFCC).withValues(alpha: 0.75 * scale)
      ..strokeWidth = 1.6 * scale;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: size * 1.2 * absCos,
        height: size * 1.2,
      ),
      _gyroRingPaint,
    );

    // 2. Futuristic Hexagonal OTA Patch Badge
    final r = size * 0.55;
    final badgeW = r * 1.8 * absCos;
    final badgeH = r * 1.8;

    canvas.save();
    canvas.scale(badgeW / 100, badgeH / 100);
    canvas.drawRRect(
      _unitRRect,
      isFront ? _frontBadgePaint : _backBadgePaint,
    );

    // Outer Crisp Neon Rim
    _badgeBorderPaint
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = (2.2 * scale * absCos) * (100 / badgeH);
    canvas.drawRRect(
      _unitRRect,
      _badgeBorderPaint,
    );
    canvas.restore();

    // 🐤 Shorebird Baby Chick Symbol in center (cached TextPainter)
    canvas.save();
    final chickScale = (badgeH * 0.58) / 24.0;
    canvas.scale(absCos * chickScale, chickScale);
    _staticChickPainter.paint(
      canvas,
      Offset(-_staticChickPainter.width / 2, -_staticChickPainter.height / 2),
    );
    canvas.restore();

    canvas.restore();
  }

  void _drawHotReloadBooster(
    Canvas canvas,
    Offset pos,
    double scale,
    double size,
  ) {
    final hoverBob = sin(_pulsePhase) * 6 * scale;
    final patchPos = Offset(pos.dx, pos.dy - 14 * scale + hoverBob);

    canvas.save();
    canvas.translate(patchPos.dx, patchPos.dy);

    final cosSpin = cos(_spinPhase);
    final absCos = cosSpin.abs().clamp(0.2, 1.0);

    // Radiant Gold / Crimson Energy Aura (concentric glow)
    _magGlowOuterPaint.color =
        const Color(0xFFFFD700).withValues(alpha: 0.22 * scale);
    canvas.drawCircle(
      Offset.zero,
      size * 0.95,
      _magGlowOuterPaint,
    );
    _magGlowInnerPaint.color =
        const Color(0xFFFFD700).withValues(alpha: 0.50 * scale);
    canvas.drawCircle(
      Offset.zero,
      size * 0.65,
      _magGlowInnerPaint,
    );

    // Outer rotating energy ring
    _boosterRingPaint
      ..color = const Color(0xFF00FFCC).withValues(alpha: 0.7 * scale)
      ..strokeWidth = 2.0 * scale;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: size * 1.3 * absCos,
        height: size * 1.3,
      ),
      _boosterRingPaint,
    );

    // Octagonal Core
    final r = size * 0.58;
    final coreW = r * 1.8 * absCos;
    final coreH = r * 1.8;

    canvas.save();
    canvas.scale(coreW / 100, coreH / 100);
    canvas.drawRRect(
      _unitRRect,
      _boosterCorePaint,
    );
    canvas.restore();

    // ⚡ Lightning Bolt Emblem (reusable path)
    canvas.save();
    canvas.scale(absCos, 1.0);
    _reusableBoltPath
      ..reset()
      ..moveTo(2 * scale, -r * 0.65)
      ..lineTo(-r * 0.45, 0)
      ..lineTo(-1 * scale, 0)
      ..lineTo(-3 * scale, r * 0.65)
      ..lineTo(r * 0.45, -1 * scale)
      ..lineTo(1 * scale, -1 * scale)
      ..close();

    canvas.drawPath(_reusableBoltPath, _boltPaint);

    _boltBorderPaint
      ..color = const Color(0xFFFF0055)
      ..strokeWidth = 1.5 * scale;
    canvas.drawPath(_reusableBoltPath, _boltBorderPaint);
    canvas.restore();

    canvas.restore();
  }

  void _drawSparkles(Canvas canvas) {
    for (final s in _sparkles) {
      s.render(canvas);
    }
  }

  void _drawMagnetParticles(Canvas canvas) {
    for (final mp in _magnetParticles) {
      mp.render(canvas);
    }
  }
}
