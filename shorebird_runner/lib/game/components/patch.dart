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
      _magnetParticles.add(MagneticTrailParticle(
        pos,
        _rng,
        scale: scale,
        isBooster: isHotReloadBooster,
        dirX: diff > 0 ? -1.0 : 1.0,
      ));
    }
  }

  @override
  void update(double dt) {
    if (!isCollected) {
      final speed = GameConfig.scrollSpeed(totalPatches);
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

  void _drawShadow(Canvas canvas, Offset pos, double scale) {
    final shadowCenter = Offset(pos.dx, pos.dy + 8 * scale);
    final sw = GameConfig.patchNearSize * 0.95 * scale;
    final sh = 12 * scale;
    canvas.drawOval(
      Rect.fromCenter(center: shadowCenter, width: sw * 1.3, height: sh * 1.3),
      Paint()..color = const Color(0x28000000),
    );
    canvas.drawOval(
      Rect.fromCenter(center: shadowCenter, width: sw, height: sh),
      Paint()..color = const Color(0x66000000),
    );
  }

  void _drawShorebirdPatch(
      Canvas canvas, Offset pos, double scale, double size) {
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
      canvas.drawCircle(
          Offset.zero,
          size * 1.05,
          Paint()
            ..color = const Color(0xFFFFD700).withValues(alpha: 0.20 * scale));
      canvas.drawCircle(
          Offset.zero,
          size * 0.75,
          Paint()
            ..color = const Color(0xFFFFD700).withValues(alpha: 0.45 * scale));

      final fluxPaint = Paint()
        ..color = const Color(0xFF00FFCC).withValues(alpha: 0.85 * scale)
        ..strokeWidth = 1.8 * scale
        ..style = PaintingStyle.stroke;
      final fluxRadius = size * (0.85 + sin(_pulsePhase * 3) * 0.12);
      canvas.drawCircle(Offset.zero, fluxRadius, fluxPaint);
    }

    // Vertical holographic light beam shooting into sky
    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0.30 * scale),
          const Color(0xFF00E5FF).withValues(alpha: 0.0),
        ],
      ).createShader(
          Rect.fromLTWH(-8 * scale, -90 * scale, 16 * scale, 90 * scale));
    canvas.drawRect(
        Rect.fromLTWH(-8 * scale, -90 * scale, 16 * scale, 90 * scale),
        beamPaint);

    // 1. Radiant Cyan/Gold Ambient Glow (concentric circles, zero blur overhead)
    canvas.drawCircle(
        Offset.zero,
        size * 0.85,
        Paint()
          ..color = const Color(0xFF00D4FF).withValues(alpha: 0.16 * scale));
    canvas.drawCircle(
        Offset.zero,
        size * 0.58,
        Paint()
          ..color = const Color(0xFF00D4FF).withValues(alpha: 0.38 * scale));

    // Concentric Holographic Gyroscope Orbiting Rings
    final ring1Paint = Paint()
      ..color = const Color(0xFF00FFCC).withValues(alpha: 0.75 * scale)
      ..strokeWidth = 1.6 * scale
      ..style = PaintingStyle.stroke;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset.zero,
            width: size * 1.2 * absCos,
            height: size * 1.2),
        ring1Paint);

    // 2. Futuristic Hexagonal OTA Patch Badge
    final r = size * 0.55;
    final badgeW = r * 1.8 * absCos;
    final badgeH = r * 1.8;

    final patchRect =
        Rect.fromCenter(center: Offset.zero, width: badgeW, height: badgeH);
    final rrect =
        RRect.fromRectAndRadius(patchRect, Radius.circular(r * 0.38 * absCos));

    // Badge Gradient (Shorebird Cyan into Deep Indigo)
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isFront
            ? const [Color(0xFF00F0FF), Color(0xFF0088FF), Color(0xFF0D1B3A)]
            : const [Color(0xFF0088FF), Color(0xFF0055BB), Color(0xFF060D1E)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(patchRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, bgPaint);

    // Outer Crisp Neon Rim
    final borderPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 2.2 * scale * absCos
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, borderPaint);

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
      Canvas canvas, Offset pos, double scale, double size) {
    final hoverBob = sin(_pulsePhase) * 6 * scale;
    final patchPos = Offset(pos.dx, pos.dy - 14 * scale + hoverBob);

    canvas.save();
    canvas.translate(patchPos.dx, patchPos.dy);

    final cosSpin = cos(_spinPhase);
    final absCos = cosSpin.abs().clamp(0.2, 1.0);

    // Radiant Gold / Crimson Energy Aura (concentric glow)
    canvas.drawCircle(
        Offset.zero,
        size * 0.95,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.22 * scale));
    canvas.drawCircle(
        Offset.zero,
        size * 0.65,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.50 * scale));

    // Outer rotating energy ring
    final ringPaint = Paint()
      ..color = const Color(0xFF00FFCC).withValues(alpha: 0.7 * scale)
      ..strokeWidth = 2.0 * scale
      ..style = PaintingStyle.stroke;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset.zero,
            width: size * 1.3 * absCos,
            height: size * 1.3),
        ringPaint);

    // Octagonal Core
    final r = size * 0.58;
    final coreRect = Rect.fromCenter(
        center: Offset.zero, width: r * 1.8 * absCos, height: r * 1.8);
    final coreRRect =
        RRect.fromRectAndRadius(coreRect, Radius.circular(r * 0.4 * absCos));

    final corePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFEE00), Color(0xFFFF8800), Color(0xFFFF0055)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(coreRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(coreRRect, corePaint);

    // ⚡ Lightning Bolt Emblem
    canvas.save();
    canvas.scale(absCos, 1.0);
    final boltPath = Path()
      ..moveTo(2 * scale, -r * 0.65)
      ..lineTo(-r * 0.45, 0)
      ..lineTo(-1 * scale, 0)
      ..lineTo(-3 * scale, r * 0.65)
      ..lineTo(r * 0.45, -1 * scale)
      ..lineTo(1 * scale, -1 * scale)
      ..close();

    final boltPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawPath(boltPath, boltPaint);

    final boltBorder = Paint()
      ..color = const Color(0xFFFF0055)
      ..strokeWidth = 1.5 * scale
      ..style = PaintingStyle.stroke;
    canvas.drawPath(boltPath, boltBorder);
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

    // Reusable paint instances with ZERO allocations in hot loop
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.85)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    final corePaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(-14, 0), const Offset(14, 0), glowPaint);
    canvas.drawLine(const Offset(-14, 0), const Offset(14, 0), corePaint);
    canvas.drawLine(const Offset(0, -14), const Offset(0, 14), glowPaint);
    canvas.drawLine(const Offset(0, -14), const Offset(0, 14), corePaint);

    canvas.restore();
  }
}
