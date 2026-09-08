import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shorebird_runner/game/shorebird_runner_game.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';
import 'package:shorebird_runner/screens/lobby_screen.dart';
import 'package:shorebird_runner/screens/multiplayer_race_screen.dart';
import 'package:shorebird_runner/screens/start_screen.dart';
import 'package:shorebird_runner/screens/tournament_podium_screen.dart';
import 'package:shorebird_runner/services/lobby_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PatchRushApp());
}

class PatchRushApp extends StatelessWidget {
  const PatchRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patch Rush — by Shorebird',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C0D10),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFC107),   // Shorebird Gold
          secondary: Color(0xFF00BCD4), // Pro Cyan
          surface: Color(0xFF111520),
          onPrimary: Color(0xFF1A1200),
          onSurface: Color(0xFFECEFF1),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFFFC107),
        ),
      ),
      home: const GameShell(),
    );
  }
}

enum AppMode { menu, solo, lobby, race, podium }

class GameShell extends StatefulWidget {
  const GameShell({super.key});

  @override
  State<GameShell> createState() => _GameShellState();
}

class _GameShellState extends State<GameShell> {
  AppMode _mode = AppMode.menu;
  ShorebirdRunnerGame? _soloGame;
  List<RacerStanding> _lastPodiumRankings = [];

  @override
  void initState() {
    super.initState();
    // Auto-enter multiplayer lobby if opened via an invite link with ?room=CODE
    if (Uri.base.queryParameters.containsKey('room')) {
      _mode = AppMode.lobby;
    }
  }

  void _startSolo() {
    final game = ShorebirdRunnerGame(
      controlScheme: ControlScheme.both,
      onGameOver: (score, patches, level) {},
    );
    setState(() {
      _soloGame = game;
      _mode = AppMode.solo;
    });
  }

  void _restartSolo() {
    setState(() {
      _soloGame = null;
    });
    Future.microtask(() => _startSolo());
  }

  @override
  Widget build(BuildContext context) {
    switch (_mode) {
      case AppMode.menu:
        return StartScreen(
          onStartSolo: _startSolo,
          onOpenLobby: () => setState(() => _mode = AppMode.lobby),
        );

      case AppMode.lobby:
        return LobbyScreen(
          onBackToMenu: () => setState(() => _mode = AppMode.menu),
          onRaceStarted: () => setState(() => _mode = AppMode.race),
        );

      case AppMode.race:
        return MultiplayerRaceScreen(
          onLeaveRace: () {
            LobbyService.instance.leaveRoom();
            setState(() => _mode = AppMode.lobby);
          },
          onRaceFinished: (rankings) {
            setState(() {
              _lastPodiumRankings = rankings;
              _mode = AppMode.podium;
            });
          },
        );

      case AppMode.podium:
        return TournamentPodiumScreen(
          rankings: _lastPodiumRankings,
          onRematch: () {
            LobbyService.instance.resetMatch();
            setState(() => _mode = AppMode.lobby);
          },
          onReturnToLobby: () {
            LobbyService.instance.leaveRoom();
            setState(() => _mode = AppMode.lobby);
          },
        );

      case AppMode.solo:
        return Scaffold(
          backgroundColor: const Color(0xFF0C0D10),
          body: Center(
            child: AspectRatio(
              aspectRatio: 800 / 600,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.20),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFC107).withValues(alpha: 0.08),
                        blurRadius: 48,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: GameWidget(
                    game: _soloGame!,
                    overlayBuilderMap: {
                      'game_over': (context, game) {
                        final g = game as ShorebirdRunnerGame;
                        return _GameOverOverlay(
                          score: g.score,
                          highScore: g.highScore,
                          totalPatches: g.totalPatches,
                          level: g.currentLevel,
                          onRestart: _restartSolo,
                          onMenu: () => setState(() {
                            _soloGame = null;
                            _mode = AppMode.menu;
                          }),
                        );
                      },
                    },
                    backgroundBuilder: (context) => Container(
                      color: const Color(0xFF0C0D10),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }
}

class _GameOverOverlay extends StatelessWidget {
  final int score;
  final int highScore;
  final int totalPatches;
  final LevelConfig level;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  const _GameOverOverlay({
    required this.score,
    required this.highScore,
    required this.totalPatches,
    required this.level,
    required this.onRestart,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final isNewRecord = score >= highScore && score > 0;
    final accentColor = Color(level.accentColor);
    // Use Shorebird gold as the primary action color in game over
    const shorebirdGold = Color(0xFFFFC107);

    return Container(
      color: Colors.black.withValues(alpha: 0.90),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF14161C),
                  Color(0xFF0C0D10),
                ],
              ),
              border: Border.all(
                color: shorebirdGold.withValues(alpha: 0.45),
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: shorebirdGold.withValues(alpha: 0.18),
                  blurRadius: 50,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Shorebird logo mark
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1A1600),
                    border: Border.all(
                      color: shorebirdGold.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: shorebirdGold.withValues(alpha: 0.3),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🐤', style: TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'RUN ENDED',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFF5252),
                    letterSpacing: 5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'A runtime crash occurred before code push.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF546E7A),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Stage Reached Badge
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: accentColor.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SHOREBIRD PLAN TIER',
                              style: TextStyle(
                                color: Color(0xFF546E7A),
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${level.emoji}  ${level.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: accentColor.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          level.planQuota,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (isNewRecord) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: shorebirdGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: shorebirdGold.withValues(alpha: 0.5)),
                    ),
                    child: const Text(
                      '🏆  NEW HIGH SCORE!',
                      style: TextStyle(
                        color: Color(0xFFFFC107),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                _ScoreRow(
                    label: 'SCORE',
                    value: score.toString().padLeft(6, '0'),
                    color: shorebirdGold),
                const SizedBox(height: 10),
                _ScoreRow(
                    label: 'PATCHES DEPLOYED',
                    value: '×$totalPatches',
                    color: const Color(0xFF00BCD4)),
                const SizedBox(height: 10),
                _ScoreRow(
                    label: 'ALL-TIME BEST',
                    value: highScore.toString().padLeft(6, '0'),
                    color: const Color(0xFF4CAF50)),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onRestart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: shorebirdGold,
                      foregroundColor: const Color(0xFF1A1200),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'PLAY AGAIN',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: onMenu,
                  child: const Text(
                    'MAIN MENU',
                    style: TextStyle(
                      color: Color(0xFF546E7A),
                      letterSpacing: 2,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ScoreRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
