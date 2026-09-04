import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

/// 3D Mario style elevated runway with rolling hills horizon,
/// cartoon clouds, checkered highway pavers, and 3D pylon posts.
class LaneWorld extends Component {
  int totalPatches = 0;
  double _scroll = 0;

  static final _nearLeft = Offset(
    GameConfig.nearLaneX[0] - 130,
    GameConfig.nearY + 20,
  );
  static final _nearRight = Offset(
    GameConfig.nearLaneX[2] + 130,
    GameConfig.nearY + 20,
  );
  static final _farLeft = Offset(
    GameConfig.farLaneX[0] - 25,
    GameConfig.horizonY,
  );
  static final _farRight = Offset(
    GameConfig.farLaneX[2] + 25,
    GameConfig.horizonY,
  );

  Color _curAccentColor = const Color(0xFF00D4FF);
  Color _curRoadColor = const Color(0xFF0B1726);
  Color _curHorizonColor = const Color(0xFF0088CC);

  @override
  void update(double dt) {
    final speed = GameConfig.scrollSpeed(totalPatches);
    _scroll = (_scroll + dt * speed * 0.45) % 1.0;

    final targetLevel = GameConfig.levelFor(totalPatches);
    final targetAccent = Color(targetLevel.accentColor);
    final targetRoad = Color(targetLevel.roadColor);
    final targetHorizon = Color(targetLevel.horizonColor);

    _curAccentColor = Color.lerp(_curAccentColor, targetAccent, dt * 2.5)!;
    _curRoadColor = Color.lerp(_curRoadColor, targetRoad, dt * 2.5)!;
    _curHorizonColor = Color.lerp(_curHorizonColor, targetHorizon, dt * 2.5)!;
  }

  @override
  void render(Canvas canvas) {
    _drawMarioHorizon(canvas);
    _drawRoadSegments(canvas);
    _drawLaneDividers(canvas);
    _drawGuardRails(canvas);
    _draw3DPylons(canvas);
  }

