import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/core/core.dart';
import 'package:shorebird_runner/features/solo_runner/bloc/solo_runner_bloc.dart';
import 'package:shorebird_runner/features/solo_runner/widgets/widgets.dart';
import 'package:shorebird_runner/game/game.dart';

class SoloRunnerScreen extends StatefulWidget {
  final PlayerSkin skin;
  final VoidCallback onBackToMenu;

  const SoloRunnerScreen({
    super.key,
    this.skin = PlayerSkin.blueBird,
    required this.onBackToMenu,
  });

  @override
  State<SoloRunnerScreen> createState() => _SoloRunnerScreenState();
}

class _SoloRunnerScreenState extends State<SoloRunnerScreen> {
  ShorebirdRunnerGame? _game;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    context.read<SoloRunnerBloc>().add(const StartSoloGame());
    _game = ShorebirdRunnerGame(
      controlScheme: ControlScheme.both,
      skin: widget.skin,
      onGameOver: (score, patches, level) {
        if (!mounted) return;
        context.read<SoloRunnerBloc>().add(
              SoloGameOver(score: score, patches: patches, level: level),
            );
      },
    );
  }

  void _restartGame() {
    context.read<SoloRunnerBloc>().add(const RestartSoloGame());
    _initGame();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SoloRunnerBloc, SoloRunnerState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isPortrait = constraints.maxHeight > constraints.maxWidth;

                final gameView = Stack(
                  children: [
                    Positioned.fill(
                      child: LayoutBuilder(
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
                                      color: AppColors.backgroundDark,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          );
                        },
                      ),
                    ),

                    // Back to menu button
                    SoloExitButton(onBackToMenu: widget.onBackToMenu),

                    // Game Over Overlay
                    if (state.status == SoloGameStatus.gameOver)
                      GameOverOverlay(
                        score: state.score,
                        highScore: state.highScore,
                        totalPatches: state.patches,
                        level: state.level,
                        onRestart: _restartGame,
                        onMenu: widget.onBackToMenu,
                      ),
                  ],
                );

                return Column(
                  children: [
                    Expanded(child: gameView),
                    if (isPortrait && state.status != SoloGameStatus.gameOver)
                      MobileTouchBar(
                        onLeft: () => _game?.moveLeft(),
                        onMid: () => _game?.moveToLane(1),
                        onRight: () => _game?.moveRight(),
                        onJump: () => _game?.jump(),
                        onSlide: () => _game?.slide(),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
