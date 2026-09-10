import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/core.dart';
import 'package:shorebird_runner/features/solo_runner/widgets/stat_tile.dart';
import 'package:shorebird_runner/game/game.dart';

class GameOverOverlay extends StatelessWidget {
  final int score;
  final int highScore;
  final int totalPatches;
  final LevelConfig level;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.highScore,
    required this.totalPatches,
    required this.level,
    required this.onRestart,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final isNewRecord = score >= highScore && score > 0;
    final accentColor = Color(level.accentColor);

    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            decoration: BoxDecoration(
              color: AppColors.panelNavy,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isNewRecord ? AppColors.shorebirdGold : accentColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isNewRecord ? AppColors.shorebirdGold : accentColor)
                      .withValues(alpha: 0.28),
                  blurRadius: 36,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isNewRecord) ...[
                  const Text(
                    AppStrings.newRecord,
                    style: TextStyle(
                      color: AppColors.shorebirdGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  AppStrings.gameOver,
                  style: TextStyle(
                    color: isNewRecord
                        ? AppColors.shorebirdGold
                        : AppColors.errorRed,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 18),
                StatTile(
                  label: AppStrings.score,
                  value: score.toString(),
                  color: AppColors.textPrimary,
                  large: true,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: AppStrings.highScore,
                        value: highScore.toString(),
                        color: AppColors.shorebirdGold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        label: AppStrings.patches,
                        value: totalPatches.toString(),
                        color: AppColors.proCyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                StatTile(
                  label: AppStrings.tierReached,
                  value: '${level.name} · ${level.planQuota}',
                  color: accentColor,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    AudioService.playSelect();
                    onRestart();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.shorebirdGold,
                    foregroundColor: AppColors.buttonDarkText,
                    minimumSize: const Size.fromHeight(50),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    AppStrings.restart,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    AudioService.playSelect();
                    onMenu();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: Colors.white24),
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    AppStrings.backToMenu,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
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
