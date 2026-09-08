import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/constants/constants.dart';

class CrashedSpectatorOverlay extends StatelessWidget {
  final int finalScore;
  final int finalPatches;

  const CrashedSpectatorOverlay({
    super.key,
    required this.finalScore,
    required this.finalPatches,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 22,
            ),
            decoration: BoxDecoration(
              color: AppColors.panelNavy,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.crashRed,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.crashRed.withValues(alpha: 0.3),
                  blurRadius: 25,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '💥 RUN CRASHED',
                  style: TextStyle(
                    color: AppColors.crashRed,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Final Score: $finalScore • Patches: $finalPatches',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.cyan,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Awaiting race completion...',
                      style: TextStyle(
                        color: AppColors.cyan,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
