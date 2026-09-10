import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:shorebird_runner/game/utils/utils.dart';

/// 3D Mario / Subway Surfers elevated runway with GTA 5 nighttime skyline,
/// rolling hills horizon, checkered highway pavers, dynamic runway light bars,
/// and 3D pylon posts.
/// Optimized for steady 120 FPS with pre-baked window geometry and cached text.
class LaneWorld extends Component {
  int totalPatches = 0;
  bool isInvincible = false;
  double _scroll = 0;

  Offset get _nearLeft => Offset(
        GameConfig.nearLaneX[0] -
            (GameConfig.nearLaneX[1] - GameConfig.nearLaneX[0]) * 0.5,
        GameConfig.nearY + 20,
      );
  Offset get _nearRight => Offset(
        GameConfig.nearLaneX[2] +
            (GameConfig.nearLaneX[2] - GameConfig.nearLaneX[1]) * 0.5,
        GameConfig.nearY + 20,
      );
  Offset get _farLeft => Offset(
        GameConfig.farLaneX[0] -
            (GameConfig.farLaneX[1] - GameConfig.farLaneX[0]) * 0.5,
        GameConfig.horizonY,
      );
  Offset get _farRight => Offset(
        GameConfig.farLaneX[2] +
            (GameConfig.farLaneX[2] - GameConfig.farLaneX[1]) * 0.5,
        GameConfig.horizonY,
      );

  Color _curAccentColor = const Color(0xFFFFC107);
  Color _curRoadColor = const Color(0xFF0B1118);
  Color _curHorizonColor = const Color(0xFFFF8F00);

  double _searchlightAngle = 0.0;

  // Pre-baked skyline geometry paths to eliminate hundreds of per-frame drawRect calls
  final Path _mountainPath = Path();
  final Path _skylineBuildingsPath = Path();
  final Path _amberWindowsPath = Path();
  final Path _cyanWindowsPath = Path();

  // Reusable paths for zero-allocation rendering loops
  final Path _segmentPath = Path();
  final Path _chevronPath = Path();
  final Path _refPath = Path();
  final Path _searchlightBeamPath = Path();

  // Cached TextPainters for Billboards & Gantry
  final Map<String, TextPainter> _cachedBillboards = {};
  final List<TextPainter> _cachedGantryTexts = [];

  // Reusable paints
  final Paint _mountainPaint = Paint();
  final Paint _hazePaint = Paint();
  final Paint _spirePaint = Paint()
    ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
    ..strokeWidth = 1.8;
  final Paint _antPaint = Paint()
    ..color = const Color(0xFF64748B)
    ..strokeWidth = 1.5;
  final Paint _amberWinPaint = Paint()
    ..color = const Color(0xFFFFD166).withValues(alpha: 0.8)
    ..style = PaintingStyle.fill;
  final Paint _cyanWinPaint = Paint()
    ..color = const Color(0xFF00E5FF).withValues(alpha: 0.7)
    ..style = PaintingStyle.fill;
  final Paint _bldFillPaint = Paint()..style = PaintingStyle.fill;
  final Paint _tilePaint = Paint()..style = PaintingStyle.fill;
  final Paint _seamPaint = Paint();
  final Paint _chevronPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint _dashPaint = Paint()..strokeCap = StrokeCap.round;
  final Paint _railGlow = Paint()..style = PaintingStyle.stroke;
  final Paint _railCore = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;
  final Paint _postPaint = Paint()..strokeCap = StrokeCap.round;
  final Paint _trussPaint = Paint();
  final Paint _boardBgPaint = Paint()
    ..color = const Color(0xFF070B14)
    ..style = PaintingStyle.fill;
  final Paint _boardBorderPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _bracketPaint = Paint()..style = PaintingStyle.stroke;

