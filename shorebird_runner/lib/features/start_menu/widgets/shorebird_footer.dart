import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/constants/constants.dart';

class ShorebirdFooter extends StatelessWidget {
  const ShorebirdFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🐤', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        const Text(
          'shorebird.dev',
          style: TextStyle(
            color: AppColors.slateDark,
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: AppColors.shorebirdGold,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Code Push · OTA Updates',
          style: TextStyle(
            color: AppColors.slateDark,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
