import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/core/core.dart';
import 'package:shorebird_runner/features/lead_capture/models/lead_model.dart';
import 'package:shorebird_runner/features/leaderboard/leaderboard.dart';
import 'package:shorebird_runner/features/solo_runner/bloc/solo_runner_bloc.dart';
import 'package:shorebird_runner/features/solo_runner/widgets/widgets.dart';
import 'package:shorebird_runner/game/game.dart';

class SoloRunnerScreen extends StatefulWidget {
  final PlayerSkin skin;
  final LeadModel? lead;
  final VoidCallback onBackToMenu;

  const SoloRunnerScreen({
    super.key,
    this.skin = PlayerSkin.blueBird,
    this.lead,
    required this.onBackToMenu,
  });

  @override
  State<SoloRunnerScreen> createState() => _SoloRunnerScreenState();
}

class _SoloRunnerScreenState extends State<SoloRunnerScreen> {
  ShorebirdRunnerGame? _game;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _initGame() {
    context.read<SoloRunnerBloc>().add(const StartSoloGame());
    _game = ShorebirdRunnerGame(
      controlScheme: ControlScheme.both,
      skin: widget.skin,
      playerTag: widget.lead?.playerTag,
      onPauseRequested: _togglePause,
      onGameOver: (score, patches, level) {
        if (!mounted) return;
        context.read<SoloRunnerBloc>().add(
              SoloGameOver(score: score, patches: patches, level: level),
            );

        if (score > 0) {
          final lead = widget.lead;
          final entry = LeaderboardEntryModel(
            playerName:
                lead?.name.isNotEmpty == true ? lead!.name : 'Anonymous Runner',
            score: score,
            patches: patches,
            organization: lead?.organization ?? '',
            event: lead?.event ?? '',
            createdAt: DateTime.now(),
          );
          context.read<LeaderboardBloc>().add(RecordScore(entry));
        }
      },
    );
  }

  void _pauseGame() {
    _game?.pauseEngine();
    context.read<SoloRunnerBloc>().add(const PauseSoloGame());
  }

  void _resumeGame() {
    _game?.resumeEngine();
    context.read<SoloRunnerBloc>().add(const ResumeSoloGame());
  }

  void _togglePause() {
    final status = context.read<SoloRunnerBloc>().state.status;
    if (status == SoloGameStatus.playing) {
      _pauseGame();
    } else if (status == SoloGameStatus.paused) {
      _resumeGame();
    }
  }

  void _restartGame() {
    context.read<SoloRunnerBloc>().add(const RestartSoloGame());
    _initGame();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SoloRunnerBloc, SoloRunnerState>(
      builder: (context, state) {
        return KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.escape ||
                  event.logicalKey == LogicalKeyboardKey.keyP) {
                _togglePause();
              }
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.backgroundDark,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isPortrait =
                      constraints.maxHeight > constraints.maxWidth;

                  final gameView = Stack(
                    children: [
                      Positioned.fill(
                        child: LayoutBuilder(
                          builder: (context, box) {
                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTapDown: (details) {
                                if (_game == null ||
                                    _game!.isOver ||
                                    state.status != SoloGameStatus.playing) {
                                  return;
                                }
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

                      // Top Left: Back to menu button
                      SoloExitButton(onBackToMenu: widget.onBackToMenu),

                      // Top Right: Audio & Pause Controls
                      if (state.status != SoloGameStatus.gameOver)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Mute/Unmute toggle
                              ValueListenableBuilder<bool>(
                                valueListenable: AudioService.isMutedNotifier,
                                builder: (context, isMuted, _) {
                                  return _HudIconButton(
                                    icon: isMuted
                                        ? Icons.volume_off_rounded
                                        : Icons.volume_up_rounded,
                                    color: isMuted
                                        ? AppColors.slateMuted
                                        : AppColors.shorebirdGold,
                                    tooltip: isMuted ? 'Unmute' : 'Mute',
                                    onTap: () => AudioService.toggleMute(),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              // Pause/Resume button
                              _HudIconButton(
                                icon: state.status == SoloGameStatus.paused
                                    ? Icons.play_arrow_rounded
                                    : Icons.pause_rounded,
                                color: AppColors.shorebirdGold,
                                tooltip: state.status == SoloGameStatus.paused
                                    ? 'Resume'
                                    : 'Pause',
                                onTap: _togglePause,
                              ),
                            ],
                          ),
                        ),

                      // Pause Overlay
                      if (state.status == SoloGameStatus.paused)
                        PauseOverlay(
                          score: _game?.score ?? state.score,
                          totalPatches: _game?.totalPatches ?? state.patches,
                          level: _game?.currentLevel ?? state.level,
                          onResume: _resumeGame,
                          onRestart: _restartGame,
                          onMenu: widget.onBackToMenu,
                        ),

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
                      if (isPortrait && state.status == SoloGameStatus.playing)
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
          ),
        );
      },
    );
  }
}

class _HudIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _HudIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () {
            AudioService.playSelect();
            onTap();
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
        ),
      ),
    );
  }
}