  // Cached ambient & billboard paints
  final Paint _searchlightPaintCyan = Paint();
  final Paint _searchlightPaintAmber = Paint();
  final Paint _bloomPaint = Paint();
  final Paint _horizonGlowPaint = Paint()..strokeWidth = 2.8;
  final Paint _towerPaint = Paint();
  final Paint _bbBgPaint = Paint()
    ..color = const Color(0xFF050B14)
    ..style = PaintingStyle.fill;
  final Paint _bbBorderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;
  final Paint _beaconGlow = Paint();
  final Paint _beaconMid = Paint();
  final Paint _beaconCore = Paint()..color = const Color(0xFFFFFFFF);
  final List<Paint> _refPaints =
      List.generate(3, (_) => Paint()..style = PaintingStyle.fill);

  @override
  Future<void> onLoad() async {
    _initStaticGeometry();
    _initCachedTextPainters();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _initStaticGeometry();
  }

  double _bldScale = 0.45;

  void _initStaticGeometry() {
    _mountainPath.reset();
    _skylineBuildingsPath.reset();
    _amberWindowsPath.reset();
    _cyanWindowsPath.reset();

    final cy = GameConfig.horizonY;
    final w = GameConfig.designWidth;
    final isDesktop = w > GameConfig.designHeight;
    _bldScale = (cy / 260.0).clamp(0.26, 0.55);
    final mtnHeight = cy * (isDesktop ? 0.30 : 0.45);

    // Mountain Ridge
    _mountainPath
      ..moveTo(0, cy)
      ..lineTo(0, cy - mtnHeight * 0.5)
      ..quadraticBezierTo(
        w * 0.15,
        cy - mtnHeight * 0.9,
        w * 0.30,
        cy - mtnHeight * 0.55,
      )
      ..quadraticBezierTo(
        w * 0.45,
        cy - mtnHeight,
        w * 0.60,
        cy - mtnHeight * 0.45,
      )
      ..quadraticBezierTo(
        w * 0.80,
        cy - mtnHeight * 0.85,
        w,
        cy - mtnHeight * 0.6,
      )
      ..lineTo(w, cy)
      ..close();

    // Pre-bake Skyscraper Building blocks and window batches
    final buildings = [
      (w * 0.02, 52.0, 90.0 * _bldScale, 0),
      (w * 0.08, 48.0, 120.0 * _bldScale, 1),
      (w * 0.15, 58.0, 75.0 * _bldScale, 2),
      (w * 0.22, 68.0, 135.0 * _bldScale, 3),
      (w * 0.30, 52.0, 100.0 * _bldScale, 4),
      (w * 0.68, 54.0, 110.0 * _bldScale, 5),
      (w * 0.75, 70.0, 145.0 * _bldScale, 6),
      (w * 0.83, 58.0, 88.0 * _bldScale, 7),
      (w * 0.90, 64.0, 115.0 * _bldScale, 8),
      (w * 0.96, 48.0, 80.0 * _bldScale, 9),
    ];

    for (final b in buildings) {
      final bx = b.$1;
      final bw = b.$2;
      final bh = b.$3;
      final seed = b.$4;

      _skylineBuildingsPath.addRect(Rect.fromLTWH(bx, cy - bh, bw, bh));

      // Batch windows into 2 unified paths
      final winCols = (bw / 10).floor();
      final winRows = (bh / 10).floor();
      for (int r = 1; r < winRows; r++) {
        for (int c = 1; c < winCols; c++) {
          final hash = (seed * 37 + r * 19 + c * 7) % 100;
          if (hash > 45) {
            final winRect =
                Rect.fromLTWH(bx + c * 10 - 2, cy - bh + r * 10, 4, 5);
            if (hash % 2 == 0) {
              _amberWindowsPath.addRect(winRect);
            } else {
              _cyanWindowsPath.addRect(winRect);
            }
          }
        }
      }
    }

    // Pre-cache landscape and architectural shaders
    _mountainPaint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0F0826), Color(0xFF060312)],
    ).createShader(Rect.fromLTWH(0, 0, w, cy));

    _bldFillPaint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0D1826), Color(0xFF040810)],
    ).createShader(Rect.fromLTWH(0, 0, w, cy));

    _towerPaint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF09061A), Color(0xFF04020C)],
    ).createShader(Rect.fromLTWH(0, 0, w, cy));

    _searchlightPaintCyan.shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        const Color(0xFF00E5FF).withValues(alpha: 0.22),
        const Color(0xFF00E5FF).withValues(alpha: 0.0),
      ],
    ).createShader(const Rect.fromLTWH(-50, -140, 100, 140));

    _searchlightPaintAmber.shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        const Color(0xFFFFB300).withValues(alpha: 0.22),
        const Color(0xFFFFB300).withValues(alpha: 0.0),
      ],
    ).createShader(const Rect.fromLTWH(-50, -140, 100, 140));

    const refColors = [
      Color(0xFF00E5FF),
      Color(0xFFFFC107),
      Color(0xFF00FFCC),
    ];
    for (int i = 0; i < 3; i++) {
      _refPaints[i].shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          refColors[i].withValues(alpha: 0.15),
          refColors[i].withValues(alpha: 0.07),
          refColors[i].withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, cy, w, GameConfig.nearY - cy));
    }

    _updateThemeShaders();
  }

  void _updateThemeShaders() {
    final cy = GameConfig.horizonY;
    final w = GameConfig.designWidth;

    _hazePaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        _curHorizonColor.withValues(alpha: 0.0),
        _curHorizonColor.withValues(alpha: 0.40),
        const Color(0xFF030712),
      ],
      stops: const [0.0, 0.65, 1.0],
    ).createShader(Rect.fromLTWH(0, cy * 0.2, w, cy * 0.8));

    _bloomPaint.shader = RadialGradient(
      colors: [
        _curAccentColor.withValues(alpha: 0.55),
        _curAccentColor.withValues(alpha: 0.20),
        const Color(0x00000000),
      ],
      stops: const [0.0, 0.45, 1.0],
    ).createShader(
      Rect.fromCircle(
        center: Offset(GameConfig.vanishingX, cy),
        radius: 110,
      ),
    );

    _horizonGlowPaint.shader = LinearGradient(
      colors: [
        _curAccentColor.withValues(alpha: 0),
        _curAccentColor.withValues(alpha: 0.95),
        const Color(0xFFFFFFFF),
        _curAccentColor.withValues(alpha: 0.95),
        _curAccentColor.withValues(alpha: 0),
      ],
    ).createShader(
      Rect.fromLTRB(_farLeft.dx - 160, cy, _farRight.dx + 160, cy),
    );
  }

  int _lastShaderLevel = -1;

  void _initCachedTextPainters() {
    // Billboards
    const billboards = [
      ('SHOREBIRD', Color(0xFFFFC107)),
      ('CODEPUSH', Color(0xFFFFB300)),
      ('FLUTTER', Color(0xFF00FFCC)),
    ];

    for (final b in billboards) {
      final tp = TextPainter(
        text: TextSpan(
          text: b.$1,
          style: TextStyle(
            color: b.$2,
            fontSize: 7.0,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      _cachedBillboards[b.$1] = tp;
    }

    // Gantry Quota Texts
    const tiers = [
      '⚡ HOBBY · 5,000 PATCHES',
      '⚡ PRO · 50,000 PATCHES',
      '⚡ BUSINESS · 1,000,000 PATCHES',
      '⚡ ENTERPRISE · CUSTOM PATCHES',
    ];

    for (final t in tiers) {
      final tp = TextPainter(
        text: TextSpan(
          text: t,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 10.0,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      _cachedGantryTexts.add(tp);
    }
  }

  @override
  void update(double dt) {
    final speed =
        GameConfig.scrollSpeed(totalPatches, isInvincible: isInvincible);
    _scroll = (_scroll + dt * speed * 0.45) % 1.0;
    _searchlightAngle += dt * 0.85;

    final targetLevel = GameConfig.levelFor(totalPatches);
    final targetAccent = Color(targetLevel.accentColor);
    final targetRoad = Color(targetLevel.roadColor);
    final targetHorizon = Color(targetLevel.horizonColor);

    _curAccentColor = Color.lerp(_curAccentColor, targetAccent, dt * 2.5)!;
    _curRoadColor = Color.lerp(_curRoadColor, targetRoad, dt * 2.5)!;
    _curHorizonColor = Color.lerp(_curHorizonColor, targetHorizon, dt * 2.5)!;

    if (_lastShaderLevel != targetLevel.level) {
      _lastShaderLevel = targetLevel.level;
      _updateThemeShaders();
    }
  }

  @override
  void render(Canvas canvas) {
    _drawCinematicCityscape(canvas);
    _drawRoadSegments(canvas);
    _drawLaneDividers(canvas);
    _drawGuardRails(canvas);
    _draw3DPylons(canvas);
    _drawPlanGantry(canvas);
  }

  void _drawCinematicCityscape(Canvas canvas) {
    final cy = GameConfig.horizonY;
    final w = GameConfig.designWidth;
    final isDesktop = w > GameConfig.designHeight;

    // 1. Distant Mountain Ridge Silhouettes against Twilight Sky (cached shader)
    canvas.drawPath(_mountainPath, _mountainPaint);

    // 2. Deep Atmospheric Horizon Fog Haze
    canvas.drawRect(
      Rect.fromLTWH(0, cy * 0.2, w, cy * 0.8),
      _hazePaint,
    );

    // 3. Sweeping Hollywood / Los Santos Searchlight Beams (zero allocations)
    _drawSearchlight(
      canvas,
      w * 0.22,
      cy,
      _searchlightAngle,
      _searchlightPaintCyan,
    );
    _drawSearchlight(
      canvas,
      w * 0.78,
      cy,
      -_searchlightAngle * 0.9 + 1.2,
      _searchlightPaintAmber,
    );

    // 4. Distant Giant Spire Towers (scaled relative to sky height)
    final towerHeight = cy * (isDesktop ? 0.48 : 0.65);
    _drawDistantTower(canvas, w * 0.36, cy, 32, towerHeight);
    _drawDistantTower(canvas, w * 0.64, cy, 36, towerHeight * 1.1);

    // 5. Pre-baked Skyscraper Silhouettes & Lit Window Paths (Zero loop allocations!)
    canvas.drawPath(_skylineBuildingsPath, _bldFillPaint);
    canvas.drawPath(_amberWindowsPath, _amberWinPaint);
    canvas.drawPath(_cyanWindowsPath, _cyanWinPaint);

    // Billboards & Rooftop Antennas
    _drawRooftopElements(canvas, cy);

    // 6. Horizon Vanishing Point Volumetric Lens Bloom (cached paint)
    canvas.drawCircle(Offset(GameConfig.vanishingX, cy), 110, _bloomPaint);

    // 7. Glowing Horizon Laser Neon Line
    canvas.drawLine(
      Offset(_farLeft.dx - 160, cy),
      Offset(_farRight.dx + 160, cy),
      _horizonGlowPaint,
    );

    // 8. Wet asphalt specular road reflections (zero allocations)
    _drawWetRoadReflections(canvas);
  }

  void _drawRooftopElements(Canvas canvas, double cy) {
    final w = GameConfig.designWidth;

    // Billboards
    _renderCachedBillboard(
      canvas,
      w * 0.08,
      cy - 120.0 * _bldScale,
      48,
      'SHOREBIRD',
      const Color(0xFFFFC107),
    );
    _renderCachedBillboard(
      canvas,
      w * 0.75,
      cy - 145.0 * _bldScale,
      70,
      'CODEPUSH',
      const Color(0xFFFFB300),
    );
    _renderCachedBillboard(
      canvas,
      w * 0.90,
      cy - 115.0 * _bldScale,
      64,
      'FLUTTER',
      const Color(0xFF00FFCC),
    );

    // Blinking radio antennas
    _drawAntenna(canvas, w * 0.08 + 24, cy - 120.0 * _bldScale, 0);
    _drawAntenna(canvas, w * 0.22 + 34, cy - 135.0 * _bldScale, 1);
    _drawAntenna(canvas, w * 0.75 + 35, cy - 145.0 * _bldScale, 2);
  }

  void _renderCachedBillboard(
    Canvas canvas,
    double x,
    double topY,
    double w,
    String text,
    Color borderColor,
  ) {
    final bbY = topY - 14;
    final bbRect = Rect.fromLTWH(x - 2, bbY, w + 4, 12);
    final rrect = RRect.fromRectAndRadius(bbRect, const Radius.circular(2));

    canvas.drawRRect(rrect, _bbBgPaint);

    _bbBorderPaint.color = borderColor.withValues(alpha: 0.85);
    canvas.drawRRect(rrect, _bbBorderPaint);

    final tp = _cachedBillboards[text];
    if (tp != null) {
      tp.paint(
        canvas,
        Offset(x + (w - tp.width) / 2, bbY + (12 - tp.height) / 2),
      );
    }
  }

  void _drawAntenna(Canvas canvas, double x, double baseY, int seed) {
    final antH = 16.0 * (_bldScale / 0.45).clamp(0.6, 1.2);
    canvas.drawLine(Offset(x, baseY), Offset(x, baseY - antH), _antPaint);
    final beaconFlash = sin(_searchlightAngle * 4 + seed) > 0.0;
    if (beaconFlash) {
      final tip = Offset(x, baseY - antH);
      _beaconGlow.color = const Color(0x66FF2A4B);
      canvas.drawCircle(tip, 3.5, _beaconGlow);

      _beaconMid.color = const Color(0xFFFF2A4B);
      canvas.drawCircle(tip, 1.8, _beaconMid);

      canvas.drawCircle(tip, 1.0, _beaconCore);
    }
  }

  void _drawDistantTower(
    Canvas canvas,
    double x,
    double baseY,
    double w,
    double h,
  ) {
    final rect = Rect.fromLTWH(x - w * 0.5, baseY - h, w, h);
    canvas.drawRect(rect, _towerPaint);
    canvas.drawLine(
      Offset(x, baseY - h),
      Offset(x, baseY - h - 35),
      _spirePaint,
    );
    _beaconMid.color = const Color(0xFFFF2A4B);
    canvas.drawCircle(
      Offset(x, baseY - h - 35),
      2.5,
      _beaconMid,
    );
  }

  void _drawSearchlight(
    Canvas canvas,
    double x,
    double y,
    double angle,
    Paint beamPaint,
  ) {
    canvas.save();
    canvas.translate(x, y);
    _searchlightBeamPath
      ..reset()
      ..moveTo(0, 0)
      ..lineTo(sin(angle) * 70 - 24, -140)
      ..lineTo(sin(angle) * 70 + 24, -140)
      ..close();
    canvas.drawPath(_searchlightBeamPath, beamPaint);
    canvas.restore();
  }

  void _drawWetRoadReflections(Canvas canvas) {
    const reflections = [1.0 / 6.0, 0.50, 5.0 / 6.0];

    for (int i = 0; i < reflections.length; i++) {
      final xFrac = reflections[i];
      final pFar = _lerpRoadPoint(xFrac, 0.05);
      final pNear = _lerpRoadPoint(xFrac, 0.95);

      const widthFar = 4.0;
      const widthNear = 28.0;

      _refPath
        ..reset()
        ..moveTo(pFar.dx - widthFar / 2, pFar.dy)
        ..lineTo(pFar.dx + widthFar / 2, pFar.dy)
        ..lineTo(pNear.dx + widthNear / 2, pNear.dy)
        ..lineTo(pNear.dx - widthNear / 2, pNear.dy)
        ..close();

      canvas.drawPath(_refPath, _refPaints[i]);
    }
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

      _segmentPath
        ..reset()
        ..moveTo(pNearL.dx, pNearL.dy)
        ..lineTo(pNearR.dx, pNearR.dy)
        ..lineTo(pFarR.dx, pFarR.dy)
        ..lineTo(pFarL.dx, pFarL.dy)
        ..close();

      final isEven = (i % 2 == 0);
      final segmentAlpha = (0.4 + tNear * 0.55).clamp(0.0, 1.0);
      final baseColor = isEven
          ? _curRoadColor
          : Color.lerp(_curRoadColor, const Color(0xFF020710), 0.5)!;

      _tilePaint.color = baseColor.withValues(alpha: segmentAlpha);
      canvas.drawPath(_segmentPath, _tilePaint);

      _seamPaint
        ..color =
            _curAccentColor.withValues(alpha: (tNear * 0.35).clamp(0.0, 0.4))
        ..strokeWidth = (1.0 + tNear * 1.5);
      canvas.drawLine(pNearL, pNearR, _seamPaint);

      // Dynamic forward-pulsing chevrons in center lane
      if (i % 3 == 0 && tNear > 0.15 && tNear < 0.88) {
        final chevronCenter = _lerpRoadPoint(0.5, tNear);
        final chW = (16.0 * tNear).clamp(3.0, 24.0);
        final chH = (8.0 * tNear).clamp(2.0, 12.0);

        _chevronPath
          ..reset()
          ..moveTo(chevronCenter.dx - chW, chevronCenter.dy + chH)
          ..lineTo(chevronCenter.dx, chevronCenter.dy - chH * 0.4)
          ..lineTo(chevronCenter.dx + chW, chevronCenter.dy + chH);

        _chevronPaint
          ..color =
              _curAccentColor.withValues(alpha: (tNear * 0.45).clamp(0.0, 0.45))
          ..strokeWidth = (1.2 + tNear * 2.0);

        canvas.drawPath(_chevronPath, _chevronPaint);
      }
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

        final dashAlpha = (t1 * 0.9).clamp(0.15, 0.95);
        _dashPaint
          ..color = _curAccentColor.withValues(alpha: dashAlpha)
          ..strokeWidth = 2.0 + t1 * 3.5;

        canvas.drawLine(p1, p2, _dashPaint);
      }
    }
  }

  void _drawGuardRails(Canvas canvas) {
    _railGlow
      ..color = _curAccentColor.withValues(alpha: 0.35)
      ..strokeWidth = 6.0;
    canvas.drawLine(_farLeft, _nearLeft, _railGlow);
    canvas.drawLine(_farRight, _nearRight, _railGlow);

    _railGlow
      ..color = _curAccentColor.withValues(alpha: 0.85)
      ..strokeWidth = 2.5;
    canvas.drawLine(_farLeft, _nearLeft, _railGlow);
    canvas.drawLine(_farRight, _nearRight, _railGlow);

    canvas.drawLine(_farLeft, _nearLeft, _railCore);
    canvas.drawLine(_farRight, _nearRight, _railCore);
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
    final top = Offset(
      base.dx + (isLeft ? -width * 0.8 : width * 0.8),
      base.dy - height,
    );

    _postPaint
      ..shader = null
      ..color = Color.lerp(const Color(0xFF0A192F), _curAccentColor, 0.45)!
          .withValues(alpha: alpha)
      ..strokeWidth = width * 0.6;
    canvas.drawLine(base, top, _postPaint);

    // Multi-ring concentric beacon glow (zero per-frame allocations)
    final beaconColor = _curAccentColor.withValues(alpha: alpha);
    _beaconGlow.color = beaconColor.withValues(alpha: alpha * 0.25);
    canvas.drawCircle(top, width * 1.2, _beaconGlow);

    _beaconMid.color = beaconColor.withValues(alpha: alpha * 0.7);
    canvas.drawCircle(top, width * 0.7, _beaconMid);

    _beaconCore.color = const Color(0xFFFFFFFF).withValues(alpha: alpha);
    canvas.drawCircle(top, width * 0.35, _beaconCore);
  }

  void _drawPlanGantry(Canvas canvas) {
    final gantryT = ((_scroll * 1.8) % 1.0);
    if (gantryT < 0.25 || gantryT > 0.88) return;

    final t = pow(gantryT, 1.8).toDouble();
    final pLeftBase = _lerpRoadPoint(-0.04, t);
    final pRightBase = _lerpRoadPoint(1.04, t);

    final gantryHeight = 110.0 * t;
    final alpha = (t * 0.95).clamp(0.0, 0.95);
    if (gantryHeight < 15) return;

    final pLeftTop = Offset(pLeftBase.dx, pLeftBase.dy - gantryHeight);
    final pRightTop = Offset(pRightBase.dx, pRightBase.dy - gantryHeight);

    _trussPaint
      ..color = const Color(0xFF1E293B).withValues(alpha: alpha)
      ..strokeWidth = 2.5 + t * 4.0;
    canvas.drawLine(pLeftBase, pLeftTop, _trussPaint);
    canvas.drawLine(pRightBase, pRightTop, _trussPaint);
    canvas.drawLine(pLeftTop, pRightTop, _trussPaint);

    // Board
    final midX = (pLeftTop.dx + pRightTop.dx) * 0.5;
    final boardY = pLeftTop.dy;
    final boardW = (pRightTop.dx - pLeftTop.dx) * 0.82;
    final boardH = 24.0 * t;

    final boardRect = Rect.fromCenter(
      center: Offset(midX, boardY),
      width: boardW,
      height: boardH,
    );

    _boardBgPaint
      ..shader = null
      ..color = const Color(0xFF0A1324).withValues(alpha: alpha * 0.95);
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, Radius.circular(4 * t)),
      _boardBgPaint,
    );

    _boardBorderPaint
      ..color = _curAccentColor.withValues(alpha: alpha * 0.9)
      ..strokeWidth = 1.6 * t;
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, Radius.circular(4 * t)),
      _boardBorderPaint,
    );

    // Brackets
    final bracketLen = 6.0 * t;
    _bracketPaint
      ..color = const Color(0xFFFFFFFF).withValues(alpha: alpha)
      ..strokeWidth = 2.0 * t;
    canvas.drawLine(
      Offset(boardRect.left, boardRect.top + bracketLen),
      Offset(boardRect.left, boardRect.top),
      _bracketPaint,
    );
    canvas.drawLine(
      Offset(boardRect.left, boardRect.top),
      Offset(boardRect.left + bracketLen, boardRect.top),
      _bracketPaint,
    );
    canvas.drawLine(
      Offset(boardRect.right - bracketLen, boardRect.top),
      Offset(boardRect.right, boardRect.top),
      _bracketPaint,
    );
    canvas.drawLine(
      Offset(boardRect.right, boardRect.top),
      Offset(boardRect.right, boardRect.top + bracketLen),
      _bracketPaint,
    );

    // Render Cached Plan Text
    final level = GameConfig.levelFor(totalPatches);
    final idx = (level.level - 1).clamp(0, _cachedGantryTexts.length - 1);
    final tp = _cachedGantryTexts[idx];

    canvas.save();
    canvas.translate(midX, boardY);
    canvas.scale((t * 0.95).clamp(0.3, 1.2));
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  Offset _lerpRoadPoint(double xFrac, double t) {
    final leftX = _farLeft.dx + (_nearLeft.dx - _farLeft.dx) * t;
    final rightX = _farRight.dx + (_nearRight.dx - _farRight.dx) * t;
    final x = leftX + (rightX - leftX) * xFrac;
    final y =
        GameConfig.horizonY + (GameConfig.nearY - GameConfig.horizonY) * t;
    return Offset(x, y);
  }
}
