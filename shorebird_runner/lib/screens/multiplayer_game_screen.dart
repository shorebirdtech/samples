import 'dart:async';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shorebird_runner/game/components/player.dart';
import 'package:shorebird_runner/game/shorebird_runner_game.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

/// Simultaneous 2-Player Split-Screen Booth Battle:
/// P1 (Left side, Blue Bird) controlled with WASD / Space
/// P2 (Right side, Gold Phoenix) controlled with Arrow Keys
class MultiplayerGameScreen extends StatefulWidget {
  final VoidCallback onBackToMenu;

  const MultiplayerGameScreen({super.key, required this.onBackToMenu});

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  late ShorebirdRunnerGame _gameP1;
  late ShorebirdRunnerGame _gameP2;
  Timer? _scoreSyncTimer;

  bool _p1Crashed = false;
  bool _p2Crashed = false;

  int _p1Score = 0;
  int _p2Score = 0;
  int _p1Patches = 0;
  int _p2Patches = 0;
  LevelConfig _p1Level = GameConfig.levels.first;
  LevelConfig _p2Level = GameConfig.levels.first;

  @override
  void initState() {
    super.initState();
    _startMatch();
  }

  void _startMatch() {
    _p1Crashed = false;
    _p2Crashed = false;
    _p1Score = 0;
    _p2Score = 0;
    _p1Patches = 0;
    _p2Patches = 0;

    _gameP1 = ShorebirdRunnerGame(
      controlScheme: ControlScheme.wasd,
      skin: PlayerSkin.blueBird,
      playerTag: 'P1 BLUE',
      onGameOver: (score, patches, level) {
        if (!mounted) return;
        setState(() {
          _p1Crashed = true;
          _p1Score = score;
          _p1Patches = patches;
          _p1Level = level;
        });
      },
    );

    _gameP2 = ShorebirdRunnerGame(
      controlScheme: ControlScheme.arrows,
      skin: PlayerSkin.goldPhoenix,
      playerTag: 'P2 GOLD',
      onGameOver: (score, patches, level) {
        if (!mounted) return;
        setState(() {
          _p2Crashed = true;
          _p2Score = score;
          _p2Patches = patches;
          _p2Level = level;
        });
      },
    );

    _scoreSyncTimer?.cancel();
    _scoreSyncTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      setState(() {
        if (!_p1Crashed) {
          _p1Score = _gameP1.score;
          _p1Patches = _gameP1.totalPatches;
          _p1Level = _gameP1.currentLevel;
        }
        if (!_p2Crashed) {
          _p2Score = _gameP2.score;
          _p2Patches = _gameP2.totalPatches;
          _p2Level = _gameP2.currentLevel;
        }
      });
    });
  }

  @override
  void dispose() {
    _scoreSyncTimer?.cancel();
    super.dispose();
  }

  bool get _bothEnded => _p1Crashed && _p2Crashed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A14),
      body: Stack(
        children: [
          // Dual Runners side by side
          Row(
            children: [
              // Player 1 Track (Left)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: AspectRatio(
                    aspectRatio: 800 / 600,
                    child: GameWidget(game: _gameP1),
                  ),
                ),
              ),

              // Player 2 Track (Right)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: const Color(0xFFFFB347).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: AspectRatio(
                    aspectRatio: 800 / 600,
                    child: GameWidget(game: _gameP2),
                  ),
                ),
              ),
            ],
          ),

          // Central VS Scoreboard Bar (Floating at Top)
          Align(
            alignment: Alignment.topCenter,
            child: _VsScoreboard(
              p1Score: _p1Score,
              p2Score: _p2Score,
              p1Crashed: _p1Crashed,
              p2Crashed: _p2Crashed,
            ),
          ),

          // Bottom Controls Hint Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: _MultiplayerControlsBar(onExit: widget.onBackToMenu),
          ),

          // Match Result Overlay when both finished
          if (_bothEnded)
            _MatchResultOverlay(
              p1Score: _p1Score,
              p2Score: _p2Score,
              p1Patches: _p1Patches,
              p2Patches: _p2Patches,
              p1Level: _p1Level,
              p2Level: _p2Level,
              onRematch: () => setState(() => _startMatch()),
              onMenu: widget.onBackToMenu,
            ),
        ],
      ),
    );
  }
}

