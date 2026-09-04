import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

/// Heads-Up Display overlay with stage progression, missed patch warning,
/// and support for Player 1 / Player 2 identification in Booth Battle mode.
class Hud extends Component {
  int score = 0;
  int highScore = 0;
  int totalPatches = 0;
  int combo = 0;
  double elapsed = 0;
  String? playerTag;

  double _levelUpBannerTimer = 0;
  LevelConfig? _bannerLevel;

  double _comboFlash = 0;
  double _missFlash = 0;

  Hud({this.playerTag});

  void triggerComboFlash() {
    _comboFlash = 1.0;
  }

  void triggerMissFlash() {
    _missFlash = 1.0;
  }

  void triggerLevelUp(LevelConfig newLevel) {
    _bannerLevel = newLevel;
    _levelUpBannerTimer = 2.8;
  }

  @override
  void update(double dt) {
    if (_comboFlash > 0) {
      _comboFlash = (_comboFlash - dt * 3.5).clamp(0, 1);
    }
    if (_missFlash > 0) {
      _missFlash = (_missFlash - dt * 3.0).clamp(0, 1);
    }
    if (_levelUpBannerTimer > 0) {
      _levelUpBannerTimer = (_levelUpBannerTimer - dt).clamp(0, 10);
    }
  }

  @override
  void render(Canvas canvas) {
    _drawTopPanel(canvas);
    _drawStageProgressBar(canvas);
    if (combo > 1) _drawComboBadge(canvas);
    if (_levelUpBannerTimer > 0 && _bannerLevel != null) {
      _drawLevelUpBanner(canvas);
    }
  }

  void _drawTopPanel(Canvas canvas) {
    final curLevel = GameConfig.levelFor(totalPatches);
    final accentColor =
        _missFlash > 0 ? const Color(0xFFFF2A4B) : Color(curLevel.accentColor);

    final panelPaint = Paint()
      ..color = const Color(0xFF070D18).withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        const Rect.fromLTWH(0, 0, GameConfig.designWidth, 68), panelPaint);

