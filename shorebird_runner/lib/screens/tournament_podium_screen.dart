import 'package:flutter/material.dart';
import 'package:shorebird_runner/game/components/player.dart';
import 'package:shorebird_runner/game/utils/audio_service.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';
import 'package:shorebird_runner/services/lobby_service.dart';

class TournamentPodiumScreen extends StatelessWidget {
  final List<RacerStanding> rankings;
  final VoidCallback onRematch;
  final VoidCallback onReturnToLobby;

  const TournamentPodiumScreen({
    super.key,
    required this.rankings,
    required this.onRematch,
    required this.onReturnToLobby,
  });

  @override
  Widget build(BuildContext context) {
    final first = rankings.isNotEmpty ? rankings[0] : null;
    final second = rankings.length > 1 ? rankings[1] : null;
    final third = rankings.length > 2 ? rankings[2] : null;

    return Scaffold(
      backgroundColor: const Color(GameConfig.colorBg),
      body: Stack(
        children: [
          // Cyberpunk celebration background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.3,
                  colors: [
                    const Color(0xFFFFD700).withValues(alpha: 0.12),
                    const Color(0xFF00D4FF).withValues(alpha: 0.08),
                    const Color(0xFF050A14),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Trophy Banner
                      Column(
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 6),
                          const Text(
                            'BOOTH TOURNAMENT PODIUM',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00FF88)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFF00FF88)
                                      .withValues(alpha: 0.4)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.storage,
                                    color: Color(0xFF00FF88), size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'SAVED TO BOOTH DATABASE',
                                  style: TextStyle(
                                    color: Color(0xFF00FF88),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // 🥇 🥈 🥉 3D Pedestal Section
                      if (first != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 2nd Place Pedestal
                            if (second != null)
                              Expanded(
                                child: _buildPodiumPedestal(
                                  standing: second,
                                  rankText: '2ND',
                                  medal: '🥈',
                                  pedestalHeight: 140,
                                  color: const Color(0xFFC0C0C0),
                                ),
                              )
                            else
                              const Spacer(),

                            const SizedBox(width: 14),

                            // 1st Place Champion Pedestal
                            Expanded(
                              flex: 1,
                              child: _buildPodiumPedestal(
                                standing: first,
                                rankText: '1ST',
                                medal: '🥇',
                                pedestalHeight: 190,
                                color: const Color(0xFFFFD700),
                                isChampion: true,
                              ),
                            ),

                            const SizedBox(width: 14),

                            // 3rd Place Pedestal
                            if (third != null)
                              Expanded(
                                child: _buildPodiumPedestal(
                                  standing: third,
                                  rankText: '3RD',
                                  medal: '🥉',
                                  pedestalHeight: 110,
                                  color: const Color(0xFFCD7F32),
                                ),
                              )
                            else
                              const Spacer(),
                          ],
                        ),

                      const SizedBox(height: 32),

                      // Complete Standings Table
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A192F).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MATCH LEADERBOARD',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...rankings.map((r) => _buildStandingRow(r)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                AudioService.playSelect();
                                onReturnToLobby();
                              },
                              icon: const Icon(Icons.meeting_room,
                                  color: Colors.white70),
                              label: const Text('BACK TO LOBBY',
                                  style: TextStyle(letterSpacing: 1.5)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white24),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                AudioService.playSelect();
                                onRematch();
                              },
                              icon: const Icon(Icons.refresh,
                                  color: Colors.black),
                              label: const Text(
                                'REMATCH RACE',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00FF88),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                elevation: 8,
                                shadowColor: const Color(0xFF00FF88)
                                    .withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPedestal({
    required RacerStanding standing,
    required String rankText,
    required String medal,
    required double pedestalHeight,
    required Color color,
    bool isChampion = false,
  }) {
    final skinEmoji = standing.skin.emoji;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(medal, style: TextStyle(fontSize: isChampion ? 38 : 28)),
        Text(skinEmoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          standing.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isChampion ? color : Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: isChampion ? 15 : 13,
          ),
        ),
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

  Widget _buildStandingRow(RacerStanding standing) {
    Color rankColor = Colors.white70;
    if (standing.rank == 1) rankColor = const Color(0xFFFFD700);
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
