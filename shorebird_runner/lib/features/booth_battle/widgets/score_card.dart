import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  final String label;
  final int score;
  final int patches;
  final Color color;
  final bool isWinner;

  const ScoreCard({
    super.key,
    required this.label,
    required this.score,
    required this.patches,
    required this.color,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? color : color.withValues(alpha: 0.4),
          width: isWinner ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              if (isWinner) ...[
                const SizedBox(width: 6),
                const Text('👑', style: TextStyle(fontSize: 14)),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            score.toString(),
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '🐤 $patches Patches',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
