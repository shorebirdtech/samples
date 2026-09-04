import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shorebird_runner/game/shorebird_runner_game.dart';
import 'package:shorebird_runner/game/utils/audio_service.dart';
import 'package:shorebird_runner/services/lobby_service.dart';

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
  final _lobby = LobbyService.instance;
  late ShorebirdRunnerGame _game;
  bool _hasCrashed = false;
  int _finalScore = 0;
  int _finalPatches = 0;

  @override
  void initState() {
    super.initState();
    _lobby.addListener(_onLobbyChanged);

    _game = ShorebirdRunnerGame(
      controlScheme: ControlScheme.both,
      skin: _lobby.mySkin,
      playerTag: _lobby.myPlayerName,
      onScoreUpdate: (score, patches, level, isAlive) {
        _lobby.sendScoreUpdate(score, patches, level.level, isAlive);
      },
      onGameOver: (score, patches, level) {
        if (!mounted) return;
        setState(() {
          _hasCrashed = true;
          _finalScore = score;
          _finalPatches = patches;
        });
        _lobby.sendScoreUpdate(score, patches, level.level, false);
      },
    );
  }

  void _onLobbyChanged() {
    if (!mounted) return;
    if (_lobby.finalRankings != null) {
      widget.onRaceFinished(_lobby.finalRankings!);
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _lobby.removeListener(_onLobbyChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final standings = _lobby.standings.isNotEmpty
        ? _lobby.standings
        : _lobby.players.map((p) {
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

    return Scaffold(
      backgroundColor: const Color(0xFF050A14),
      body: Stack(
        children: [
          // 3D Game Canvas
          Center(
            child: AspectRatio(
              aspectRatio: 800 / 600,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: GameWidget(
                    game: _game,
                    backgroundBuilder: (context) => Container(
                      color: const Color(0xFF0A0E1A),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Top Header Overlay: Room Code & Status
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room Badge & Leave Button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A192F).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF00D4FF).withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            const Text('🌐 ROOM: ', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                            Text(
                              _lobby.currentRoomCode ?? '----',
                              style: const TextStyle(
                                color: Color(0xFF00D4FF),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Text('QUIT', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),

                  // Real-time Standings Mini Board
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A192F).withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFB347).withValues(alpha: 0.4)),
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
                                  color: Color(0xFFFFB347),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Icon(Icons.bolt, color: Color(0xFFFFB347), size: 12),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ...standings.take(4).map((s) {
                            final isMe = s.id == _lobby.myPlayerId;
                            String medal = '#${s.rank}';
                            if (s.rank == 1) medal = '🥇';
                            if (s.rank == 2) medal = '🥈';
                            if (s.rank == 3) medal = '🥉';

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Text(medal, style: const TextStyle(fontSize: 10)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      s.name + (isMe ? ' (YOU)' : ''),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isMe ? const Color(0xFF00D4FF) : Colors.white,
                                        fontWeight: isMe ? FontWeight.w900 : FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    s.isAlive ? '${s.score}' : '💥',
                                    style: TextStyle(
                                      color: s.isAlive ? const Color(0xFF00FF88) : const Color(0xFFFF2A4B),
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
                  ),
                ],
              ),
            ),
          ),

          // Spectating / Crashed Overlay
          if (_hasCrashed)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.75),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A192F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFF2A4B), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF2A4B).withValues(alpha: 0.3),
                          blurRadius: 25,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '💥 RUN CRASHED',
                          style: TextStyle(
                            color: Color(0xFFFF2A4B),
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Final Score: $_finalScore • Patches: $_finalPatches',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D4FF)),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Awaiting race completion...',
                              style: TextStyle(color: Color(0xFF00D4FF), fontSize: 12),
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
}
