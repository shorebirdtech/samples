import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/constants/constants.dart';

class ShorebirdLogo extends StatelessWidget {
  const ShorebirdLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ambient golden bloom halo
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.shorebirdGold.withValues(alpha: 0.35),
                blurRadius: 48,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                blurRadius: 32,
              ),
            ],
          ),
        ),

        // Main crafted emblem container
        Container(
          width: 114,
          height: 114,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [
                Color(0xFF1E293B),
                Color(0xFF0F172A),
                Color(0xFF030712),
              ],
              center: Alignment(-0.2, -0.3),
              radius: 1.2,
            ),
            border: Border.all(
              color: AppColors.shorebirdGold,
              width: 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shorebirdGold.withValues(alpha: 0.3),
                blurRadius: 20,
              ),
              const BoxShadow(
                color: Color(0xFF000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: CustomPaint(
            size: const Size(114, 114),
            painter: _ShorebirdEmblemPainter(),
          ),
        ),
      ],
    );
  }
}

class _ShorebirdEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Subtle inner circular grid track
    final trackPaint = Paint()
      ..color = AppColors.shorebirdGold.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(cx, cy), 42, trackPaint);
    canvas.drawCircle(Offset(cx, cy), 32, trackPaint);

    // Orbiting tick marks
    final tickPaint = Paint()
      ..color = AppColors.shorebirdGold.withValues(alpha: 0.3)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 12; i++) {
      final angle = i * (pi / 6);
      final p1 = Offset(cx + cos(angle) * 44, cy + sin(angle) * 44);
      final p2 = Offset(cx + cos(angle) * 48, cy + sin(angle) * 48);
      canvas.drawLine(p1, p2, tickPaint);
    }

    // Handcrafted Shorebird Wing Glyph
    final wingPath = Path();
    // Primary aerodynamic wing sweep
    wingPath.moveTo(cx - 24, cy + 6);
    wingPath.cubicTo(cx - 20, cy - 14, cx - 2, cy - 26, cx + 22, cy - 24);
    wingPath.cubicTo(cx + 10, cy - 14, cx + 2, cy - 4, cx - 4, cy + 2);
    wingPath.cubicTo(cx + 8, cy - 2, cx + 18, cy + 2, cx + 26, cy + 12);
    wingPath.cubicTo(cx + 12, cy + 14, cx - 6, cy + 20, cx - 24, cy + 6);
    wingPath.close();

    // Golden metallic gradient for main wing
    final wingPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFE082),
          AppColors.shorebirdGold,
          Color(0xFFD97706),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 30))
      ..style = PaintingStyle.fill;
    canvas.drawPath(wingPath, wingPaint);

    // Secondary inner wing feather
    final innerWing = Path()
      ..moveTo(cx - 16, cy + 2)
      ..cubicTo(cx - 10, cy - 8, cx + 4, cy - 16, cx + 16, cy - 14)
      ..cubicTo(cx + 6, cy - 8, cx, cy - 2, cx - 4, cy + 4)
      ..close();
    final innerWingPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFFFD54F),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 20))
      ..style = PaintingStyle.fill;
    canvas.drawPath(innerWing, innerWingPaint);

    // Aerodynamic crest / beak
    final beakPath = Path()
      ..moveTo(cx + 18, cy - 24)
      ..lineTo(cx + 28, cy - 18)
      ..lineTo(cx + 19, cy - 14)
      ..close();
    final beakPaint = Paint()
      ..color = const Color(0xFFFF9100)
      ..style = PaintingStyle.fill;
    canvas.drawPath(beakPath, beakPaint);

    // Bird eye / energy core
    final eyeCenter = Offset(cx + 14, cy - 17);
    canvas.drawCircle(eyeCenter, 2.8, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(
      eyeCenter + const Offset(0.6, -0.6),
      1.0,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
