import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/core.dart';
import 'package:shorebird_runner/features/tournament_lobby/models/models.dart';
import 'package:shorebird_runner/game/game.dart';

class PlayerListCard extends StatelessWidget {
  final List<LobbyPlayer> players;
  final String? myPlayerId;

  const PlayerListCard({
    super.key,
    required this.players,
    required this.myPlayerId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.panelNavy.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CONNECTED DEVELOPERS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              _PlayerCountBadge(count: players.length),
            ],
          ),
          const SizedBox(height: 14),
          if (players.isEmpty)
            const _EmptyPlayersPlaceholder()
          else
            ...players.map((p) => _PlayerRow(
                  player: p,
                  isMe: p.id == myPlayerId,
                  isRoomHost: p.id == players.firstOrNull?.id,
                )),
        ],
      ),
    );
  }
}

class _PlayerCountBadge extends StatelessWidget {
  final int count;

  const _PlayerCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final isEmpty = count == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isEmpty
            ? Colors.orange.withValues(alpha: 0.15)
            : AppColors.neonGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isEmpty ? '0 JOINED' : '$count READY',
        style: TextStyle(
          color: isEmpty ? Colors.orange : AppColors.neonGreen,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyPlayersPlaceholder extends StatelessWidget {
  const _EmptyPlayersPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyan),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'AWAITING DEVELOPERS TO JOIN...',
            style: TextStyle(
              color: AppColors.cyan,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Scan the QR code above or enter room code on mobile devices.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final LobbyPlayer player;
  final bool isMe;
  final bool isRoomHost;

  const _PlayerRow({
    required this.player,
    required this.isMe,
    required this.isRoomHost,
  });

  Color get _skinColor {
    switch (player.skin) {
      case PlayerSkin.goldPhoenix:
        return AppColors.skinAmber;
      case PlayerSkin.emeraldFalcon:
        return AppColors.skinGreen;
      case PlayerSkin.violetRaven:
        return AppColors.skinPurple;
      case PlayerSkin.blueBird:
        return AppColors.skinBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final skinColor = _skinColor;
    final skinEmoji = player.skin.emoji;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.cyan.withValues(alpha: 0.12)
            : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMe ? AppColors.cyan : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Text(skinEmoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.name,
                      style: TextStyle(
                        color: isMe ? AppColors.cyan : Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    if (isMe)
                      const _PlayerBadge(label: 'YOU', color: AppColors.cyan),
                    if (isRoomHost)
                      const _PlayerBadge(
                          label: '👑 HOST', color: AppColors.goldMedal),
                  ],
                ),
                Text(
                  player.skin.displayName,
                  style: TextStyle(
                    color: skinColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.neonGreen, size: 18),
        ],
      ),
    );
  }
}

class _PlayerBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _PlayerBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
