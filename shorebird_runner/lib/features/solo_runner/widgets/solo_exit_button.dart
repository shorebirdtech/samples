import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/audio/audio.dart';
import 'package:shorebird_runner/core/constants/constants.dart';

class SoloExitButton extends StatelessWidget {
  final VoidCallback onBackToMenu;

  const SoloExitButton({
    super.key,
    required this.onBackToMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 10,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AudioService.playSelect();
            onBackToMenu();
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, color: Colors.white70, size: 14),
                SizedBox(width: 4),
                Text(
                  AppStrings.menu,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
