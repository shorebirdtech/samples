import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

/// High-Performance Heads-Up Display overlay — Shorebird brand themed.
/// Zero per-frame text layouts (cached TextPainters for 120 FPS smoothness),
/// gold/amber accent, clean glassmorphic panel, stage progression bar.
class Hud extends Component {
  int _score = 0;
  int get score => _score;
  set score(int val) {
    if (_score != val) {
      _score = val;
      _updateScorePainter();
    }
  }

  int highScore = 0;
  int _totalPatches = 0;
  int get totalPatches => _totalPatches;
  set totalPatches(int val) {
    if (_totalPatches != val) {
      _totalPatches = val;
      _updatePatchPainters();
    }
  }

  int _combo = 0;
  int get combo => _combo;
  set combo(int val) {
    if (_combo != val) {
      _combo = val;
      _updateComboPainter();
    }
  }

  double _elapsed = 0;
  double get elapsed => _elapsed;
  set elapsed(double val) {
    _elapsed = val;
    final sec = val.toInt();
    if (sec != _lastSecond) {
      _lastSecond = sec;
      _updateTimePainter();
    }
  }

  String? playerTag;

  double _levelUpBannerTimer = 0;
  LevelConfig? _bannerLevel;

  double _comboFlash = 0;
  double _missFlash = 0;
  double _time = 0;
  int _lastSecond = -1;
  int _lastLevelNum = -1;

  // Shorebird brand colors
  static const _shorebirdGold = Color(0xFFFFC107);
  static const _textPrimary = Color(0xFFECEFF1);
  static const _textMuted = Color(0xFF64748B);

  // Cached TextPainters — updated ONLY when content changes!
  TextPainter? _tpPlanLabel;
  TextPainter? _tpPlanName;
  TextPainter? _tpScoreLabel;
  TextPainter? _tpScoreValue;
  TextPainter? _tpNextLabel;
  TextPainter? _tpNextValue;
  TextPainter? _tpLogo;
  TextPainter? _tpCombo;
  TextPainter? _tpBannerTitle;
  TextPainter? _tpBannerName;
  TextPainter? _tpBannerQuota;

  // Reusable paint objects to avoid allocations in render()
  final Paint _bgPaint = Paint();
  final Paint _sheenPaint = Paint();
  final Paint _borderPaint = Paint();
  final Paint _missOverlayPaint = Paint();
  final Paint _trackPaint = Paint()..color = const Color(0xFF1E293B);
  final Paint _progressFillPaint = Paint();
  final Paint _orbCorePaint = Paint()..color = const Color(0xFFFFFFFF);
  final Paint _orbGlowPaint = Paint();
  final Paint _comboBgPaint = Paint();
  final Paint _comboBorderPaint = Paint()..style = PaintingStyle.stroke;

  Hud({this.playerTag}) {
    _initStaticPainters();
    _updateScorePainter();
    _updateTimePainter();
    _updatePatchPainters();
    _updateComboPainter();
  }

