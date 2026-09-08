import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/features/tournament_lobby/bloc/lobby_bloc.dart';
import 'package:shorebird_runner/game/game.dart';

class SkinChoiceChip extends StatelessWidget {
  final PlayerSkin skin;
  final String label;
  final Color color;

  const SkinChoiceChip({
    super.key,
    required this.skin,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected =
        context.select((LobbyBloc b) => b.state.selectedSkin) == skin;
    return InkWell(
      onTap: () {
        AudioService.playSelect();
        context.read<LobbyBloc>().add(LobbySkinSelected(skin));
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.25)
              : const Color(0xFF050F1E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
