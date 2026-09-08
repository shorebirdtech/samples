import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/constants/constants.dart';
import 'package:shorebird_runner/features/tournament_lobby/models/models.dart';

class LiveStandingsCard extends StatelessWidget {
  final List<RacerStanding> standings;
  final String? myPlayerId;

  const LiveStandingsCard({
    super.key,
    required this.standings,
    required this.myPlayerId,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0A192F).withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.shorebirdGold.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LIVE RACE',
                  style: TextStyle(
                    color: AppColors.shorebirdGold,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                Icon(
                  Icons.bolt,
                  color: AppColors.shorebirdGold,
                  size: 12,
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...standings.take(4).map((s) {
              final isMe = s.id == myPlayerId;
              String medal = '#${s.rank}';
              if (s.rank == 1) medal = '🥇';
              if (s.rank == 2) medal = '🥈';
              if (s.rank == 3) medal = '🥉';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text(
                      medal,
                      style: const TextStyle(fontSize: 10),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        s.name + (isMe ? ' (YOU)' : ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isMe ? AppColors.cyan : Colors.white,
                          fontWeight: isMe ? FontWeight.w900 : FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      s.isAlive ? '${s.score}' : '💥',
                      style: TextStyle(
                        color: s.isAlive
                            ? AppColors.neonGreen
                            : AppColors.crashRed,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
