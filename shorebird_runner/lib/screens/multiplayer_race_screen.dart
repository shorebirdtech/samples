import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shorebird_runner/game/components/player.dart';
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
  ShorebirdRunnerGame? _game;
  bool _hasCrashed = false;
  int _finalScore = 0;
  int _finalPatches = 0;

  @override
  void initState() {
    super.initState();
    _lobby.addListener(_onLobbyChanged);

    if (!_lobby.isSpectator) {
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

    if (_lobby.isSpectator) {
      return _buildSpectatorScreen(standings);
    }

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
                    game: _game!,
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF0A192F).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFF00D4FF)
                                  .withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            const Text('🌐 ROOM: ',
                                style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Text('QUIT',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),

                  // Real-time Standings Mini Board
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A192F).withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color:
                                const Color(0xFFFFB347).withValues(alpha: 0.4)),
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
                              Icon(Icons.bolt,
                                  color: Color(0xFFFFB347), size: 12),
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
                                  Text(medal,
                                      style: const TextStyle(fontSize: 10)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      s.name + (isMe ? ' (YOU)' : ''),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isMe
                                            ? const Color(0xFF00D4FF)
                                            : Colors.white,
                                        fontWeight: isMe
                                            ? FontWeight.w900
                                            : FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    s.isAlive ? '${s.score}' : '💥',
                                    style: TextStyle(
                                      color: s.isAlive
                                          ? const Color(0xFF00FF88)
                                          : const Color(0xFFFF2A4B),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A192F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFFFF2A4B), width: 1.5),
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
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF00D4FF)),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Awaiting race completion...',
                              style: TextStyle(
                                  color: Color(0xFF00D4FF), fontSize: 12),
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

  Widget _buildSpectatorScreen(List<RacerStanding> standings) {
    final activeCount = standings.where((s) => s.isAlive).length;

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
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
                          color:
                              const Color(0xFF00D4FF).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                const Color(0xFF00D4FF).withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Text('🐤', style: TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SHOREBIRD PATCH RUSH',
                            style: TextStyle(
                              color: Color(0xFF00D4FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF2A4B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'LIVE TOURNAMENT SPECTATOR BOARD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A192F),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                const Color(0xFF00FF88).withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FF88)
                                  .withValues(alpha: 0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Text('ROOM: ',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                            Text(
                              _lobby.currentRoomCode ?? '----',
                              style: const TextStyle(
                                color: Color(0xFF00FF88),
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
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A192F),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                const Color(0xFF00D4FF).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          '$activeCount / ${standings.length} DEVELOPERS RUNNING',
                          style: const TextStyle(
                            color: Color(0xFF00D4FF),
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
                              borderRadius: BorderRadius.circular(10)),
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
                            borderGlow = const Color(0xFFFFD700);
                            rankColor = const Color(0xFFFFD700);
                            medal = '🥇 1ST';
                          } else if (s.rank == 2) {
                            borderGlow = const Color(0xFFC0C0C0);
                            rankColor = const Color(0xFFC0C0C0);
                            medal = '🥈 2ND';
                          } else if (s.rank == 3) {
                            borderGlow = const Color(0xFFCD7F32);
                            rankColor = const Color(0xFFCD7F32);
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
                              color: const Color(0xFF0A192F)
                                  .withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: s.isAlive
                                    ? borderGlow
                                    : const Color(0xFFFF2A4B)
                                        .withValues(alpha: 0.5),
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
                                // Avatar & Rank
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(skinEmoji,
                                        style: const TextStyle(fontSize: 32)),
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
                                // Player stats
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
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: s.isAlive
                                                  ? const Color(0xFF00FF88)
                                                      .withValues(alpha: 0.15)
                                                  : const Color(0xFFFF2A4B)
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
                                                    ? const Color(0xFF00FF88)
                                                    : const Color(0xFFFF2A4B),
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
                                          color: Color(0xFF00D4FF),
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
                                              color: Color(0xFFFFD700),
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

              // Bottom status bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A192F).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: Color(0xFF00D4FF)),
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
