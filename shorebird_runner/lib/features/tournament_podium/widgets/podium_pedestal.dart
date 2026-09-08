import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/core.dart';
import 'package:shorebird_runner/features/tournament_lobby/models/models.dart';
import 'package:shorebird_runner/game/game.dart';

class PodiumPedestal extends StatelessWidget {
  final RacerStanding standing;
  final String rankText;
  final Color color;
  final double pedestalHeight;
  final bool isChampion;

  const PodiumPedestal({
    super.key,
    required this.standing,
    required this.rankText,
    required this.color,
    required this.pedestalHeight,
    required this.isChampion,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = standing.skin.emoji;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isChampion)
          const Text('👑', style: TextStyle(fontSize: 28))
        else
          const SizedBox(height: 28),
        const SizedBox(height: 4),
        Text(emoji, style: TextStyle(fontSize: isChampion ? 44 : 36)),
        const SizedBox(height: 8),
        Text(
          standing.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: isChampion ? 15 : 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${standing.score} PTS',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: isChampion ? 16 : 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: pedestalHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.35),
                color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: color, width: isChampion ? 2 : 1),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isChampion ? 0.3 : 0.15),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              rankText,
              style: TextStyle(
                color: color,
                fontSize: isChampion ? 28 : 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StandingRow extends StatelessWidget {
  final RacerStanding standing;

  const StandingRow({super.key, required this.standing});

  @override
  Widget build(BuildContext context) {
    Color rankColor = Colors.white70;
    if (standing.rank == 1) rankColor = AppColors.shorebirdGold;
    if (standing.rank == 2) rankColor = const Color(0xFFC0C0C0);
    if (standing.rank == 3) rankColor = const Color(0xFFCD7F32);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF050F1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: rankColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${standing.rank}',
              style: TextStyle(
                  color: rankColor, fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  standing.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14),
                ),
                Text(
                  'Stage ${standing.level} • ${standing.patches} patches',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '${standing.score} PTS',
            style: TextStyle(
              color: rankColor,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
