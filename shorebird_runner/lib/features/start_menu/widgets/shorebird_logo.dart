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

        // Main crafted emblem container with iconic 🐤 chick
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
          alignment: Alignment.center,
          child: const Text(
            '🐤',
            style: TextStyle(
              fontSize: 56,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}
