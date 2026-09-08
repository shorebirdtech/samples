import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/constants/constants.dart';

class VsScoreboard extends StatelessWidget {
  final int p1Score;
  final int p2Score;
  final bool p1Crashed;
  final bool p2Crashed;

  const VsScoreboard({
    super.key,
    required this.p1Score,
    required this.p2Score,
    required this.p1Crashed,
    required this.p2Crashed,
  });

  @override
  Widget build(BuildContext context) {
    final diff = p1Score - p2Score;
    final leadText = diff > 0
        ? 'P1 +$diff LEAD 🔥'
        : (diff < 0 ? 'P2 +${-diff} LEAD ⚡' : 'TIED! ⚔️');

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkNavy.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // P1 tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.cyan.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'P1',
                  style: TextStyle(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                if (p1Crashed)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text('💥', style: TextStyle(fontSize: 10)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            p1Score.toString().padLeft(5, '0'),
            style: const TextStyle(
              color: AppColors.cyan,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.darkSlate,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              leadText,
              style: const TextStyle(
                color: AppColors.goldLight,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 14),

          Text(
            p2Score.toString().padLeft(5, '0'),
            style: const TextStyle(
              color: AppColors.shorebirdGold,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          // P2 tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.shorebirdGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.shorebirdGold.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'P2',
                  style: TextStyle(
                    color: AppColors.shorebirdGold,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                if (p2Crashed)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text('💥', style: TextStyle(fontSize: 10)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
