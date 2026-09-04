import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/painting.dart';
import 'package:shorebird_runner/game/components/player.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

enum ObstacleType {
  appStore,  // Apple App Store logo barrier
  playStore, // Google Play Store 4-color polygon emblem
  wormBug,   // Animated 🐛 crawling worm / caterpillar bug
}

/// 3D obstacle representing App Store & Play Store review delays, and runtime bugs.
/// Must be dodged by reflexive lane switching.
class Obstacle extends Component {
  int lane;
  double depth; // 0=horizon, 1=player position
  final ObstacleType type;
  final double _wobblePhase;
  final double _rotationPhase;
  bool isDead = false;
  int totalPatches = 0;

  Obstacle({
    required this.lane,
    required this.type,
    required Random rng,
  })  : depth = 0,
        _wobblePhase = rng.nextDouble() * pi * 2,
        _rotationPhase = (rng.nextDouble() - 0.5) * 0.2;

  @override
  void update(double dt) {
    final speed = GameConfig.scrollSpeed(totalPatches);
    depth += dt * speed * 0.54;
  }

  bool get isPastPlayer => depth >= 1.06;

  Offset get worldPosition => PerspectiveHelper.lanePosition(lane, depth);
  double get worldScale => PerspectiveHelper.scaleAtDepth(depth);

  @override
  void render(Canvas canvas) {
    if (isDead) return;

    final pos = worldPosition;
    final scale = worldScale;
    final size = GameConfig.obstacleNearSize * scale;

    switch (type) {
      case ObstacleType.appStore:
        _drawAppStore(canvas, pos, scale, size);
        break;
      case ObstacleType.playStore:
        _drawPlayStore(canvas, pos, scale, size);
        break;
      case ObstacleType.wormBug:
        _drawWormBug(canvas, pos, scale, size);
        break;
    }
  }

