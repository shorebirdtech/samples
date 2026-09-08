import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/core/constants/constants.dart';
import 'package:shorebird_runner/features/tournament_lobby/bloc/lobby_bloc.dart';

class SpectatorBanner extends StatelessWidget {
  final String nameControllerText;

  const SpectatorBanner({super.key, required this.nameControllerText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cyan.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tv, color: AppColors.cyan, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BIG SCREEN / SPECTATOR BOARD',
                  style: TextStyle(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'This screen hosts the live spectator view. Attendees join from their phones.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {
              final state = context.read<LobbyBloc>().state;
              context.read<LobbyBloc>().add(
                    JoinAsParticipantRequested(
                      playerName: nameControllerText.isEmpty
                          ? 'Host Pilot'
                          : nameControllerText,
                      skin: state.selectedSkin,
                    ),
                  );
            },
            icon: const Icon(
              Icons.sports_esports,
              size: 16,
              color: AppColors.neonGreen,
            ),
            label: const Text(
              'Join as Racer',
              style: TextStyle(
                color: AppColors.neonGreen,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
