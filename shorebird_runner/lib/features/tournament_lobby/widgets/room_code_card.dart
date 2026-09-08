import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shorebird_runner/core/constants/constants.dart';
import 'package:shorebird_runner/features/start_menu/start_menu.dart';

class RoomCodeCard extends StatelessWidget {
  final String roomCode;
  final bool isHost;
  final String inviteUrl;

  const RoomCodeCard({
    super.key,
    required this.roomCode,
    required this.isHost,
    required this.inviteUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cyan.withValues(alpha: 0.15),
            AppColors.roadDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cyan, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan.withValues(alpha: 0.25),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'SHARE ROOM CODE WITH BOOTH ATTENDEES',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                roomCode,
                style: const TextStyle(
                  color: AppColors.cyan,
                  fontSize: 46,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8.0,
                  shadows: [
                    Shadow(
                      color: AppColors.cyan,
                      blurRadius: 18,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.copy, color: AppColors.cyan),
                tooltip: 'Copy Code',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: roomCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Room code copied to clipboard!'),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isHost
                ? '👑 YOU ARE THE TOURNAMENT HOST'
                : 'WAITING FOR HOST TO START RACE...',
            style: TextStyle(
              color: isHost ? AppColors.goldMedal : Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          _InviteQrSection(inviteUrl: inviteUrl),
        ],
      ),
    );
  }
}

class _InviteQrSection extends StatelessWidget {
  final String inviteUrl;

  const _InviteQrSection({required this.inviteUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.cyan.withValues(alpha: 0.35),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 10,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(6),
              child: QrImageView(
                data: inviteUrl,
                version: QrVersions.auto,
                size: 110,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: AppColors.cyan,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'SCAN TO JOIN ON PHONE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Point any mobile phone camera\nto auto-join this room instantly.',
                style: TextStyle(color: AppColors.slateBlue, fontSize: 11),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.cyan,
                      side: BorderSide(
                        color: AppColors.cyan.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.link, size: 14),
                    label: const Text(
                      'Copy Invite Link',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: inviteUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Invite link copied! Share with attendees.',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.neonGreen,
                      side: BorderSide(
                        color: AppColors.neonGreen.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.menu_book, size: 14),
                    label: const Text(
                      'Rules',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => showGameRulesDialog(context),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
