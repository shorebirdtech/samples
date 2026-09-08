import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/painting.dart';
import 'package:shorebird_runner/game/components/player.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

enum ObstacleType {
  appStore, // Apple App Store logo barrier (dodge sideways)
  playStore, // Google Play Store 4-color polygon emblem (dodge sideways)
  wormBug, // Animated 🐛 crawling caterpillar bug (jump over or dodge)
  mergeBarricade, // 🚧 Low road construction barricade (jump over or dodge)
  reviewGate, // 🚨 Overhead App Review Laser Gate (slide under or dodge)
}

/// 3D obstacle representing App Store & Play Store review delays, merge blocks, and runtime bugs.
/// Designed for 120 FPS performance with zero MaskFilter.blur passes and cached TextPainters.
class Obstacle extends Component {
  int lane;
  double depth; // 0=horizon, 1=player position
  final ObstacleType type;
  final double _wobblePhase;
  final double _rotationPhase;
  bool isDead = false;
  int totalPatches = 0;

  bool get isJumpable =>
      type == ObstacleType.wormBug || type == ObstacleType.mergeBarricade;
  bool get isSlideable => type == ObstacleType.reviewGate;

  static final TextPainter _reviewGatePainter = TextPainter(
    text: const TextSpan(
      text: 'UNDER REVIEW',
      style: TextStyle(
        color: Color(0xFFFFC107),
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.4,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  Obstacle({
    required this.lane,
    required this.type,
    required Random rng,
  })  : depth = 0,
        _wobblePhase = rng.nextDouble() * pi * 2,
        _rotationPhase = (rng.nextDouble() - 0.5) * 0.15;

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
      case ObstacleType.mergeBarricade:
        _drawMergeBarricade(canvas, pos, scale, size);
        break;
      case ObstacleType.reviewGate:
        _drawReviewGate(canvas, pos, scale, size);
        break;
    }
  }

  // ── 🍎 Apple App Store Logo Obstacle ───────────────────────────────────────
  void _drawAppStore(Canvas canvas, Offset pos, double scale, double size) {
    final hoverBob = sin(_wobblePhase + depth * 6) * 4 * scale;
    final centerY = pos.dy - size * 0.55 + hoverBob;

    // Dual-concentric ground shadow (zero blur, butter smooth)
    final shadowCenter = Offset(pos.dx, pos.dy + 8 * scale);
    canvas.drawOval(
      Rect.fromCenter(
          center: shadowCenter, width: size * 1.25, height: 16 * scale),
      Paint()..color = const Color(0xFF001133).withValues(alpha: 0.25 * scale),
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: shadowCenter, width: size * 0.92, height: 10 * scale),
      Paint()..color = const Color(0xFF001133).withValues(alpha: 0.55 * scale),
    );

    canvas.save();
    canvas.translate(pos.dx, centerY);
    canvas.rotate(_rotationPhase * sin(depth * 5));

    final boxW = size * 0.96;
    final boxH = size * 0.96;
    final boxRect =
        Rect.fromCenter(center: Offset.zero, width: boxW, height: boxH);
    final cornerRadius = Radius.circular(boxW * 0.23);
    final rrect = RRect.fromRectAndRadius(boxRect, cornerRadius);

    // Neon Blue Stepped Ambient Halo (replaces MaskFilter.blur)
    canvas.drawRRect(
      rrect.inflate(8 * scale),
      Paint()..color = const Color(0xFF0A84FF).withValues(alpha: 0.15 * scale),
    );
    canvas.drawRRect(
      rrect.inflate(3 * scale),
      Paint()..color = const Color(0xFF0A84FF).withValues(alpha: 0.35 * scale),
    );

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
    final sheenRect = Rect.fromCenter(
        center: Offset(0, -boxH * 0.22),
        width: boxW * 0.92,
        height: boxH * 0.42);
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
    canvas.drawRRect(
        RRect.fromRectAndRadius(sheenRect, Radius.circular(boxW * 0.18)),
        sheenPaint);

    // Outer Crisp Border
    final borderPaint = Paint()
      ..color = const Color(0xFF80BFFF).withValues(alpha: 0.65)
      ..strokeWidth = 2.0 * scale
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, borderPaint);

    // Apple App Store "A" Logo (Pencil, Ruler, Brush bars)
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

    canvas.drawLine(
        Offset(-boxW * 0.03, topPeakY), Offset(legLeftX, bottomY), aPaint);
    canvas.drawLine(
        Offset(boxW * 0.03, topPeakY), Offset(legRightX, bottomY), aPaint);
    canvas.drawLine(
        Offset(-boxW * 0.28, crossY), Offset(boxW * 0.28, crossY), aPaint);

