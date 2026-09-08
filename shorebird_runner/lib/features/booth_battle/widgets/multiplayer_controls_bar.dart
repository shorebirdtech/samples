import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/audio/audio.dart';
import 'package:shorebird_runner/core/constants/constants.dart';

class MultiplayerControlsBar extends StatelessWidget {
  final VoidCallback onExit;

  const MultiplayerControlsBar({super.key, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkNavy.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderNavy),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🎮 P1: A/D (Lanes), W (Jump), S (Slide)',
            style: TextStyle(
              color: AppColors.cyan,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 20),
          const Text('•', style: TextStyle(color: Colors.white24)),
          const SizedBox(width: 20),
          const Text(
            '🕹️ P2: Left/Right (Lanes), Up (Jump), Down (Slide)',
            style: TextStyle(
              color: AppColors.shorebirdGold,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 24),
          InkWell(
            onTap: () {
              AudioService.playSelect();
              onExit();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'ESC: Menu',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
