import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/core/core.dart';
import 'package:shorebird_runner/features/multiplayer_race/bloc/race_bloc.dart';
import 'package:shorebird_runner/features/multiplayer_race/widgets/widgets.dart';
import 'package:shorebird_runner/features/solo_runner/widgets/widgets.dart';
import 'package:shorebird_runner/features/tournament_lobby/tournament_lobby.dart';
import 'package:shorebird_runner/game/game.dart';

class MultiplayerRaceScreen extends StatefulWidget {
  final VoidCallback onLeaveRace;
  final void Function(List<RacerStanding> rankings) onRaceFinished;

  const MultiplayerRaceScreen({
    super.key,
    required this.onLeaveRace,
    required this.onRaceFinished,
  });

  @override
  State<MultiplayerRaceScreen> createState() => _MultiplayerRaceScreenState();
}

class _MultiplayerRaceScreenState extends State<MultiplayerRaceScreen> {
  ShorebirdRunnerGame? _game;

  @override
  void initState() {
    super.initState();
    final repo = context.read<ILobbyRepository>();
    if (!repo.isSpectator) {
      final me = repo.players.firstWhere(
        (p) => p.id == repo.myPlayerId,
        orElse: () => LobbyPlayer(
          id: repo.myPlayerId ?? 'me',
          name: 'Player',
          skin: PlayerSkin.blueBird,
        ),
      );

      _game = ShorebirdRunnerGame(
        controlScheme: ControlScheme.both,
        skin: me.skin,
        playerTag: me.name,
        onScoreUpdate: (score, patches, level, isAlive) {
          context.read<RaceBloc>().add(
                UpdateRacerScore(
                  score: score,
                  patches: patches,
                  level: level.level,
                  isAlive: isAlive,
                ),
              );
        },
        onGameOver: (score, patches, level) {
          context.read<RaceBloc>().add(
                PlayerCrashedEvent(
                  finalScore: score,
                  finalPatches: patches,
                ),
              );
          context.read<RaceBloc>().add(
                UpdateRacerScore(
                  score: score,
                  patches: patches,
                  level: level.level,
                  isAlive: false,
                ),
              );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ILobbyRepository>();

    return BlocConsumer<RaceBloc, RaceState>(
      listener: (context, state) {
        if (state.finalRankings != null) {
          widget.onRaceFinished(state.finalRankings!);
        }
      },
      builder: (context, state) {
        final standings = state.standings.isNotEmpty
            ? state.standings
            : repo.players.map((p) {
                return RacerStanding(
                  rank: 1,
                  id: p.id,
                  name: p.name,
                  skin: p.skin,
                  score: p.score,
                  patches: p.patches,
                  level: p.level,
                  isAlive: p.isAlive,
                );
              }).toList();

        if (repo.isSpectator) {
          return _buildSpectatorScreen(repo, standings);
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile =
                  constraints.maxWidth < 800 || constraints.maxHeight < 600;
              final isPortrait = constraints.maxHeight > constraints.maxWidth;

              Widget gameCanvas = LayoutBuilder(
                builder: (context, box) {
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: (details) {
                      if (_game == null || _game!.isOver) return;
                      final width = box.maxWidth;
                      final x = details.localPosition.dx;
                      if (x < width * 0.36) {
                        _game!.moveToLane(0);
                      } else if (x > width * 0.64) {
                        _game!.moveToLane(2);
                      } else {
                        _game!.moveToLane(1);
                      }
                    },
                    child: _game != null
                        ? GameWidget(
                            game: _game!,
                            backgroundBuilder: (context) => Container(
                              color: AppColors.raceBgDark,
                            ),
                          )
                        : const SizedBox(),
                  );
                },
              );

              final showTouchBar = isMobile && isPortrait && !state.hasCrashed;
              final renderedCanvas = Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: showTouchBar ? 68 : 0,
                child: gameCanvas,
              );

              return Stack(
                children: [
                  renderedCanvas,

                  // Top Header Overlay: Room Code & Status
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Room Badge & Leave Button
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.panelNavy
                                      .withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        AppColors.cyan.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Text(
                                      '🌐 ROOM: ',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      repo.currentRoomCode ?? '----',
                                      style: const TextStyle(
                                        color: AppColors.cyan,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  AudioService.playSelect();
                                  widget.onLeaveRace();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: const Text(
                                    AppStrings.quit,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Real-time Standings Mini Board
                          LiveStandingsCard(
                            standings: standings,
                            myPlayerId: repo.myPlayerId,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Mobile Controls
                  if (isMobile && isPortrait && !state.hasCrashed)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: MobileTouchBar(
                        onLeft: () => _game?.moveToLane(0),
                        onMid: () => _game?.moveToLane(1),
                        onRight: () => _game?.moveToLane(2),
                        onJump: () => _game?.jump(),
                        onSlide: () => _game?.slide(),
                      ),
                    ),

                  // Spectating / Crashed Overlay
                  if (state.hasCrashed)
                    CrashedSpectatorOverlay(
                      finalScore: state.finalScore,
                      finalPatches: state.finalPatches,
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSpectatorScreen(
    ILobbyRepository repo,
    List<RacerStanding> standings,
  ) {
    final activeCount = standings.where((s) => s.isAlive).length;

    return Scaffold(
      backgroundColor: AppColors.raceBgDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Big Screen Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.cyan.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Icon(
                          Icons.tv,
                          color: AppColors.cyan,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BOOTH TOURNAMENT DISPLAY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                          Text(
                            'LIVE MULTIPLAYER CI/CD RACE STREAM',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.panelNavy,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.neonGreen.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonGreen.withValues(alpha: 0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'ROOM: ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              repo.currentRoomCode ?? '----',
                              style: const TextStyle(
                                color: AppColors.neonGreen,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.panelNavy,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.cyan.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          '$activeCount / ${standings.length} DEVELOPERS RUNNING',
                          style: const TextStyle(
                            color: AppColors.cyan,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {
                          AudioService.playSelect();
                          widget.onLeaveRace();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('END RACE'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Live Standings Grid
              Expanded(
                child: standings.isEmpty
                    ? const Center(
                        child: Text(
                          'No active participants in this race',
                          style: TextStyle(color: Colors.white60, fontSize: 16),
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 420,
                          mainAxisExtent: 140,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: standings.length,
                        itemBuilder: (context, index) {
                          final s = standings[index];
                          final isTop3 = s.rank <= 3;

                          Color borderGlow = Colors.white12;
                          Color rankColor = Colors.white70;
                          String medal = '#${s.rank}';
                          if (s.rank == 1) {
                            borderGlow = AppColors.shorebirdGold;
                            rankColor = AppColors.shorebirdGold;
                            medal = '🥇 1ST';
                          } else if (s.rank == 2) {
                            borderGlow = AppColors.silverMedal;
                            rankColor = AppColors.silverMedal;
                            medal = '🥈 2ND';
                          } else if (s.rank == 3) {
                            borderGlow = AppColors.bronzeMedal;
                            rankColor = AppColors.bronzeMedal;
                            medal = '🥉 3RD';
                          }

                          String skinEmoji = s.skin.emoji;

                          String planName = 'HOBBY (5K)';
                          if (s.level == 2) planName = 'PRO (50K)';
                          if (s.level == 3) planName = 'BUSINESS (1M)';
                          if (s.level >= 4) planName = 'ENTERPRISE';

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.panelNavy.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: s.isAlive
                                    ? borderGlow
                                    : AppColors.crashRed.withValues(alpha: 0.5),
                                width: isTop3 && s.isAlive ? 2.0 : 1.0,
                              ),
                              boxShadow: [
                                if (isTop3 && s.isAlive)
                                  BoxShadow(
                                    color: borderGlow.withValues(alpha: 0.2),
                                    blurRadius: 12,
                                  ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      skinEmoji,
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      medal,
                                      style: TextStyle(
                                        color: rankColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              s.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: s.isAlive
                                                  ? AppColors.neonGreen
                                                      .withValues(alpha: 0.15)
                                                  : AppColors.crashRed
                                                      .withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              s.isAlive
                                                  ? '🟢 RUNNING'
                                                  : '💥 CRASHED',
                                              style: TextStyle(
                                                color: s.isAlive
                                                    ? AppColors.neonGreen
                                                    : AppColors.crashRed,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Plan: $planName',
                                        style: const TextStyle(
                                          color: AppColors.cyan,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${s.score} PTS',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          Text(
                                            '🐤 ${s.patches}',
                                            style: const TextStyle(
                                              color: AppColors.shorebirdGold,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 16),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.panelNavy.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 14, color: AppColors.cyan),
                    SizedBox(width: 8),
                    Text(
                      'Live updates as pilots dodge obstacles & collect patches • Podium appears upon match completion',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
