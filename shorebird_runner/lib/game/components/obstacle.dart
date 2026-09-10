import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/painting.dart';
import 'package:shorebird_runner/game/components/obstacle_type.dart';
import 'package:shorebird_runner/game/components/perspective_helper.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

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
  bool isInvincible = false;

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
    final speed =
        GameConfig.scrollSpeed(totalPatches, isInvincible: isInvincible);
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

  static final Paint _shadowOuterPaint = Paint();
  static final Paint _shadowInnerPaint = Paint();

  // App Store static assets
  static const Rect _appBoxRect = Rect.fromLTWH(-50, -50, 100, 100);
  static final RRect _appUnitRRect =
      RRect.fromRectAndRadius(_appBoxRect, const Radius.circular(23));
  static const Rect _appSheenRect = Rect.fromLTWH(-46, -43, 92, 42);
  static final RRect _appSheenUnitRRect =
      RRect.fromRectAndRadius(_appSheenRect, const Radius.circular(18));

  static final Paint _appHaloOuterPaint = Paint();
  static final Paint _appHaloInnerPaint = Paint();

  static final Paint _appBgPaint = Paint()
    ..shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF1E90FF),
        Color(0xFF0071E3),
        Color(0xFF0040DD),
      ],
      stops: [0.0, 0.55, 1.0],
    ).createShader(_appBoxRect)
    ..style = PaintingStyle.fill;

  static final Paint _appSheenPaint = Paint()
    ..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withValues(alpha: 0.35),
        Colors.white.withValues(alpha: 0.0),
      ],
    ).createShader(_appSheenRect)
    ..style = PaintingStyle.fill;

  static final Paint _appBorderPaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _appAPaint = Paint()
    ..color = Colors.white
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  static final Paint _appJointPaint = Paint()..color = const Color(0xFF0071E3);

  // Play Store static assets
  static final Paint _playHaloOuterPaint = Paint();
  static final Paint _playHaloInnerPaint = Paint();

  static final Path _playBluePath = Path()
    ..moveTo(-42, -44)
    ..lineTo(-42, 44)
    ..lineTo(5, 0)
    ..close();

  static final Path _playGreenPath = Path()
    ..moveTo(-42, -44)
    ..lineTo(5, 0)
    ..lineTo(46, 0)
    ..close();

  static final Path _playYellowPath = Path()
    ..moveTo(46, 0)
    ..lineTo(5, 0)
    ..lineTo(-12, 32)
    ..close();

  static final Path _playRedPath = Path()
    ..moveTo(-42, 44)
    ..lineTo(5, 0)
    ..lineTo(46, 0)
    ..lineTo(-42, 44)
    ..close();

  static final Path _playOuterPath = Path()
    ..moveTo(-42, -44)
    ..lineTo(46, 0)
    ..lineTo(-42, 44)
    ..close();

  static final Paint _playBluePaint = Paint()
    ..shader = const LinearGradient(
      colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(const Rect.fromLTWH(-42, -44, 47, 44))
    ..style = PaintingStyle.fill;

  static final Paint _playGreenPaint = Paint()
    ..shader = const LinearGradient(
      colors: [Color(0xFF00F5A0), Color(0xFF00D95A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomRight,
    ).createShader(const Rect.fromLTWH(-42, -44, 88, 44))
    ..style = PaintingStyle.fill;

  static final Paint _playYellowPaint = Paint()
    ..shader = const LinearGradient(
      colors: [Color(0xFFFFDD00), Color(0xFFFF9900)],
      begin: Alignment.topRight,
      end: Alignment.bottomCenter,
    ).createShader(const Rect.fromLTWH(5, 0, 41, 32))
    ..style = PaintingStyle.fill;

  static final Paint _playRedPaint = Paint()
    ..shader = const LinearGradient(
      colors: [Color(0xFFFF4E50), Color(0xFFF9D423)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ).createShader(const Rect.fromLTWH(-42, 0, 88, 44))
    ..style = PaintingStyle.fill;

  static final Paint _playBorderPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.3)
    ..style = PaintingStyle.stroke;

  // Cyber Glitch Bug static assets
  static final Paint _glitchShellPaint = Paint()
    ..shader = const RadialGradient(
      colors: [
        Color(0xFF334155),
        Color(0xFF1E293B),
        Color(0xFF020617),
      ],
      center: Alignment(-0.25, -0.35),
    ).createShader(const Rect.fromLTWH(-50, -50, 100, 100))
    ..style = PaintingStyle.fill;

  static final Paint _glitchCorePaint = Paint()
    ..shader = const RadialGradient(
      colors: [
        Color(0xFF5EEAD4),
        Color(0xFF0D9488),
        Color(0xFF042F2E),
      ],
      center: Alignment(0.0, 0.0),
    ).createShader(const Rect.fromLTWH(-50, -50, 100, 100))
    ..style = PaintingStyle.fill;

  static final Paint _glitchLegPaint = Paint()
    ..color = const Color(0xFF475569)
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  static final Paint _glitchLegTipPaint = Paint()
    ..color = const Color(0xFF00FFCC);

  static final Paint _glitchCircuitPaint = Paint()
    ..color = const Color(0xFF00FFCC).withValues(alpha: 0.75)
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  static final Paint _glitchVisorGlow = Paint()
    ..color = const Color(0xFF00FFCC).withValues(alpha: 0.4);
  static final Paint _glitchVisorCore = Paint()
    ..color = const Color(0xFFFFFFFF);

  // Hologram emitter pylons for store checkpoints
  static final Paint _emitterBasePaint = Paint()
    ..color = const Color(0xFF0F172A)
    ..style = PaintingStyle.fill;
  static final Paint _emitterRingPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  static final Paint _emitterLaserPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;

  // Merge Barricade static assets
  static final Paint _barricadeLegPaint = Paint()
    ..color = const Color(0xFF334155)
    ..style = PaintingStyle.stroke;
  static final Paint _barricadeRailPaint = Paint()
    ..color = const Color(0xFFFFB300);
  static final Paint _barricadeStripePaint = Paint()
    ..color = const Color(0xFF1E293B)
    ..style = PaintingStyle.stroke;
  static final Paint _beaconGlowPaint = Paint();
  static final Paint _beaconCorePaint = Paint();

  // Review Gate static assets
  static final Paint _gatePostPaint = Paint()
    ..color = const Color(0xFF1E293B)
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  static final Paint _gateNeonLinePaint = Paint()
    ..color = const Color(0xFF00E5FF).withValues(alpha: 0.8)
    ..style = PaintingStyle.stroke;
  static final Paint _gateCrossbarBgPaint = Paint()
    ..color = const Color(0xFF0F172A);
  static final Paint _gateCrossbarBorderPaint = Paint()
    ..color = const Color(0xFFFFC107).withValues(alpha: 0.7)
    ..style = PaintingStyle.stroke;
  static final Paint _gateLaserGlowPaint = Paint()
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  static final Paint _gateLaserCorePaint = Paint()
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  static final Paint _gateLaserFilamentPaint = Paint()
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  // ── 🍎 Apple App Store Logo Obstacle ───────────────────────────────────────
  void _drawAppStore(Canvas canvas, Offset pos, double scale, double size) {
    final hoverBob = sin(_wobblePhase + depth * 6) * 4 * scale;
    final centerY = pos.dy - size * 0.55 + hoverBob;

    // Grounded Holo-Emitter Pylons on lane shoulders
    final pLeft = Offset(pos.dx - size * 0.62, pos.dy);
    final pRight = Offset(pos.dx + size * 0.62, pos.dy);
    final pylonW = 7.0 * scale;
    final pylonH = 16.0 * scale;

    _emitterRingPaint.color =
        const Color(0xFF0A84FF).withValues(alpha: 0.65 * scale);
    _emitterLaserPaint.color =
        const Color(0xFF0A84FF).withValues(alpha: 0.35 * scale);

    // Left emitter
    canvas.drawRect(
      Rect.fromLTWH(
        pLeft.dx - pylonW * 0.5,
        pLeft.dy - pylonH,
        pylonW,
        pylonH,
      ),
      _emitterBasePaint,
    );
    canvas.drawCircle(
      Offset(pLeft.dx, pLeft.dy - pylonH),
      pylonW * 0.6,
      _emitterRingPaint,
    );
    canvas.drawLine(
      Offset(pLeft.dx, pLeft.dy - pylonH),
      Offset(pos.dx - size * 0.45, centerY),
      _emitterLaserPaint,
    );

    // Right emitter
    canvas.drawRect(
      Rect.fromLTWH(
        pRight.dx - pylonW * 0.5,
        pRight.dy - pylonH,
        pylonW,
        pylonH,
      ),
      _emitterBasePaint,
    );
    canvas.drawCircle(
      Offset(pRight.dx, pRight.dy - pylonH),
      pylonW * 0.6,
      _emitterRingPaint,
    );
    canvas.drawLine(
      Offset(pRight.dx, pRight.dy - pylonH),
      Offset(pos.dx + size * 0.45, centerY),
      _emitterLaserPaint,
    );

    // Dual-concentric ground shadow
    final shadowCenter = Offset(pos.dx, pos.dy + 8 * scale);
    _shadowOuterPaint.color =
        const Color(0xFF001133).withValues(alpha: 0.25 * scale);
    canvas.drawOval(
      Rect.fromCenter(
        center: shadowCenter,
        width: size * 1.25,
        height: 16 * scale,
      ),
      _shadowOuterPaint,
    );
    _shadowInnerPaint.color =
        const Color(0xFF001133).withValues(alpha: 0.55 * scale);
    canvas.drawOval(
      Rect.fromCenter(
        center: shadowCenter,
        width: size * 0.92,
        height: 10 * scale,
      ),
      _shadowInnerPaint,
    );

    canvas.save();
    canvas.translate(pos.dx, centerY);
    canvas.rotate(_rotationPhase * sin(depth * 5));

    final boxW = size * 0.96;
    final boxH = size * 0.96;

    // Neon Blue Stepped Ambient Halo
    _appHaloOuterPaint.color =
        const Color(0xFF0A84FF).withValues(alpha: 0.15 * scale);
    final haloOuterRect = Rect.fromCenter(
      center: Offset.zero,
      width: boxW + 16 * scale,
      height: boxH + 16 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        haloOuterRect,
        Radius.circular(boxW * 0.23 + 8 * scale),
      ),
      _appHaloOuterPaint,
    );

    _appHaloInnerPaint.color =
        const Color(0xFF0A84FF).withValues(alpha: 0.35 * scale);
    final haloInnerRect = Rect.fromCenter(
      center: Offset.zero,
      width: boxW + 6 * scale,
      height: boxH + 6 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        haloInnerRect,
        Radius.circular(boxW * 0.23 + 3 * scale),
      ),
      _appHaloInnerPaint,
    );

    // App Store Signature Blue Gradient
    canvas.save();
    canvas.scale(boxW / 100, boxH / 100);
    canvas.drawRRect(_appUnitRRect, _appBgPaint);
    canvas.drawRRect(_appSheenUnitRRect, _appSheenPaint);

    // Outer Crisp Border
    _appBorderPaint
      ..color = const Color(0xFF80BFFF).withValues(alpha: 0.65)
      ..strokeWidth = (2.0 * scale) * (100 / boxW);
    canvas.drawRRect(_appUnitRRect, _appBorderPaint);

    // Apple App Store "A" Logo
    const aStrokeW = 11.0;
    _appAPaint.strokeWidth = aStrokeW;

    canvas.drawLine(
      const Offset(-3.0, -26.0),
      const Offset(-26.0, 26.0),
      _appAPaint,
    );
    canvas.drawLine(
      const Offset(3.0, -26.0),
      const Offset(26.0, 26.0),
      _appAPaint,
    );
    canvas.drawLine(
      const Offset(-28.0, 6.0),
      const Offset(28.0, 6.0),
      _appAPaint,
    );

    canvas.drawCircle(
      const Offset(-14.0, 6.0),
      aStrokeW * 0.22,
      _appJointPaint,
    );
    canvas.drawCircle(
      const Offset(14.0, 6.0),
      aStrokeW * 0.22,
      _appJointPaint,
    );
    canvas.restore();

    canvas.restore();
  }

  // ── 🛍️ Google Play Store 4-Color Polygon Obstacle ──────────────────────────
  void _drawPlayStore(Canvas canvas, Offset pos, double scale, double size) {
    final hoverBob = cos(_wobblePhase + depth * 6) * 4 * scale;
    final centerY = pos.dy - size * 0.55 + hoverBob;

    // Grounded Holo-Emitter Pylons on lane shoulders
    final pLeft = Offset(pos.dx - size * 0.62, pos.dy);
    final pRight = Offset(pos.dx + size * 0.62, pos.dy);
    final pylonW = 7.0 * scale;
    final pylonH = 16.0 * scale;

    _emitterRingPaint.color =
        const Color(0xFF00E676).withValues(alpha: 0.65 * scale);
    _emitterLaserPaint.color =
        const Color(0xFF00E676).withValues(alpha: 0.35 * scale);

    // Left emitter
    canvas.drawRect(
      Rect.fromLTWH(
        pLeft.dx - pylonW * 0.5,
        pLeft.dy - pylonH,
        pylonW,
        pylonH,
      ),
      _emitterBasePaint,
    );
    canvas.drawCircle(
      Offset(pLeft.dx, pLeft.dy - pylonH),
      pylonW * 0.6,
      _emitterRingPaint,
    );
    canvas.drawLine(
      Offset(pLeft.dx, pLeft.dy - pylonH),
      Offset(pos.dx - size * 0.45, centerY),
      _emitterLaserPaint,
    );

    // Right emitter
    canvas.drawRect(
      Rect.fromLTWH(
        pRight.dx - pylonW * 0.5,
        pRight.dy - pylonH,
        pylonW,
        pylonH,
      ),
      _emitterBasePaint,
    );
    canvas.drawCircle(
      Offset(pRight.dx, pRight.dy - pylonH),
      pylonW * 0.6,
      _emitterRingPaint,
    );
    canvas.drawLine(
      Offset(pRight.dx, pRight.dy - pylonH),
      Offset(pos.dx + size * 0.45, centerY),
      _emitterLaserPaint,
    );

    // Dual-concentric ground shadow
    final shadowCenter = Offset(pos.dx, pos.dy + 8 * scale);
    _shadowOuterPaint.color =
        const Color(0xFF000000).withValues(alpha: 0.25 * scale);
    canvas.drawOval(
      Rect.fromCenter(
        center: shadowCenter,
        width: size * 1.25,
        height: 16 * scale,
      ),
      _shadowOuterPaint,
    );
    _shadowInnerPaint.color =
        const Color(0xFF000000).withValues(alpha: 0.55 * scale);
    canvas.drawOval(
      Rect.fromCenter(
        center: shadowCenter,
        width: size * 0.92,
        height: 10 * scale,
      ),
      _shadowInnerPaint,
    );

    canvas.save();
    canvas.translate(pos.dx, centerY);

    // Multi-hue stepped halo
    _playHaloOuterPaint.color =
        const Color(0xFF00E676).withValues(alpha: 0.15 * scale);
    canvas.drawCircle(
      Offset.zero,
      size * 0.62,
      _playHaloOuterPaint,
    );
    _playHaloInnerPaint.color =
        const Color(0xFF00E676).withValues(alpha: 0.32 * scale);
    canvas.drawCircle(
      Offset.zero,
      size * 0.52,
      _playHaloInnerPaint,
    );

    final w = size * 0.92;
    final h = size * 0.98;

    // 4 Facets drawn using static unit paths and pre-baked shaders
    canvas.save();
    canvas.scale(w / 100, h / 100);

    canvas.drawPath(_playBluePath, _playBluePaint);
    canvas.drawPath(_playGreenPath, _playGreenPaint);
    canvas.drawPath(_playYellowPath, _playYellowPaint);
    canvas.drawPath(_playRedPath, _playRedPaint);
    canvas.drawPath(_playBluePath, _playBluePaint);

    _playBorderPaint.strokeWidth = (1.5 * scale) * (100 / w);
    canvas.drawPath(_playOuterPath, _playBorderPaint);

    canvas.restore();

    canvas.restore();
  }

  // ── 👾 Cyber Glitch Bug Entity (Jumpable) ─────────────────────────────────
  void _drawWormBug(Canvas canvas, Offset pos, double scale, double size) {
    final crawlSpeed = depth * 18 + _wobblePhase;
    final crawlBob = (sin(crawlSpeed * 2) * 2.5).abs() * scale;

    // Ground shadow
    final shadowCenter = Offset(pos.dx, pos.dy + 3 * scale);
    _shadowOuterPaint.color =
        const Color(0xFF000000).withValues(alpha: 0.35 * scale);
    canvas.drawOval(
      Rect.fromCenter(
        center: shadowCenter,
        width: size * 1.35,
        height: 12 * scale,
      ),
      _shadowOuterPaint,
    );

    final centerY = pos.dy - size * 0.28 - crawlBob;
    final bodyW = size * 0.85;
    final bodyH = size * 0.44;

    // 1. Skittering Mechanical Legs (3 pairs)
    _glitchLegPaint.strokeWidth = 2.4 * scale;
    for (int leg = 0; leg < 3; leg++) {
      final legT = (leg - 1) * 0.35;
      final legPhase = crawlSpeed + leg * 1.2;
      final legStep = sin(legPhase) * 6 * scale;

      // Left leg
      final lBase = Offset(pos.dx - bodyW * 0.38 + legT * bodyW * 0.5, centerY);
      final lKnee =
          Offset(lBase.dx - 12 * scale, lBase.dy - 6 * scale + legStep * 0.5);
      final lFoot = Offset(lBase.dx - 16 * scale, pos.dy + legStep);
      canvas.drawLine(lBase, lKnee, _glitchLegPaint);
      canvas.drawLine(lKnee, lFoot, _glitchLegPaint);
      canvas.drawCircle(lFoot, 1.8 * scale, _glitchLegTipPaint);

      // Right leg
      final rBase = Offset(pos.dx + bodyW * 0.38 - legT * bodyW * 0.5, centerY);
      final rKnee =
          Offset(rBase.dx + 12 * scale, rBase.dy - 6 * scale - legStep * 0.5);
      final rFoot = Offset(rBase.dx + 16 * scale, pos.dy - legStep);
      canvas.drawLine(rBase, rKnee, _glitchLegPaint);
      canvas.drawLine(rKnee, rFoot, _glitchLegPaint);
      canvas.drawCircle(rFoot, 1.8 * scale, _glitchLegTipPaint);
    }

    // 2. Armored Robotic Carapace Shell
    final shellRect = Rect.fromCenter(
      center: Offset(pos.dx, centerY),
      width: bodyW,
      height: bodyH,
    );
    final shellRRect =
        RRect.fromRectAndRadius(shellRect, Radius.circular(8 * scale));
    canvas.drawRRect(shellRRect, _glitchShellPaint);

    // 3. Central Pulsing Power Core Matrix
    final pulse = 0.85 + 0.15 * sin(crawlSpeed * 3);
    final coreRect = Rect.fromCenter(
      center: Offset(pos.dx, centerY),
      width: bodyW * 0.42 * pulse,
      height: bodyH * 0.55 * pulse,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(coreRect, Radius.circular(4 * scale)),
      _glitchCorePaint,
    );

    // 4. Circuit trace lines
    _glitchCircuitPaint.strokeWidth = 1.2 * scale;
    canvas.drawLine(
      Offset(pos.dx - bodyW * 0.45, centerY),
      Offset(pos.dx - bodyW * 0.22, centerY),
      _glitchCircuitPaint,
    );
    canvas.drawLine(
      Offset(pos.dx + bodyW * 0.22, centerY),
      Offset(pos.dx + bodyW * 0.45, centerY),
      _glitchCircuitPaint,
    );

    // 5. Front Optical Visor Slit
    final visorY = centerY - bodyH * 0.25;
    final visorW = bodyW * 0.48;
    canvas.drawLine(
      Offset(pos.dx - visorW * 0.5, visorY),
      Offset(pos.dx + visorW * 0.5, visorY),
      _glitchVisorGlow..strokeWidth = 4.0 * scale,
    );
    canvas.drawLine(
      Offset(pos.dx - visorW * 0.5, visorY),
      Offset(pos.dx + visorW * 0.5, visorY),
      _glitchVisorCore..strokeWidth = 1.5 * scale,
    );
  }

  // ── 🚧 Low Merge Barricade (Jumpable) ──────────────────────────────────────
  void _drawMergeBarricade(
    Canvas canvas,
    Offset pos,
    double scale,
    double size,
  ) {
    final barW = size * 1.35;
    final barH = size * 0.42;
    final groundY = pos.dy;

    // Ground shadow
    _shadowOuterPaint.color =
        const Color(0xFF000000).withValues(alpha: 0.45 * scale);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pos.dx, groundY + 4 * scale),
        width: barW * 1.1,
        height: 12 * scale,
      ),
      _shadowOuterPaint,
    );

    // Stanchion Legs
    _barricadeLegPaint.strokeWidth = 4.0 * scale;
    canvas.drawLine(
      Offset(pos.dx - barW * 0.38, groundY),
      Offset(pos.dx - barW * 0.38, groundY - barH),
      _barricadeLegPaint,
    );
    canvas.drawLine(
      Offset(pos.dx + barW * 0.38, groundY),
      Offset(pos.dx + barW * 0.38, groundY - barH),
      _barricadeLegPaint,
    );

    // Barricade Rail with Hazard Diagonal Stripes
    final railRect = Rect.fromCenter(
      center: Offset(pos.dx, groundY - barH * 0.6),
      width: barW,
      height: barH * 0.55,
    );
    final railRRect =
        RRect.fromRectAndRadius(railRect, Radius.circular(4 * scale));

    canvas.drawRRect(railRRect, _barricadeRailPaint);

    // Black chevron stripes
    canvas.save();
    canvas.clipRRect(railRRect);
    _barricadeStripePaint.strokeWidth = 8.0 * scale;
    for (double x = -barW; x <= barW * 2; x += 18 * scale) {
      canvas.drawLine(
        Offset(railRect.left + x, railRect.bottom + 5 * scale),
        Offset(railRect.left + x + 16 * scale, railRect.top - 5 * scale),
        _barricadeStripePaint,
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
        _beaconGlowPaint.color =
            const Color(0xFFFFD54F).withValues(alpha: 0.25 * scale);
        canvas.drawCircle(
          beaconPos,
          10 * scale,
          _beaconGlowPaint,
        );
      }

      _beaconCorePaint.color = strobeColor;
      canvas.drawCircle(
        beaconPos,
        5 * scale,
        _beaconCorePaint,
      );
    }
  }

  // ── 🚨 Overhead Review Laser Gate (Slideable Underneath) ───────────────────
  void _drawReviewGate(Canvas canvas, Offset pos, double scale, double size) {
    final gateW = size * 1.5;
    final gateH = size * 1.25;
    final groundY = pos.dy;

    // Ground shadow beneath posts
    _shadowOuterPaint.color =
        const Color(0xFF000000).withValues(alpha: 0.35 * scale);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pos.dx, groundY + 4 * scale),
        width: gateW * 1.05,
        height: 10 * scale,
      ),
      _shadowOuterPaint,
    );

    final leftPostX = pos.dx - gateW * 0.45;
    final rightPostX = pos.dx + gateW * 0.45;
    final topY = groundY - gateH;

    // Cybernetic Vertical Pylons
    _gatePostPaint.strokeWidth = 6.0 * scale;
    canvas.drawLine(
      Offset(leftPostX, groundY),
      Offset(leftPostX, topY),
      _gatePostPaint,
    );
    canvas.drawLine(
      Offset(rightPostX, groundY),
      Offset(rightPostX, topY),
      _gatePostPaint,
    );

    // Cyan accent lines on pylons
    _gateNeonLinePaint.strokeWidth = 2.0 * scale;
    canvas.drawLine(
      Offset(leftPostX, groundY),
      Offset(leftPostX, topY),
      _gateNeonLinePaint,
    );
    canvas.drawLine(
      Offset(rightPostX, groundY),
      Offset(rightPostX, topY),
      _gateNeonLinePaint,
    );

    // Top Crossbar
    final crossbarRect = Rect.fromCenter(
      center: Offset(pos.dx, topY + 8 * scale),
      width: gateW * 0.98,
      height: 18 * scale,
    );
    final crossbarRRect =
        RRect.fromRectAndRadius(crossbarRect, Radius.circular(4 * scale));
    canvas.drawRRect(crossbarRRect, _gateCrossbarBgPaint);

    _gateCrossbarBorderPaint.strokeWidth = 1.5 * scale;
    canvas.drawRRect(
      crossbarRRect,
      _gateCrossbarBorderPaint,
    );

    // "UNDER REVIEW" pre-cached text banner
    canvas.save();
    canvas.translate(
      pos.dx - (_reviewGatePainter.width * scale * 0.9) / 2,
      topY + 8 * scale - (_reviewGatePainter.height * scale * 0.9) / 2,
    );
    canvas.scale(scale * 0.9, scale * 0.9);
    _reviewGatePainter.paint(canvas, Offset.zero);
    canvas.restore();

    // High Security Laser Beams (positioned from 55% to 85% height off the ground)
    final laserPulse = (sin(_wobblePhase + depth * 18) * 0.5 + 0.5);
    final laserY1 = topY + 22 * scale;
    final laserY2 = topY + 36 * scale;

    _gateLaserGlowPaint
      ..color =
          const Color(0xFFFF1744).withValues(alpha: 0.25 * laserPulse * scale)
      ..strokeWidth = 8.0 * scale;

    _gateLaserCorePaint
      ..color = const Color(0xFFFF5252).withValues(alpha: 0.95 * scale)
      ..strokeWidth = 3.0 * scale;

    _gateLaserFilamentPaint
      ..color = Colors.white.withValues(alpha: 0.85 * scale)
      ..strokeWidth = 1.2 * scale;

    for (final ly in [laserY1, laserY2]) {
      // Stepped soft outer glow
      canvas.drawLine(
        Offset(leftPostX, ly),
        Offset(rightPostX, ly),
        _gateLaserGlowPaint,
      );
      // Bright laser core
      canvas.drawLine(
        Offset(leftPostX, ly),
        Offset(rightPostX, ly),
        _gateLaserCorePaint,
      );
      // White hot filament
      canvas.drawLine(
        Offset(leftPostX, ly),
        Offset(rightPostX, ly),
        _gateLaserFilamentPaint,
      );
    }
  }
}