  void _initStaticPainters() {
    _tpLogo = TextPainter(
      text: const TextSpan(text: '🐤', style: TextStyle(fontSize: 18)),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void _updateScorePainter() {
    _tpScoreValue = TextPainter(
      text: TextSpan(
        text: _score.toString().padLeft(7, '0'),
        style: const TextStyle(
          color: _textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void _updateTimePainter() {
    final mins = (_elapsed ~/ 60).toString().padLeft(2, '0');
    final secs = (_elapsed.toInt() % 60).toString().padLeft(2, '0');
    _tpScoreLabel = TextPainter(
      text: TextSpan(
        text: 'SCORE   ·   $mins:$secs',
        style: const TextStyle(
          color: _textMuted,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void _updatePatchPainters() {
    final curLevel = GameConfig.levelFor(_totalPatches);

    if (curLevel.level != _lastLevelNum) {
      _lastLevelNum = curLevel.level;
      final planText = playerTag != null
          ? '$playerTag  ·  ${curLevel.planQuota}'
          : 'PLAN  ·  ${curLevel.planQuota}';

      _tpPlanLabel = TextPainter(
        text: TextSpan(
          text: planText,
          style: const TextStyle(
            color: _textMuted,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      _tpPlanName = TextPainter(
        text: TextSpan(
          text: '${curLevel.emoji}  ${curLevel.name}',
          style: const TextStyle(
            color: _shorebirdGold,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    }

    final nextLvl = GameConfig.nextLevel(_totalPatches);
    final patchesInLevel = _totalPatches - curLevel.patchThreshold;
    final nextText = nextLvl != null
        ? '$patchesInLevel / ${curLevel.patchesNeeded}  🐤'
        : 'ENTERPRISE  👑';
    final nextLabel = nextLvl != null ? 'NEXT: ${nextLvl.name}' : 'MAX TIER';

    _tpNextLabel = TextPainter(
      text: TextSpan(
        text: nextLabel,
        style: const TextStyle(
          color: _textMuted,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    _tpNextValue = TextPainter(
      text: TextSpan(
        text: nextText,
        style: TextStyle(
          color: Color(curLevel.accentColor),
          fontSize: 15,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void _updateComboPainter() {
    if (_combo > 1) {
      _tpCombo = TextPainter(
        text: TextSpan(
          text: '🔥  STREAK  ×$_combo',
          style: const TextStyle(
            color: Color(0xFFFFE082),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    }
  }

  void triggerComboFlash() => _comboFlash = 1.0;
  void triggerMissFlash() => _missFlash = 1.0;

  void triggerLevelUp(LevelConfig newLevel) {
    _bannerLevel = newLevel;
    _levelUpBannerTimer = 3.0;

    _tpBannerTitle = TextPainter(
      text: const TextSpan(
        text: '🚀  PLAN UPGRADED  ·  LEVEL UP!',
        style: TextStyle(
          color: _shorebirdGold,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    _tpBannerName = TextPainter(
      text: TextSpan(
        text: '${newLevel.emoji}  ${newLevel.name}  PLAN',
        style: TextStyle(
          color: Color(newLevel.accentColor),
          fontSize: 26,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    _tpBannerQuota = TextPainter(
      text: TextSpan(
        text: '${newLevel.planQuota}  ·  SPEED BOOST!',
        style: const TextStyle(
          color: _textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  @override
  void update(double dt) {
    _time += dt;
    if (_comboFlash > 0) _comboFlash = (_comboFlash - dt * 3.5).clamp(0, 1);
    if (_missFlash > 0) _missFlash = (_missFlash - dt * 3.0).clamp(0, 1);
    if (_levelUpBannerTimer > 0) {
      _levelUpBannerTimer = (_levelUpBannerTimer - dt).clamp(0, 10);
    }
  }

  @override
  void render(Canvas canvas) {
    _drawTopPanel(canvas);
    _drawStageProgressBar(canvas);
    if (_combo > 1 && _tpCombo != null) _drawComboBadge(canvas);
    if (_levelUpBannerTimer > 0 && _bannerLevel != null) {
      _drawLevelUpBanner(canvas);
    }
  }

  void _drawTopPanel(Canvas canvas) {
    final isMissing = _missFlash > 0;
    final accentColor = isMissing ? const Color(0xFFFF3D57) : _shorebirdGold;

    // Panel background — deep navy with subtle gradient
    const panelRect = Rect.fromLTWH(0, 0, GameConfig.designWidth, 68);
    _bgPaint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xF00D111A),
        Color(0xF007090F),
      ],
    ).createShader(panelRect);
    canvas.drawRect(panelRect, _bgPaint);

    // Top sheen
    const sheenRect = Rect.fromLTWH(0, 0, GameConfig.designWidth, 18);
    _sheenPaint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0x14FFFFFF),
        Color(0x00FFFFFF),
      ],
    ).createShader(sheenRect);
    canvas.drawRect(sheenRect, _sheenPaint);

    // Shorebird gold bottom border
    const borderRect = Rect.fromLTWH(0, 67, GameConfig.designWidth, 1.5);
    _borderPaint.shader = LinearGradient(
      colors: [
        accentColor.withValues(alpha: 0.0),
        accentColor.withValues(alpha: 0.9),
        accentColor.withValues(alpha: 0.0),
      ],
    ).createShader(borderRect);
    canvas.drawRect(borderRect, _borderPaint);

    // Miss flash overlay
    if (isMissing) {
      _missOverlayPaint.color =
          const Color(0xFFFF3D57).withValues(alpha: _missFlash * 0.22);
      canvas.drawRect(panelRect, _missOverlayPaint);
    }

    // ── LEFT: Plan Tier ──
    _tpPlanLabel?.paint(canvas, const Offset(18, 10));
    _tpPlanName?.paint(canvas, const Offset(18, 26));

    // ── CENTER: Score ──
    if (_tpScoreLabel != null) {
      _tpScoreLabel!.paint(
        canvas,
        Offset((GameConfig.designWidth - _tpScoreLabel!.width) / 2, 12),
      );
    }
    if (_tpScoreValue != null) {
      _tpScoreValue!.paint(
        canvas,
        Offset((GameConfig.designWidth - _tpScoreValue!.width) / 2, 28),
      );
    }

    // ── RIGHT: Next Level Progress ──
    _tpNextLabel?.paint(canvas, const Offset(GameConfig.designWidth - 178, 10));
    _tpNextValue?.paint(canvas, const Offset(GameConfig.designWidth - 178, 26));

    // 🐤 Shorebird logo mark on the far right
    _tpLogo?.paint(canvas, const Offset(GameConfig.designWidth - 30, 24));
  }

  void _drawStageProgressBar(Canvas canvas) {
    final curLevel = GameConfig.levelFor(_totalPatches);
    final accent = Color(curLevel.accentColor);
    final fraction = GameConfig.levelProgressFraction(_totalPatches);
    const barY = 67.5;
    const barH = 3.5;

    // Track
    canvas.drawRect(
      const Rect.fromLTWH(0, barY, GameConfig.designWidth, barH),
      _trackPaint,
    );

    // Fill with accent gradient
    if (fraction > 0) {
      final fillW = GameConfig.designWidth * fraction;
      final fillRect = Rect.fromLTWH(0, barY, fillW, barH);
      _progressFillPaint.shader = LinearGradient(
        colors: [
          accent.withValues(alpha: 0.6),
          accent,
          const Color(0xFFFFFFFF),
        ],
        stops: const [0.0, 0.75, 1.0],
      ).createShader(fillRect);
      canvas.drawRect(fillRect, _progressFillPaint);

      // Progress glow orb without expensive blur pass
      final orbCenter = Offset(fillW, barY + barH / 2);
      _orbGlowPaint.color = accent.withValues(alpha: 0.35);
      canvas.drawCircle(orbCenter, 7.0, _orbGlowPaint);
      _orbGlowPaint.color = accent.withValues(alpha: 0.85);
      canvas.drawCircle(orbCenter, 4.0, _orbGlowPaint);
      canvas.drawCircle(orbCenter, 2.0, _orbCorePaint);
    }
  }

  void _drawComboBadge(Canvas canvas) {
    const x = 18.0;
    const y = 80.0;
    final pulseAlpha = 0.18 + _comboFlash * 0.42 + 0.08 * sin(_time * 5.0);

    final badgeRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(x, y, 125, 28),
      const Radius.circular(14),
    );

    _comboBgPaint.color =
        _shorebirdGold.withValues(alpha: pulseAlpha.clamp(0.0, 0.7));
    canvas.drawRRect(badgeRect, _comboBgPaint);

    _comboBorderPaint.color = _shorebirdGold.withValues(alpha: 0.85);
    _comboBorderPaint.strokeWidth = 1.2;
    canvas.drawRRect(badgeRect, _comboBorderPaint);

    _tpCombo?.paint(canvas, const Offset(x + 10, y + 5));
  }

  void _drawLevelUpBanner(Canvas canvas) {
    final level = _bannerLevel!;
    final progress = _levelUpBannerTimer / 3.0;
    final alpha = (progress > 0.85
            ? (1.0 - progress) * 6.5
            : (progress * 1.5).clamp(0.0, 1.0))
        .clamp(0.0, 1.0);
    final scale = (0.88 + 0.12 * sin(progress * pi * 1.5)).clamp(0.88, 1.05);

    const bannerW = 500.0;
    const bannerH = 120.0;
    const cx = GameConfig.designWidth / 2;
    const cy = 190.0;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);

    final rect =
        Rect.fromCenter(center: Offset.zero, width: bannerW, height: bannerH);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(20));
    final accent = Color(level.accentColor);

    // Multi-layer crisp ambient glow (no expensive blur pass)
    final glowPaint = Paint()..style = PaintingStyle.stroke;
    glowPaint.color = accent.withValues(alpha: 0.15 * alpha);
    glowPaint.strokeWidth = 10;
    canvas.drawRRect(rrect, glowPaint);
    glowPaint.color = accent.withValues(alpha: 0.35 * alpha);
    glowPaint.strokeWidth = 4;
    canvas.drawRRect(rrect, glowPaint);

    // Background
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xF8111520),
          Color(0xF80C0F18),
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = accent.withValues(alpha: 0.9 * alpha)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, borderPaint);

    // Render text
    if (_tpBannerTitle != null) {
      _tpBannerTitle!.paint(
        canvas,
        Offset(-_tpBannerTitle!.width / 2, -36),
      );
    }
    if (_tpBannerName != null) {
      _tpBannerName!.paint(
        canvas,
        Offset(-_tpBannerName!.width / 2, -8),
      );
    }
    if (_tpBannerQuota != null) {
      _tpBannerQuota!.paint(
        canvas,
        Offset(-_tpBannerQuota!.width / 2, 24),
      );
    }

    canvas.restore();
  }
}
