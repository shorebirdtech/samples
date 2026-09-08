import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/core/core.dart';
import 'package:shorebird_runner/features/booth_battle/bloc/booth_battle_bloc.dart';
import 'package:shorebird_runner/features/booth_battle/widgets/widgets.dart';
import 'package:shorebird_runner/game/game.dart';

/// Simultaneous 2-Player Split-Screen Booth Battle:
/// P1 (Left side, Blue Bird) controlled with WASD / Space
/// P2 (Right side, Gold Phoenix) controlled with Arrow Keys
class BoothBattleScreen extends StatefulWidget {
  final VoidCallback onBackToMenu;

  const BoothBattleScreen({super.key, required this.onBackToMenu});

  @override
  State<BoothBattleScreen> createState() => _BoothBattleScreenState();
}

class _BoothBattleScreenState extends State<BoothBattleScreen> {
  late ShorebirdRunnerGame _gameP1;
  late ShorebirdRunnerGame _gameP2;

  @override
  void initState() {
    super.initState();
    _startMatch();
  }

  void _startMatch() {
    context.read<BoothBattleBloc>().add(const RestartBoothBattle());

    _gameP1 = ShorebirdRunnerGame(
      controlScheme: ControlScheme.wasd,
      skin: PlayerSkin.blueBird,
      playerTag: 'P1 BLUE',
      onScoreUpdate: (score, patches, level, isAlive) {
        context.read<BoothBattleBloc>().add(
              UpdateP1Score(
                score: score,
                patches: patches,
                level: level,
                isAlive: isAlive,
              ),
            );
      },
      onGameOver: (score, patches, level) {
        context.read<BoothBattleBloc>().add(
              UpdateP1Score(
                score: score,
                patches: patches,
                level: level,
                isAlive: false,
              ),
            );
      },
    );

    _gameP2 = ShorebirdRunnerGame(
      controlScheme: ControlScheme.arrows,
      skin: PlayerSkin.goldPhoenix,
      playerTag: 'P2 GOLD',
      onScoreUpdate: (score, patches, level, isAlive) {
        context.read<BoothBattleBloc>().add(
              UpdateP2Score(
                score: score,
                patches: patches,
                level: level,
                isAlive: isAlive,
              ),
            );
      },
      onGameOver: (score, patches, level) {
        context.read<BoothBattleBloc>().add(
              UpdateP2Score(
                score: score,
                patches: patches,
                level: level,
                isAlive: false,
              ),
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoothBattleBloc, BoothBattleState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: Stack(
            children: [
              // Dual Runners side by side taking 100% full height and width
              Positioned.fill(
                child: Row(
                  children: [
                    // Player 1 Track (Left)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: AppColors.cyan.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: GameWidget(
                          game: _gameP1,
                          backgroundBuilder: (context) => Container(
                            color: AppColors.backgroundDark,
                          ),
                        ),
                      ),
                    ),

                    // Player 2 Track (Right)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppColors.shorebirdGold
                                  .withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: GameWidget(
                          game: _gameP2,
                          backgroundBuilder: (context) => Container(
                            color: AppColors.backgroundDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Central VS Scoreboard Bar (Floating at Top)
              Align(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  child: VsScoreboard(
                    p1Score: state.p1Score,
                    p2Score: state.p2Score,
                    p1Crashed: state.p1Crashed,
                    p2Crashed: state.p2Crashed,
                  ),
                ),
              ),

              // Bottom Controls Hint Bar
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: MultiplayerControlsBar(onExit: widget.onBackToMenu),
                ),
              ),

              // Match Result Overlay when both finished
              if (state.isMatchOver)
                MatchResultOverlay(
                  p1Score: state.p1Score,
                  p2Score: state.p2Score,
                  p1Patches: state.p1Patches,
                  p2Patches: state.p2Patches,
                  p1Level: state.p1Level,
                  p2Level: state.p2Level,
                  onRematch: _startMatch,
                  onMenu: widget.onBackToMenu,
                ),
            ],
          ),
        );
      },
    );
  }
}
