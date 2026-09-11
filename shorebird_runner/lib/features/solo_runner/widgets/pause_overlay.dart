import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/core.dart';
import 'package:shorebird_runner/features/leaderboard/leaderboard.dart';
import 'package:shorebird_runner/features/solo_runner/widgets/stat_tile.dart';
import 'package:shorebird_runner/game/game.dart';

class PauseOverlay extends StatelessWidget {
  final int score;
  final int totalPatches;
  final LevelConfig level;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  const PauseOverlay({
    super.key,
    required this.score,
    required this.totalPatches,
    required this.level,
    required this.onResume,
    required this.onRestart,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(level.accentColor);

    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.panelNavy,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.shorebirdGold.withValues(alpha: 0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shorebirdGold.withValues(alpha: 0.2),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with audio toggle
                Row(
                  children: [
                    const Spacer(),
                    const Icon(
                      Icons.pause_circle_filled_rounded,
                      color: AppColors.shorebirdGold,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'GAME PAUSED',
                      style: TextStyle(
                        color: AppColors.shorebirdGold,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    ValueListenableBuilder<bool>(
                      valueListenable: AudioService.isMutedNotifier,
                      builder: (context, isMuted, _) {
                        return IconButton(
                          icon: Icon(
                            isMuted
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            color: isMuted
                                ? AppColors.slateMuted
                                : AppColors.shorebirdGold,
                            size: 20,
                          ),
                          tooltip: isMuted ? 'Unmute Audio' : 'Mute Audio',
                          onPressed: () => AudioService.toggleMute(),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Press ESC or P to resume',
                  style: TextStyle(
                    color: AppColors.slateMuted,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),

                // Current run stats
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: AppStrings.score,
                        value: score.toString(),
                        color: AppColors.textPrimary,
                        large: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        label: AppStrings.patches,
                        value: totalPatches.toString(),
                        color: AppColors.proCyan,
                        large: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                StatTile(
                  label: 'CURRENT STAGE',
                  value: '${level.name} (${level.planQuota})',
                  color: accentColor,
                ),
                const SizedBox(height: 16),

                // Controls refresher
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'CONTROLS REFRESHER',
                        style: TextStyle(
                          color: AppColors.slateMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _ControlItem(
                            icon: Icons.swap_horiz_rounded,
                            label: 'A / D / ◀ ▶',
                            action: 'DODGE',
                          ),
                          _ControlItem(
                            icon: Icons.arrow_upward_rounded,
                            label: 'W / ▲ / SPACE',
                            action: 'LEAP',
                          ),
                          _ControlItem(
                            icon: Icons.arrow_downward_rounded,
                            label: 'S / ▼',
                            action: 'SLIDE',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Primary Resume Button
                ElevatedButton(
                  onPressed: () {
                    AudioService.playSelect();
                    onResume();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.shorebirdGold,
                    foregroundColor: AppColors.buttonDarkText,
                    minimumSize: const Size.fromHeight(48),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'RESUME RUN',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Secondary buttons: Restart & Leaderboard
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          AudioService.playSelect();
                          onRestart();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh_rounded, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'RESTART',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          AudioService.playSelect();
                          LeaderboardDialog.show(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.shorebirdGold,
                          side: BorderSide(
                            color:
                                AppColors.shorebirdGold.withValues(alpha: 0.4),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.emoji_events_rounded,
                                size: 16,
                                color: AppColors.shorebirdGold,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'LEADERBOARD',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Back to menu
                OutlinedButton(
                  onPressed: () {
                    AudioService.playSelect();
                    onMenu();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: Colors.white12),
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    AppStrings.backToMenu,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
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

class _ControlItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String action;

  const _ControlItem({
    required this.icon,
    required this.label,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.shorebirdGold, size: 16),
        const SizedBox(height: 2),
        Text(
          action,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.slateMuted,
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
