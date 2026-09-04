import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:shorebird_runner/game/components/player.dart';
import 'package:shorebird_runner/game/utils/audio_service.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

/// A glowing 3D Shorebird OTA Patch collectible.
/// Represents an instant code patch deployed by Shorebird (🐤)
/// to bypass App Store and Play Store review delays.
class Patch extends Component {
  int lane;
  double depth;
  bool isCollected = false;
  bool hasTriggeredMiss = false;
  double _collectAnimation = 0;
  double _spinPhase;
  double _pulsePhase;
  int totalPatches = 0;

  final void Function(Offset pos)? onMissed;
  final List<_Sparkle> _sparkles = [];

  Patch({
    required this.lane,
    required Random rng,
    this.onMissed,
  })  : depth = 0,
        _spinPhase = rng.nextDouble() * pi * 2,
        _pulsePhase = rng.nextDouble() * pi * 2;

  @override
  void update(double dt) {
    if (!isCollected) {
      final speed = GameConfig.scrollSpeed(totalPatches);
      depth += dt * speed * 0.54;
      _spinPhase += dt * 3.6;
      _pulsePhase += dt * 5.0;

      // Miss detection: passed player uncollected
      if (depth >= 1.04 && !hasTriggeredMiss) {
        hasTriggeredMiss = true;
        onMissed?.call(worldPosition);
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

  Offset get worldPosition => PerspectiveHelper.lanePosition(lane, depth);
  double get worldScale => PerspectiveHelper.scaleAtDepth(depth);

  void collect() {
    if (isCollected) return;
    isCollected = true;
    AudioService.playPatch();

    final pos = worldPosition;
    final rng = Random();
    for (int i = 0; i < 22; i++) {
      _sparkles.add(_Sparkle(pos, rng));
    }
  }

  @override
  void render(Canvas canvas) {
    if (isDone) return;

    if (isCollected) {
      _drawSparkles(canvas);
      return;
    }

    final pos = worldPosition;
    final scale = worldScale;
    final size = GameConfig.patchNearSize * scale;

    _drawShadow(canvas, pos, scale);
    _drawShorebirdPatch(canvas, pos, scale, size);
  }

  void _drawShadow(Canvas canvas, Offset pos, double scale) {
    final shadowPaint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: 0.5 * scale)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * scale);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pos.dx, pos.dy + 8 * scale),
        width: GameConfig.patchNearSize * 0.85 * scale,
        height: 11 * scale,
      ),
      shadowPaint,
    );
  }

  void _drawShorebirdPatch(Canvas canvas, Offset pos, double scale, double size) {
    final hoverBob = sin(_pulsePhase) * 5 * scale;
    final patchPos = Offset(pos.dx, pos.dy - 12 * scale + hoverBob);

    canvas.save();
    canvas.translate(patchPos.dx, patchPos.dy);

    final cosSpin = cos(_spinPhase);
    final absCos = cosSpin.abs().clamp(0.12, 1.0);
    final isFront = cosSpin >= 0;

    // 1. Radiant Cyan/Gold Ambient Glow
    final glowPaint = Paint()
      ..color = const Color(0xFF00D4FF).withValues(alpha: 0.45 * scale)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 * scale);
    canvas.drawCircle(Offset.zero, size * 0.65, glowPaint);

    // 2. Futuristic Hexagonal OTA Patch Badge
    final r = size * 0.55;
    final badgeW = r * 1.8 * absCos;
    final badgeH = r * 1.8;

    final patchRect = Rect.fromCenter(center: Offset.zero, width: badgeW, height: badgeH);
    final rrect = RRect.fromRectAndRadius(patchRect, Radius.circular(r * 0.38 * absCos));

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

    // 🐤 Shorebird Baby Chick Symbol in center (spins in 3D perspective with the patch)
    canvas.save();
    canvas.scale(absCos, 1.0);
    final tp = TextPainter(
      text: TextSpan(
        text: '🐤',
        style: TextStyle(
          fontSize: badgeH * 0.58,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();

    canvas.restore();
  }

  void _drawSparkles(Canvas canvas) {
    for (final s in _sparkles) {
      s.render(canvas);
    }
  }
}

class _Sparkle {
  Offset pos;
  final Offset velocity;
  final Color color;
  final double radius;
  double life = 1.0;

  _Sparkle(Offset origin, Random rng)
      : pos = origin,
        velocity = Offset(
          (rng.nextDouble() - 0.5) * 190,
          -rng.nextDouble() * 170 - 40,
        ),
        color = rng.nextBool() ? const Color(0xFF00E5FF) : const Color(0xFFFFD700),
        radius = rng.nextDouble() * 3.5 + 2.0;

  void update(double dt) {
    pos += velocity * dt;
    life = (life - dt * 2.8).clamp(0.0, 1.0);
  }

  void render(Canvas canvas) {
    if (life <= 0) return;
    final paint = Paint()
      ..color = color.withValues(alpha: life)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, radius * life, paint);
  }
}