  void _drawMarioHorizon(Canvas canvas) {
    const cy = GameConfig.horizonY;

    // Rolling Mario Hills in distance
    final hillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _curHorizonColor.withValues(alpha: 0.55),
          const Color(0xFF071829),
        ],
      ).createShader(const Rect.fromLTWH(0, cy - 80, GameConfig.designWidth, 80));

    final hillPath = Path()
      ..moveTo(0, cy)
      ..quadraticBezierTo(GameConfig.designWidth * 0.25, cy - 65, GameConfig.designWidth * 0.5, cy - 25)
      ..quadraticBezierTo(GameConfig.designWidth * 0.75, cy - 75, GameConfig.designWidth, cy)
      ..close();
    canvas.drawPath(hillPath, hillPaint);

    // Mario Puffy Cloud
    _drawCloud(canvas, const Offset(GameConfig.vanishingX - 160, cy - 70), 0.7);
    _drawCloud(canvas, const Offset(GameConfig.vanishingX + 170, cy - 85), 0.85);

    // Glowing horizon neon line
    final horizonGlow = Paint()
      ..shader = LinearGradient(
        colors: [
          _curAccentColor.withValues(alpha: 0),
          _curAccentColor.withValues(alpha: 0.9),
          const Color(0xFFFFFFFF),
          _curAccentColor.withValues(alpha: 0.9),
          _curAccentColor.withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromLTRB(_farLeft.dx - 120, cy, _farRight.dx + 120, cy),
      )
      ..strokeWidth = 2.5;

    canvas.drawLine(
      Offset(_farLeft.dx - 120, cy),
      Offset(_farRight.dx + 120, cy),
      horizonGlow,
    );
  }

  void _drawCloud(Canvas canvas, Offset pos, double scale) {
    final cloudPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(pos, 22 * scale, cloudPaint);
    canvas.drawCircle(Offset(pos.dx - 15 * scale, pos.dy + 6 * scale), 16 * scale, cloudPaint);
    canvas.drawCircle(Offset(pos.dx + 18 * scale, pos.dy + 4 * scale), 18 * scale, cloudPaint);
  }

  void _drawRoadSegments(Canvas canvas) {
    const segments = 16;
    for (int i = segments - 1; i >= 0; i--) {
      final tNearNorm = ((i + 1) / segments + _scroll) % 1.0;
      final tFarNorm = (i / segments + _scroll) % 1.0;

      if (tFarNorm > tNearNorm) continue;

      final tNear = pow(tNearNorm, 1.8).toDouble();
      final tFar = pow(tFarNorm, 1.8).toDouble();

      final pNearL = _lerpRoadPoint(0, tNear);
      final pNearR = _lerpRoadPoint(1, tNear);
      final pFarR = _lerpRoadPoint(1, tFar);
      final pFarL = _lerpRoadPoint(0, tFar);

      final path = Path()
        ..moveTo(pNearL.dx, pNearL.dy)
        ..lineTo(pNearR.dx, pNearR.dy)
        ..lineTo(pFarR.dx, pFarR.dy)
        ..lineTo(pFarL.dx, pFarL.dy)
        ..close();

      final isEven = (i % 2 == 0);
      final segmentAlpha = (0.4 + tNear * 0.55).clamp(0.0, 1.0);
      final baseColor = isEven ? _curRoadColor : Color.lerp(_curRoadColor, const Color(0xFF020710), 0.5)!;

      final tilePaint = Paint()
        ..color = baseColor.withValues(alpha: segmentAlpha)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, tilePaint);

      final seamPaint = Paint()
        ..color = _curAccentColor.withValues(alpha: (tNear * 0.35).clamp(0.0, 0.4))
        ..strokeWidth = (1.0 + tNear * 1.5);
      canvas.drawLine(pNearL, pNearR, seamPaint);
    }
  }

  void _drawLaneDividers(Canvas canvas) {
    for (int lane = 1; lane < GameConfig.laneCount; lane++) {
      final laneFrac = lane / GameConfig.laneCount;
      const dashes = 10;

      for (int i = 0; i < dashes; i++) {
        final t1 = pow(((i / dashes) + _scroll) % 1.0, 1.8).toDouble();
        final t2 = pow((((i + 0.5) / dashes) + _scroll) % 1.0, 1.8).toDouble();
        if (t1 > t2) continue;

        final p1 = _lerpRoadPoint(laneFrac, t1);
        final p2 = _lerpRoadPoint(laneFrac, t2);

        final dashAlpha = (t1 * 0.7).clamp(0.0, 0.7);
        final dashPaint = Paint()
          ..color = _curAccentColor.withValues(alpha: dashAlpha)
          ..strokeWidth = 1.0 + t1 * 2.5
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(p1, p2, dashPaint);
      }
    }
  }

  void _drawGuardRails(Canvas canvas) {
    final railGlow = Paint()
      ..color = _curAccentColor.withValues(alpha: 0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final railCore = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(_farLeft, _nearLeft, railGlow);
    canvas.drawLine(_farLeft, _nearLeft, railCore);

    canvas.drawLine(_farRight, _nearRight, railGlow);
    canvas.drawLine(_farRight, _nearRight, railCore);
  }

  void _draw3DPylons(Canvas canvas) {
    const pylonCount = 8;
    for (int i = 0; i < pylonCount; i++) {
      final tRaw = ((i / pylonCount) + _scroll) % 1.0;
      final t = pow(tRaw, 1.8).toDouble();

      final leftBase = _lerpRoadPoint(0, t);
      final rightBase = _lerpRoadPoint(1, t);

      final height = 55.0 * t;
      final width = 4.0 + 8.0 * t;
      final alpha = (t * 0.9).clamp(0.0, 0.9);

      if (height < 2) continue;

      _drawSinglePylon(canvas, leftBase, height, width, alpha, isLeft: true);
      _drawSinglePylon(canvas, rightBase, height, width, alpha, isLeft: false);
    }
  }

  void _drawSinglePylon(
    Canvas canvas,
    Offset base,
    double height,
    double width,
    double alpha, {
    required bool isLeft,
  }) {
    final top = Offset(base.dx + (isLeft ? -width * 0.8 : width * 0.8), base.dy - height);

    final postPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFF0A192F).withValues(alpha: alpha),
          _curAccentColor.withValues(alpha: alpha),
        ],
      ).createShader(Rect.fromPoints(base, top))
      ..strokeWidth = width * 0.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base, top, postPaint);

    final beaconGlow = Paint()
      ..color = _curAccentColor.withValues(alpha: alpha * 0.7)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, width * 1.5);
    canvas.drawCircle(top, width * 0.9, beaconGlow);

    final beaconCore = Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: alpha);
    canvas.drawCircle(top, width * 0.45, beaconCore);
  }

  Offset _lerpRoadPoint(double xFrac, double t) {
    final leftX = _farLeft.dx + (_nearLeft.dx - _farLeft.dx) * t;
    final rightX = _farRight.dx + (_nearRight.dx - _farRight.dx) * t;
    final x = leftX + (rightX - leftX) * xFrac;
    final y = GameConfig.horizonY + (GameConfig.nearY - GameConfig.horizonY) * t;
    return Offset(x, y);
  }
}