class _VsScoreboard extends StatelessWidget {
  final int p1Score;
  final int p2Score;
  final bool p1Crashed;
  final bool p2Crashed;

  const _VsScoreboard({
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
        color: const Color(0xFF090E1A).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A3A5C)),
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
              color: const Color(0xFF00D4FF).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF00D4FF).withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Text('P1', style: TextStyle(color: Color(0xFF00D4FF), fontWeight: FontWeight.w900, fontSize: 12)),
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
              color: Color(0xFF00D4FF),
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              leadText,
              style: const TextStyle(
                color: Color(0xFFFFD166),
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
              color: Color(0xFFFFB347),
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
              color: const Color(0xFFFFB347).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFFFB347).withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Text('P2', style: TextStyle(color: Color(0xFFFFB347), fontWeight: FontWeight.w900, fontSize: 12)),
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

class _MultiplayerControlsBar extends StatelessWidget {
  final VoidCallback onExit;
  const _MultiplayerControlsBar({required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF090E1A).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔵 P1: [A][D] Move · [W]/[Space] Jump', style: TextStyle(color: Color(0xFF00D4FF), fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(width: 20),
          const Text('🟡 P2: [←][→] Move · [↑] Jump', style: TextStyle(color: Color(0xFFFFB347), fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: onExit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('✕ QUIT', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchResultOverlay extends StatelessWidget {
  final int p1Score;
  final int p2Score;
  final int p1Patches;
  final int p2Patches;
  final LevelConfig p1Level;
  final LevelConfig p2Level;
  final VoidCallback onRematch;
  final VoidCallback onMenu;

  const _MatchResultOverlay({
    required this.p1Score,
    required this.p2Score,
    required this.p1Patches,
    required this.p2Patches,
    required this.p1Level,
    required this.p2Level,
    required this.onRematch,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final bool p1Won = p1Score > p2Score;
    final bool p2Won = p2Score > p1Score;
    final bool isTie = p1Score == p2Score;

    final winnerTitle = isTie
        ? '⚔️ DRAW MATCH!'
        : (p1Won ? '👑 PLAYER 1 WINS!' : '👑 PLAYER 2 WINS!');
    final winnerColor = isTie
        ? const Color(0xFFFFD166)
        : (p1Won ? const Color(0xFF00D4FF) : const Color(0xFFFFB347));

    return Container(
      color: Colors.black.withValues(alpha: 0.88),
      child: Center(
        child: Container(
          width: 520,
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF131C31), Color(0xFF090E1A)],
            ),
            border: Border.all(color: winnerColor.withValues(alpha: 0.6), width: 2),
            boxShadow: [
              BoxShadow(
                color: winnerColor.withValues(alpha: 0.25),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                winnerTitle,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: winnerColor,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'BOOTH BATTLE FINAL RESULT',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // Side by Side Stats
              Row(
                children: [
                  Expanded(
                    child: _PlayerMatchCard(
                      tag: 'PLAYER 1',
                      isWinner: p1Won,
                      score: p1Score,
                      patches: p1Patches,
                      level: p1Level,
                      color: const Color(0xFF00D4FF),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _PlayerMatchCard(
                      tag: 'PLAYER 2',
                      isWinner: p2Won,
                      score: p2Score,
                      patches: p2Patches,
                      level: p2Level,
                      color: const Color(0xFFFFB347),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRematch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: winnerColor,
                    foregroundColor: const Color(0xFF0A0E1A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'PLAY REMATCH ⚔️',
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
                  style: TextStyle(color: Color(0xFF94A3B8), letterSpacing: 2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerMatchCard extends StatelessWidget {
  final String tag;
  final bool isWinner;
  final int score;
  final int patches;
  final LevelConfig level;
  final Color color;

  const _PlayerMatchCard({
    required this.tag,
    required this.isWinner,
    required this.score,
    required this.patches,
    required this.level,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: isWinner ? 0.7 : 0.25), width: isWinner ? 1.8 : 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tag,
                style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
              ),
              if (isWinner)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text('👑', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            score.toString().padLeft(6, '0'),
            style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
            '${level.emoji} ${level.name}',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '×$patches Patches',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