    final jointPaint = Paint()..color = const Color(0xFF0071E3);
    canvas.drawCircle(
        Offset(-boxW * 0.14, crossY), aStrokeW * 0.22, jointPaint);
    canvas.drawCircle(Offset(boxW * 0.14, crossY), aStrokeW * 0.22, jointPaint);

    canvas.restore();
  }

  // ── 🛍️ Google Play Store 4-Color Polygon Obstacle ──────────────────────────
  void _drawPlayStore(Canvas canvas, Offset pos, double scale, double size) {
    final hoverBob = cos(_wobblePhase + depth * 6) * 4 * scale;
    final centerY = pos.dy - size * 0.55 + hoverBob;

    // Dual-concentric ground shadow
    final shadowCenter = Offset(pos.dx, pos.dy + 8 * scale);
    canvas.drawOval(
      Rect.fromCenter(
          center: shadowCenter, width: size * 1.25, height: 16 * scale),
      Paint()..color = const Color(0xFF000000).withValues(alpha: 0.25 * scale),
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: shadowCenter, width: size * 0.92, height: 10 * scale),
      Paint()..color = const Color(0xFF000000).withValues(alpha: 0.55 * scale),
    );

    canvas.save();
    canvas.translate(pos.dx, centerY);

    // Multi-hue stepped halo (replaces blur)
    canvas.drawCircle(
      Offset.zero,
      size * 0.62,
      Paint()..color = const Color(0xFF00E676).withValues(alpha: 0.15 * scale),
    );
    canvas.drawCircle(
      Offset.zero,
      size * 0.52,
      Paint()..color = const Color(0xFF00E676).withValues(alpha: 0.32 * scale),
    );

    final w = size * 0.92;
    final h = size * 0.98;

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

    // 2. Green Facet (Top-Right)
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

    // 3. Yellow Facet (Bottom-Right)
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

  // ── 🐛 Worm Caterpillar Bug Obstacle (Jumpable) ────────────────────────────
  void _drawWormBug(Canvas canvas, Offset pos, double scale, double size) {
    final crawlSpeed = depth * 16 + _wobblePhase;
    final crawlBob = (sin(crawlSpeed) * 3.5).abs() * scale;

    // Dual-concentric ground shadow
    final shadowCenter = Offset(pos.dx, pos.dy + 4 * scale);
    canvas.drawOval(
      Rect.fromCenter(
          center: shadowCenter, width: size * 1.3, height: 14 * scale),
      Paint()..color = const Color(0xFF000000).withValues(alpha: 0.22 * scale),
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: shadowCenter, width: size * 0.95, height: 8 * scale),
      Paint()..color = const Color(0xFF000000).withValues(alpha: 0.52 * scale),
    );

    const segmentCount = 5;
    final segmentRadius = size * 0.22;

    for (int i = segmentCount - 1; i >= 0; i--) {
      final t = i / (segmentCount - 1);
      final segmentOffset = (i - 2) * (segmentRadius * 0.95);
      final segmentWobble = sin(crawlSpeed - i * 0.75) * 6 * scale;
      final segX = pos.dx + segmentOffset * 0.5;
      final segY =
          pos.dy - size * 0.28 - crawlBob + segmentWobble * (1.0 - t * 0.3);

      final isHead = (i == 0);
      final radius = isHead
          ? segmentRadius * 1.25
          : segmentRadius * (0.85 + (1.0 - t) * 0.25);

      final segRect =
          Rect.fromCircle(center: Offset(segX, segY), radius: radius);

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

      if (!isHead) {
        final spotPaint = Paint()
          ..color = const Color(0xFFFACC15).withValues(alpha: 0.85);
        canvas.drawCircle(
            Offset(segX, segY - radius * 0.45), radius * 0.28, spotPaint);

        final footPaint = Paint()..color = const Color(0xFF15803D);
        canvas.drawCircle(Offset(segX - radius * 0.35, segY + radius * 0.9),
            radius * 0.22, footPaint);
        canvas.drawCircle(Offset(segX + radius * 0.35, segY + radius * 0.9),
            radius * 0.22, footPaint);
      }

      if (isHead) {
        final antennaPaint = Paint()
          ..color = const Color(0xFF15803D)
          ..strokeWidth = 2.5 * scale
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        final leftAntenna = Path()
          ..moveTo(segX - radius * 0.35, segY - radius * 0.7)
          ..quadraticBezierTo(
            segX - radius * 0.8,
            segY - radius * 1.6,
            segX - radius * 0.6,
            segY - radius * 1.8,
          );
        canvas.drawPath(leftAntenna, antennaPaint);
        canvas.drawCircle(Offset(segX - radius * 0.6, segY - radius * 1.8),
            radius * 0.22, Paint()..color = const Color(0xFFFF4E50));

        final rightAntenna = Path()
          ..moveTo(segX + radius * 0.35, segY - radius * 0.7)
          ..quadraticBezierTo(
            segX + radius * 0.8,
            segY - radius * 1.6,
            segX + radius * 0.6,
            segY - radius * 1.8,
          );
        canvas.drawPath(rightAntenna, antennaPaint);
        canvas.drawCircle(Offset(segX + radius * 0.6, segY - radius * 1.8),
            radius * 0.22, Paint()..color = const Color(0xFFFF4E50));

        final eyeRadius = radius * 0.32;
        final leftEyePos = Offset(segX - radius * 0.36, segY - radius * 0.15);
        final rightEyePos = Offset(segX + radius * 0.36, segY - radius * 0.15);

        canvas.drawCircle(leftEyePos, eyeRadius, Paint()..color = Colors.white);
        canvas.drawCircle(
            rightEyePos, eyeRadius, Paint()..color = Colors.white);

        final pupilRadius = eyeRadius * 0.55;
        canvas.drawCircle(
            Offset(leftEyePos.dx, leftEyePos.dy + eyeRadius * 0.1),
            pupilRadius,
            Paint()..color = Colors.black);
        canvas.drawCircle(
            Offset(rightEyePos.dx, rightEyePos.dy + eyeRadius * 0.1),
            pupilRadius,
            Paint()..color = Colors.black);

        canvas.drawCircle(
            Offset(leftEyePos.dx - pupilRadius * 0.3,
                leftEyePos.dy - pupilRadius * 0.3),
            pupilRadius * 0.35,
            Paint()..color = Colors.white);
        canvas.drawCircle(
            Offset(rightEyePos.dx - pupilRadius * 0.3,
                rightEyePos.dy - pupilRadius * 0.3),
            pupilRadius * 0.35,
            Paint()..color = Colors.white);

        final blushPaint = Paint()
          ..color = const Color(0xFFFF69B4).withValues(alpha: 0.6);
        canvas.drawCircle(Offset(segX - radius * 0.55, segY + radius * 0.25),
            radius * 0.22, blushPaint);
        canvas.drawCircle(Offset(segX + radius * 0.55, segY + radius * 0.25),
            radius * 0.22, blushPaint);

        final mouthPaint = Paint()
          ..color = const Color(0xFF052E16)
          ..strokeWidth = 2.0 * scale
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        final mouthPath = Path()
          ..moveTo(segX - radius * 0.22, segY + radius * 0.35)
          ..quadraticBezierTo(segX, segY + radius * 0.65, segX + radius * 0.22,
              segY + radius * 0.35);
        canvas.drawPath(mouthPath, mouthPaint);
      }
    }
  }

  // ── 🚧 Low Merge Barricade (Jumpable) ──────────────────────────────────────
  void _drawMergeBarricade(
      Canvas canvas, Offset pos, double scale, double size) {
    final barW = size * 1.35;
    final barH = size * 0.42;
    final groundY = pos.dy;

    // Ground shadow
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(pos.dx, groundY + 4 * scale),
          width: barW * 1.1,
          height: 12 * scale),
      Paint()..color = const Color(0xFF000000).withValues(alpha: 0.45 * scale),
    );

    // Stanchion Legs
    final legPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 4.0 * scale
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(pos.dx - barW * 0.38, groundY),
        Offset(pos.dx - barW * 0.38, groundY - barH), legPaint);
    canvas.drawLine(Offset(pos.dx + barW * 0.38, groundY),
        Offset(pos.dx + barW * 0.38, groundY - barH), legPaint);

    // Barricade Rail with Hazard Diagonal Stripes
    final railRect = Rect.fromCenter(
      center: Offset(pos.dx, groundY - barH * 0.6),
      width: barW,
      height: barH * 0.55,
    );
    final railRRect = RRect.fromRectAndRadius(railRect, Radius.circular(4 * scale));

    canvas.drawRRect(railRRect, Paint()..color = const Color(0xFFFFB300));

    // Black chevron stripes
    canvas.save();
    canvas.clipRRect(railRRect);
    final stripePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 8.0 * scale
      ..style = PaintingStyle.stroke;
    for (double x = -barW; x <= barW * 2; x += 18 * scale) {
      canvas.drawLine(
        Offset(railRect.left + x, railRect.bottom + 5 * scale),
        Offset(railRect.left + x + 16 * scale, railRect.top - 5 * scale),
        stripePaint,
      );
    }
    canvas.restore();

    // Dual Flashing Amber Beacons on top corners
    final strobeFlash = (sin(_wobblePhase + depth * 14) > 0);
    final strobeColor = strobeFlash
        ? const Color(0xFFFFD54F)
        : const Color(0xFFFF8F00).withValues(alpha: 0.6);

    for (final xSign in [-1.0, 1.0]) {
      final beaconPos =
          Offset(pos.dx + xSign * (barW * 0.38), groundY - barH - 4 * scale);

      if (strobeFlash) {
        canvas.drawCircle(
          beaconPos,
          10 * scale,
          Paint()
            ..color =
                const Color(0xFFFFD54F).withValues(alpha: 0.25 * scale),
        );
      }

      canvas.drawCircle(
        beaconPos,
        5 * scale,
        Paint()..color = strobeColor,
      );
    }
  }

  // ── 🚨 Overhead Review Laser Gate (Slideable Underneath) ───────────────────
  void _drawReviewGate(Canvas canvas, Offset pos, double scale, double size) {
    final gateW = size * 1.5;
    final gateH = size * 1.25;
    final groundY = pos.dy;

    // Ground shadow beneath posts
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(pos.dx, groundY + 4 * scale),
          width: gateW * 1.05,
          height: 10 * scale),
      Paint()..color = const Color(0xFF000000).withValues(alpha: 0.35 * scale),
    );

    final leftPostX = pos.dx - gateW * 0.45;
    final rightPostX = pos.dx + gateW * 0.45;
    final topY = groundY - gateH;

    // Cybernetic Vertical Pylons
    final postPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 6.0 * scale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(leftPostX, groundY), Offset(leftPostX, topY), postPaint);
    canvas.drawLine(
        Offset(rightPostX, groundY), Offset(rightPostX, topY), postPaint);

    // Cyan accent lines on pylons
    final neonLinePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.8)
      ..strokeWidth = 2.0 * scale
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(leftPostX, groundY), Offset(leftPostX, topY), neonLinePaint);
    canvas.drawLine(
        Offset(rightPostX, groundY), Offset(rightPostX, topY), neonLinePaint);

    // Top Crossbar
    final crossbarRect = Rect.fromCenter(
      center: Offset(pos.dx, topY + 8 * scale),
      width: gateW * 0.98,
      height: 18 * scale,
    );
    final crossbarRRect =
        RRect.fromRectAndRadius(crossbarRect, Radius.circular(4 * scale));
    canvas.drawRRect(crossbarRRect, Paint()..color = const Color(0xFF0F172A));
    canvas.drawRRect(
        crossbarRRect,
        Paint()
          ..color = const Color(0xFFFFC107).withValues(alpha: 0.7)
          ..strokeWidth = 1.5 * scale
          ..style = PaintingStyle.stroke);

    // "UNDER REVIEW" pre-cached text banner
    canvas.save();
    canvas.translate(
        pos.dx - (_reviewGatePainter.width * scale * 0.9) / 2,
        topY + 8 * scale - (_reviewGatePainter.height * scale * 0.9) / 2);
    canvas.scale(scale * 0.9, scale * 0.9);
    _reviewGatePainter.paint(canvas, Offset.zero);
    canvas.restore();

    // High Security Laser Beams (positioned from 55% to 85% height off the ground)
    // Low slide clears cleanly below!
    final laserPulse = (sin(_wobblePhase + depth * 18) * 0.5 + 0.5);
    final laserY1 = topY + 22 * scale;
    final laserY2 = topY + 36 * scale;

    for (final ly in [laserY1, laserY2]) {
      // Stepped soft outer glow
      canvas.drawLine(
        Offset(leftPostX, ly),
        Offset(rightPostX, ly),
        Paint()
          ..color =
              const Color(0xFFFF1744).withValues(alpha: 0.25 * laserPulse * scale)
          ..strokeWidth = 8.0 * scale
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
      // Bright laser core
      canvas.drawLine(
        Offset(leftPostX, ly),
        Offset(rightPostX, ly),
        Paint()
          ..color =
              const Color(0xFFFF5252).withValues(alpha: 0.95 * scale)
          ..strokeWidth = 3.0 * scale
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
      // White hot filament
      canvas.drawLine(
        Offset(leftPostX, ly),
        Offset(rightPostX, ly),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.85 * scale)
          ..strokeWidth = 1.2 * scale
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }
  }
}
