import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/constants/constants.dart';
import 'package:shorebird_runner/features/start_menu/widgets/particle_data.dart';
import 'package:shorebird_runner/features/start_menu/widgets/star_data.dart';

class StartBackgroundPainter extends CustomPainter {
  final double progress;
  static final _rng = Random(42);
  static final _stars = List.generate(180, (_) => StarData(_rng));
  static final _particles = List.generate(25, (i) => ParticleData(_rng, i));

  StartBackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.3),
        radius: 1.2,
        colors: [
          AppColors.bgGradientTop,
          AppColors.backgroundDark,
          AppColors.bgGradientBottom,
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final auroraPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -1.0),
        radius: 0.8,
        colors: [
          AppColors.shorebirdGold.withValues(alpha: 0.06),
          AppColors.shorebirdGold.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), auroraPaint);

    for (final star in _stars) {
      final y = (star.y + progress * star.speed * 0.008) % 1.0;
      final twinkleVal =
          (0.4 + 0.6 * sin(progress * star.twinkleSpeed * pi * 2 + star.phase))
              .clamp(0.0, 1.0);
      final alpha = star.brightness * twinkleVal;
      canvas.drawCircle(
        Offset(star.x * size.width, y * size.height),
        star.size,
        Paint()
          ..color = Color.fromARGB(
            (alpha * 255).round(),
            star.isGolden ? 255 : 180,
            star.isGolden ? 220 : 210,
            star.isGolden ? 100 : 255,
          ),
      );
    }

    for (final p in _particles) {
      final y = (p.startY - progress * p.speed) % 1.0;
      final x = p.startX + sin(progress * p.wobble * pi * 2) * 0.03;
      final lifeAlpha = sin(y * pi).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.size,
        Paint()
          ..color = AppColors.shorebirdGold.withValues(alpha: lifeAlpha * 0.35),
      );
    }

    final gridPaint = Paint()
      ..color = AppColors.shorebirdGold.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    final cx = size.width / 2;
    final cy = size.height * 0.72;
    for (int i = 0; i <= 8; i++) {
      final x = size.width * i / 8;
      canvas.drawLine(Offset(x, size.height), Offset(cx, cy), gridPaint);
    }
    for (int i = 0; i <= 5; i++) {
      final y = cy + (size.height - cy) * i / 5;
      final spread = ((size.height - y) / (size.height - cy)).clamp(0.0, 1.0) *
          size.width *
          0.5;
      canvas.drawLine(
        Offset(cx - spread, y),
        Offset(cx + spread, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(StartBackgroundPainter oldDelegate) => true;
}
