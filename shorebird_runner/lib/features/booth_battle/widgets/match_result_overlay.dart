import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/core.dart';
import 'package:shorebird_runner/features/booth_battle/widgets/score_card.dart';
import 'package:shorebird_runner/game/game.dart';

class MatchResultOverlay extends StatelessWidget {
  final int p1Score;
  final int p2Score;
  final int p1Patches;
  final int p2Patches;
  final LevelConfig p1Level;
  final LevelConfig p2Level;
  final VoidCallback onRematch;
  final VoidCallback onMenu;

  const MatchResultOverlay({
    super.key,
    required this.p1Score,
    required this.p2Score,
    required this.p1Patches,
    required this.p2Patches,
    required this.p1Level,
    required this.p2Level,
    required this.onRematch,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final p1Wins = p1Score > p2Score;
    final isTie = p1Score == p2Score;

    final winnerTitle = isTie
        ? 'HONORABLE DRAW!'
        : (p1Wins ? '🏆 PLAYER 1 VICTORIOUS!' : '🏆 PLAYER 2 VICTORIOUS!');

    final winnerColor = isTie
        ? AppColors.goldLight
        : (p1Wins ? AppColors.cyan : AppColors.shorebirdGold);

    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 540),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.darkNavy,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: winnerColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: winnerColor.withValues(alpha: 0.3),
                blurRadius: 32,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                winnerTitle,
                style: TextStyle(
                  color: winnerColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ScoreCard(
                      label: 'P1 BLUE',
                      score: p1Score,
                      patches: p1Patches,
                      color: AppColors.cyan,
                      isWinner: p1Wins && !isTie,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ScoreCard(
                      label: 'P2 GOLD',
                      score: p2Score,
                      patches: p2Patches,
                      color: AppColors.shorebirdGold,
                      isWinner: !p1Wins && !isTie,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      AudioService.playSelect();
                      onMenu();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('MAIN MENU'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      AudioService.playSelect();
                      onRematch();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: winnerColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'PLAY AGAIN',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
