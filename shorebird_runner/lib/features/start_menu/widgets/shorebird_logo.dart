import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/constants/constants.dart';

class ShorebirdLogo extends StatelessWidget {
  const ShorebirdLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 148,
          height: 148,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.shorebirdGold.withValues(alpha: 0.30),
                blurRadius: 60,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
        // Logo container
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [AppColors.cardDarkAlt, AppColors.backgroundDark],
              center: Alignment.topLeft,
              radius: 1.5,
            ),
            border: Border.all(
              color: AppColors.shorebirdGold.withValues(alpha: 0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shorebirdGold.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Developer avatar
              const Text('👨‍💻', style: TextStyle(fontSize: 52)),
              // Shorebird badge
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDark,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.shorebirdGold,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shorebirdGold.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Text('🐤', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
