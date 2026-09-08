import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/core.dart';
import 'package:shorebird_runner/features/tournament_lobby/models/models.dart';
import 'package:shorebird_runner/features/tournament_podium/widgets/widgets.dart';

class TournamentPodiumScreen extends StatelessWidget {
  final List<RacerStanding> rankings;
  final VoidCallback onRematch;
  final VoidCallback onReturnToLobby;
  final bool isHost;

  const TournamentPodiumScreen({
    super.key,
    required this.rankings,
    required this.onRematch,
    required this.onReturnToLobby,
    this.isHost = false,
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
                    AppColors.shorebirdGold.withValues(alpha: 0.12),
                    AppColors.cyan.withValues(alpha: 0.08),
                    AppColors.roadDark,
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
                            'TOURNAMENT FINISH',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 4.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'OFFICIAL SHOREBIRD CI/CD LEADERBOARD',
                            style: TextStyle(
                              color: AppColors.cyan.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 3D Pedestals (1st, 2nd, 3rd)
                      if (first != null)
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                          decoration: BoxDecoration(
                            color:
                                AppColors.podiumCardNavy.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.shorebirdGold
                                  .withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shorebirdGold
                                    .withValues(alpha: 0.15),
                                blurRadius: 25,
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // 2nd Place (Left)
                              Expanded(
                                child: second != null
                                    ? PodiumPedestal(
                                        standing: second,
                                        rankText: '2ND',
                                        color: AppColors.silverMedal,
                                        pedestalHeight: 110,
                                        isChampion: false,
                                      )
                                    : const SizedBox(),
                              ),
                              const SizedBox(width: 12),

                              // 1st Place (Center, tallest)
                              Expanded(
                                child: PodiumPedestal(
                                  standing: first,
                                  rankText: '1ST',
                                  color: AppColors.shorebirdGold,
                                  pedestalHeight: 160,
                                  isChampion: true,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // 3rd Place (Right)
                              Expanded(
                                child: third != null
                                    ? PodiumPedestal(
                                        standing: third,
                                        rankText: '3RD',
                                        color: AppColors.bronzeMedal,
                                        pedestalHeight: 80,
                                        isChampion: false,
                                      )
                                    : const SizedBox(),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Full Leaderboard List
                      if (rankings.length > 3) ...[
                        const Text(
                          'OTHER CONTENDERS',
                          style: TextStyle(
                            color: AppColors.cyan,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...rankings
                            .skip(3)
                            .map((r) => StandingRow(standing: r)),
                        const SizedBox(height: 20),
                      ],

                      // Bottom Action Buttons
                      if (isHost)
                        _HostActionButtons(
                          onReturnToLobby: onReturnToLobby,
                          onRematch: onRematch,
                        )
                      else
                        _GuestActionButtons(onReturnToLobby: onReturnToLobby),
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
}

class _HostActionButtons extends StatelessWidget {
  final VoidCallback onReturnToLobby;
  final VoidCallback onRematch;

  const _HostActionButtons({
    required this.onReturnToLobby,
    required this.onRematch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              AudioService.playSelect();
              onReturnToLobby();
            },
            icon: const Icon(Icons.meeting_room, color: Colors.white70),
            label:
                const Text('LEAVE ROOM', style: TextStyle(letterSpacing: 1.5)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
            icon: const Icon(Icons.refresh, color: Colors.black),
            label: const Text(
              'REMATCH RACE',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 8,
              shadowColor: AppColors.neonGreen.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GuestActionButtons extends StatelessWidget {
  final VoidCallback onReturnToLobby;

  const _GuestActionButtons({required this.onReturnToLobby});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.panelNavy.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.cyan.withValues(alpha: 0.4),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.cyan,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'WAITING FOR ROOM OWNER TO REMATCH...',
                style: TextStyle(
                  color: AppColors.cyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () {
            AudioService.playSelect();
            onReturnToLobby();
          },
          icon: const Icon(Icons.exit_to_app, color: AppColors.crashRed),
          label: const Text(
            'LEAVE ROOM',
            style: TextStyle(
              letterSpacing: 1.5,
              color: AppColors.crashRed,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.crashRed),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