  // ── 🍎 Apple App Store Logo Obstacle ───────────────────────────────────────
  void _drawAppStore(Canvas canvas, Offset pos, double scale, double size) {
    final hoverBob = sin(_wobblePhase + depth * 6) * 5 * scale;
    final centerY = pos.dy - size * 0.55 + hoverBob;

    // Ground shadow
    final shadowPaint = Paint()
      ..color = const Color(0xFF001133).withValues(alpha: 0.6 * scale)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * scale);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy + 8 * scale), width: size * 1.1, height: 14 * scale),
      shadowPaint,
    );

    canvas.save();
    canvas.translate(pos.dx, centerY);
    canvas.rotate(_rotationPhase * sin(depth * 5));

    final boxW = size * 0.96;
    final boxH = size * 0.96;
    final boxRect = Rect.fromCenter(center: Offset.zero, width: boxW, height: boxH);
    final cornerRadius = Radius.circular(boxW * 0.23);
    final rrect = RRect.fromRectAndRadius(boxRect, cornerRadius);

    // Neon Blue Ambient Glow
    final glowPaint = Paint()
      ..color = const Color(0xFF0A84FF).withValues(alpha: 0.45 * scale)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 * scale);
    canvas.drawRRect(rrect, glowPaint);

    // App Store Signature Blue Gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1E90FF),
          Color(0xFF0071E3),
          Color(0xFF0040DD),
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(boxRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, bgPaint);

    // Subtle Glass Top Sheen
    final sheenRect = Rect.fromCenter(center: Offset(0, -boxH * 0.22), width: boxW * 0.92, height: boxH * 0.42);
    final sheenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(sheenRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(sheenRect, Radius.circular(boxW * 0.18)), sheenPaint);

    // Outer Crisp Border
    final borderPaint = Paint()
      ..color = const Color(0xFF80BFFF).withValues(alpha: 0.65)
      ..strokeWidth = 2.0 * scale
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, borderPaint);

    // ── Apple App Store "A" Logo (Pencil, Ruler, Brush bars) ─────────────────
    final aStrokeW = boxW * 0.11;
    final aPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = aStrokeW
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final topPeakY = -boxH * 0.26;
    final bottomY = boxH * 0.26;
    final legLeftX = -boxW * 0.26;
    final legRightX = boxW * 0.26;
    final crossY = boxH * 0.06;

    // Left diagonal bar
    canvas.drawLine(Offset(-boxW * 0.03, topPeakY), Offset(legLeftX, bottomY), aPaint);
    // Right diagonal bar
    canvas.drawLine(Offset(boxW * 0.03, topPeakY), Offset(legRightX, bottomY), aPaint);
    // Horizontal cross bar
    canvas.drawLine(Offset(-boxW * 0.28, crossY), Offset(boxW * 0.28, crossY), aPaint);

    // Inner detail joints
    final jointPaint = Paint()..color = const Color(0xFF0071E3);
    canvas.drawCircle(Offset(-boxW * 0.14, crossY), aStrokeW * 0.22, jointPaint);
    canvas.drawCircle(Offset(boxW * 0.14, crossY), aStrokeW * 0.22, jointPaint);

    canvas.restore();
  }

  // ── 🛍️ Google Play Store 4-Color Polygon Obstacle ──────────────────────────
  void _drawPlayStore(Canvas canvas, Offset pos, double scale, double size) {
    final hoverBob = cos(_wobblePhase + depth * 6) * 5 * scale;
    final centerY = pos.dy - size * 0.55 + hoverBob;

    // Ground shadow
    final shadowPaint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: 0.55 * scale)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * scale);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy + 8 * scale), width: size * 1.1, height: 14 * scale),
      shadowPaint,
    );

    canvas.save();
    canvas.translate(pos.dx, centerY);

    // Soft colored multi-hue glow
    final glowPaint = Paint()
      ..color = const Color(0xFF00E676).withValues(alpha: 0.35 * scale)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 * scale);
    canvas.drawCircle(Offset.zero, size * 0.52, glowPaint);

    final w = size * 0.92;
    final h = size * 0.98;

    // Key vertices of the Google Play Store Triangle
    final pTopLeft = Offset(-w * 0.42, -h * 0.44);
    final pBottomLeft = Offset(-w * 0.42, h * 0.44);
    final pRightTip = Offset(w * 0.46, 0);
    final pCenter = Offset(w * 0.05, 0);

    // 1. Blue Facet (Top-Left)
    final bluePath = Path()
      ..moveTo(pTopLeft.dx, pTopLeft.dy)
      ..lineTo(pBottomLeft.dx, pBottomLeft.dy)
      ..lineTo(pCenter.dx, pCenter.dy)
      ..close();
    final bluePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromPoints(pTopLeft, pCenter))
      ..style = PaintingStyle.fill;
    canvas.drawPath(bluePath, bluePaint);

    // 2. Green Facet (Top-Right pointing to tip)
    final greenPath = Path()
      ..moveTo(pTopLeft.dx, pTopLeft.dy)
      ..lineTo(pCenter.dx, pCenter.dy)
      ..lineTo(pRightTip.dx, pRightTip.dy)
      ..close();
    final greenPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00F5A0), Color(0xFF00D95A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromPoints(pTopLeft, pRightTip))
      ..style = PaintingStyle.fill;
    canvas.drawPath(greenPath, greenPaint);

    // 3. Yellow Facet (Bottom-Right tip)
    final yellowPath = Path()
      ..moveTo(pRightTip.dx, pRightTip.dy)
      ..lineTo(pCenter.dx, pCenter.dy)
      ..lineTo(pBottomLeft.dx + w * 0.3, h * 0.32)
      ..close();
    final yellowPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFDD00), Color(0xFFFF9900)],
        begin: Alignment.topRight,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromPoints(pCenter, pRightTip))
      ..style = PaintingStyle.fill;
    canvas.drawPath(yellowPath, yellowPaint);

    // 4. Red Facet (Bottom-Left)
    final redPath = Path()
      ..moveTo(pBottomLeft.dx, pBottomLeft.dy)
      ..lineTo(pCenter.dx, pCenter.dy)
      ..lineTo(pRightTip.dx, pRightTip.dy)
      ..lineTo(pBottomLeft.dx, pBottomLeft.dy)
      ..close();
    final redPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF4E50), Color(0xFFF9D423)],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromPoints(pBottomLeft, pRightTip))
      ..style = PaintingStyle.fill;
    canvas.drawPath(redPath, redPaint);

    // Re-draw Blue segment clean overlay with anti-aliasing
    canvas.drawPath(bluePath, bluePaint);

    // Outer Crisp Edge
    final outerPath = Path()
      ..moveTo(pTopLeft.dx, pTopLeft.dy)
      ..lineTo(pRightTip.dx, pRightTip.dy)
      ..lineTo(pBottomLeft.dx, pBottomLeft.dy)
      ..close();
    canvas.drawPath(
      outerPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = 1.5 * scale
        ..style = PaintingStyle.stroke,
    );

    canvas.restore();
  }

  // ── 🐛 Worm Caterpillar Bug Obstacle ──────────────────────────────────────
  void _drawWormBug(Canvas canvas, Offset pos, double scale, double size) {
    final crawlSpeed = depth * 16 + _wobblePhase;
    final crawlBob = (sin(crawlSpeed) * 3.5).abs() * scale;

    // Ground shadow following the worm segments
    final shadowPaint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: 0.5 * scale)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * scale);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pos.dx, pos.dy + 4 * scale),
        width: size * 1.15,
        height: 12 * scale,
      ),
      shadowPaint,
    );

    // 5 Segmented Caterpillar Body
    const segmentCount = 5;
    final segmentRadius = size * 0.22;

    // Draw from tail to head (tail = index 4, head = index 0)
    for (int i = segmentCount - 1; i >= 0; i--) {
      final t = i / (segmentCount - 1);
      final segmentOffset = (i - 2) * (segmentRadius * 0.95);
      // Crawling arch waveform
      final segmentWobble = sin(crawlSpeed - i * 0.75) * 6 * scale;
      final segX = pos.dx + segmentOffset * 0.5;
      final segY = pos.dy - size * 0.28 - crawlBob + segmentWobble * (1.0 - t * 0.3);

      final isHead = (i == 0);
      final radius = isHead ? segmentRadius * 1.25 : segmentRadius * (0.85 + (1.0 - t) * 0.25);

      final segRect = Rect.fromCircle(center: Offset(segX, segY), radius: radius);

      // Gradient body coloring (bright toxic neon green / lime)
      final bodyPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF86EFAC),
            isHead ? const Color(0xFF22C55E) : const Color(0xFF16A34A),
            const Color(0xFF052E16),
          ],
          center: const Alignment(-0.25, -0.35),
        ).createShader(segRect)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(segX, segY), radius, bodyPaint);

      // Small yellow decorative spots on body rings
      if (!isHead) {
        final spotPaint = Paint()..color = const Color(0xFFFACC15).withValues(alpha: 0.85);
        canvas.drawCircle(Offset(segX, segY - radius * 0.45), radius * 0.28, spotPaint);

        // Tiny cute caterpillar feet touching ground
        final footPaint = Paint()..color = const Color(0xFF15803D);
        canvas.drawCircle(Offset(segX - radius * 0.35, segY + radius * 0.9), radius * 0.22, footPaint);
        canvas.drawCircle(Offset(segX + radius * 0.35, segY + radius * 0.9), radius * 0.22, footPaint);
      }

      // Head Features (Eyes, Antennae, Smile, Cheeks)
      if (isHead) {
        // Antennae
        final antennaPaint = Paint()
          ..color = const Color(0xFF15803D)
          ..strokeWidth = 2.5 * scale
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        // Left antenna
        final leftAntenna = Path()
          ..moveTo(segX - radius * 0.35, segY - radius * 0.7)
          ..quadraticBezierTo(
            segX - radius * 0.8,
            segY - radius * 1.6,
            segX - radius * 0.6,
            segY - radius * 1.8,
          );
        canvas.drawPath(leftAntenna, antennaPaint);
        canvas.drawCircle(Offset(segX - radius * 0.6, segY - radius * 1.8), radius * 0.22, Paint()..color = const Color(0xFFFF4E50));

        // Right antenna
        final rightAntenna = Path()
          ..moveTo(segX + radius * 0.35, segY - radius * 0.7)
          ..quadraticBezierTo(
            segX + radius * 0.8,
            segY - radius * 1.6,
            segX + radius * 0.6,
            segY - radius * 1.8,
          );
        canvas.drawPath(rightAntenna, antennaPaint);
        canvas.drawCircle(Offset(segX + radius * 0.6, segY - radius * 1.8), radius * 0.22, Paint()..color = const Color(0xFFFF4E50));

        // Big cartoon glossy eyes
        final eyeRadius = radius * 0.32;
        final leftEyePos = Offset(segX - radius * 0.36, segY - radius * 0.15);
        final rightEyePos = Offset(segX + radius * 0.36, segY - radius * 0.15);

        canvas.drawCircle(leftEyePos, eyeRadius, Paint()..color = Colors.white);
        canvas.drawCircle(rightEyePos, eyeRadius, Paint()..color = Colors.white);

        // Pupils looking forward
        final pupilRadius = eyeRadius * 0.55;
        canvas.drawCircle(Offset(leftEyePos.dx, leftEyePos.dy + eyeRadius * 0.1), pupilRadius, Paint()..color = Colors.black);
        canvas.drawCircle(Offset(rightEyePos.dx, rightEyePos.dy + eyeRadius * 0.1), pupilRadius, Paint()..color = Colors.black);

        // Eye glint
        canvas.drawCircle(Offset(leftEyePos.dx - pupilRadius * 0.3, leftEyePos.dy - pupilRadius * 0.3), pupilRadius * 0.35, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(rightEyePos.dx - pupilRadius * 0.3, rightEyePos.dy - pupilRadius * 0.3), pupilRadius * 0.35, Paint()..color = Colors.white);

        // Cute rosy cheeks
        final blushPaint = Paint()..color = const Color(0xFFFF69B4).withValues(alpha: 0.6);
        canvas.drawCircle(Offset(segX - radius * 0.55, segY + radius * 0.25), radius * 0.22, blushPaint);
        canvas.drawCircle(Offset(segX + radius * 0.55, segY + radius * 0.25), radius * 0.22, blushPaint);

        // Mischievous bug smile
        final mouthPaint = Paint()
          ..color = const Color(0xFF052E16)
          ..strokeWidth = 2.0 * scale
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        final mouthPath = Path()
          ..moveTo(segX - radius * 0.22, segY + radius * 0.35)
          ..quadraticBezierTo(segX, segY + radius * 0.65, segX + radius * 0.22, segY + radius * 0.35);
        canvas.drawPath(mouthPath, mouthPaint);
      }
    }
  }
}