    // Bottom border
    final borderPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          accentColor.withValues(alpha: 0.2),
          accentColor.withValues(alpha: 0.9),
          accentColor.withValues(alpha: 0.2),
        ],
      ).createShader(const Rect.fromLTWH(0, 67, GameConfig.designWidth, 1.5));
    canvas.drawRect(
        const Rect.fromLTWH(0, 67, GameConfig.designWidth, 1.5), borderPaint);

    // Red miss flash overlay on top panel
    if (_missFlash > 0) {
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, GameConfig.designWidth, 68),
        Paint()
          ..color = const Color(0xFFFF2A4B).withValues(alpha: _missFlash * 0.3),
      );
    }

    // 1. Plan / Player Tag
    final planHeader = playerTag != null
        ? '$playerTag · ${curLevel.planQuota}'
        : 'PLAN · ${curLevel.planQuota}';

    _drawText(
      canvas,
      planHeader,
      const Offset(22, 12),
      TextStyle(
        color:
            _missFlash > 0 ? const Color(0xFFFF8888) : const Color(0xFF94A3B8),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );

    _drawText(
      canvas,
      '${curLevel.emoji} ${curLevel.name}',
      const Offset(22, 28),
      TextStyle(
        color: accentColor,
        fontSize: 16,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );

    // 2. Score
    final mins = (elapsed ~/ 60).toString().padLeft(2, '0');
    final secs = (elapsed.toInt() % 60).toString().padLeft(2, '0');
    _drawText(
      canvas,
      'SCORE  ·  TIME $mins:$secs',
      const Offset(GameConfig.designWidth / 2 - 65, 12),
      const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );

    _drawText(
      canvas,
      score.toString().padLeft(6, '0'),
      const Offset(GameConfig.designWidth / 2 - 50, 26),
      TextStyle(
        color:
            _missFlash > 0 ? const Color(0xFFFF416C) : const Color(0xFFFFFFFF),
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.5,
      ),
    );

    // 3. Patches / Next Level
    final nextLvl = GameConfig.nextLevel(totalPatches);
    final nextText = nextLvl != null
        ? '${totalPatches - curLevel.patchThreshold} / ${curLevel.patchesNeeded} 🐤'
        : 'ENTERPRISE 👑';

    _drawText(
      canvas,
      nextLvl != null ? 'NEXT: ${nextLvl.name}' : 'ENTERPRISE TIER',
      const Offset(GameConfig.designWidth - 180, 12),
      const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );

    _drawText(
      canvas,
      nextText,
      const Offset(GameConfig.designWidth - 180, 28),
      const TextStyle(
        color: Color(GameConfig.colorAmber),
        fontSize: 16,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
    );
  }

  void _drawStageProgressBar(Canvas canvas) {
    final curLevel = GameConfig.levelFor(totalPatches);
    final accentColor = Color(curLevel.accentColor);
    final fraction = GameConfig.levelProgressFraction(totalPatches);

    const barY = 68.0;
    const barH = 4.0;

    canvas.drawRect(
      const Rect.fromLTWH(0, barY, GameConfig.designWidth, barH),
      Paint()..color = const Color(0xFF0F172A),
    );

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          accentColor.withValues(alpha: 0.7),
          accentColor,
          const Color(0xFFFFFFFF)
        ],
      ).createShader(
          const Rect.fromLTWH(0, barY, GameConfig.designWidth, barH));

    canvas.drawRect(
      Rect.fromLTWH(0, barY, GameConfig.designWidth * fraction, barH),
      fillPaint,
    );

    if (fraction > 0.02) {
      final glowPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(
        Offset(GameConfig.designWidth * fraction, barY + barH / 2),
        4.0,
        glowPaint,
      );
    }
  }

  void _drawComboBadge(Canvas canvas) {
    const x = 24.0;
    const y = 84.0;

    final badgeRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(x, y, 110, 26),
      const Radius.circular(13),
    );

    final bgPaint = Paint()
      ..color =
          const Color(0xFFFFB347).withValues(alpha: 0.2 + _comboFlash * 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(badgeRect, bgPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFFFB347).withValues(alpha: 0.7)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(badgeRect, borderPaint);

    _drawText(
      canvas,
      'STREAK ×$combo 🔥',
      const Offset(x + 12, y + 5),
      const TextStyle(
        color: Color(0xFFFFD166),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
    );
  }

  void _drawLevelUpBanner(Canvas canvas) {
    final level = _bannerLevel!;
    final progress = _levelUpBannerTimer / 2.8;
    final alpha = (progress > 0.8 ? (1.0 - progress) * 5 : (progress * 1.5))
        .clamp(0.0, 1.0);
    final scale = (0.9 + 0.1 * sin(progress * pi)).clamp(0.9, 1.05);

    const bannerW = 480.0;
    const bannerH = 110.0;
    const cx = GameConfig.designWidth / 2;
    const cy = 180.0;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);

    final rect =
        Rect.fromCenter(center: Offset.zero, width: bannerW, height: bannerH);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(20));

    final glowPaint = Paint()
      ..color = Color(level.accentColor).withValues(alpha: 0.35 * alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawRRect(rrect, glowPaint);

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0F172A).withValues(alpha: 0.95 * alpha),
          const Color(0xFF1E293B).withValues(alpha: 0.95 * alpha),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, bodyPaint);

    final borderPaint = Paint()
      ..color = Color(level.accentColor).withValues(alpha: 0.8 * alpha)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, borderPaint);

    _drawCenteredText(
      canvas,
      '🚀 PLAN UPGRADED · LEVEL UP!',
      const Offset(0, -32),
      TextStyle(
        color: const Color(0xFFFFD166).withValues(alpha: alpha),
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.5,
      ),
    );

    _drawCenteredText(
      canvas,
      '${level.emoji} ${level.name} PLAN',
      const Offset(0, -6),
      TextStyle(
        color: Color(level.accentColor).withValues(alpha: alpha),
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );

    _drawCenteredText(
      canvas,
      '${level.planQuota}  ·  SPEED BOOST!',
      const Offset(0, 22),
      TextStyle(
        color: const Color(0xFF94A3B8).withValues(alpha: alpha),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );

    canvas.restore();
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  void _drawCenteredText(
      Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy));
  }
}
