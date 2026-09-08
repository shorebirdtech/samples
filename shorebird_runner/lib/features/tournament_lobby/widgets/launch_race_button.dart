import 'package:flutter/material.dart';

class LaunchRaceButton extends StatelessWidget {
  final int playerCount;
  final VoidCallback onStartRace;

  const LaunchRaceButton({
    super.key,
    required this.playerCount,
    required this.onStartRace,
  });

  @override
  Widget build(BuildContext context) {
    final hasPlayers = playerCount > 0;
    return ElevatedButton.icon(
      onPressed: hasPlayers ? onStartRace : null,
      icon: Icon(
        hasPlayers ? Icons.play_arrow : Icons.hourglass_empty,
        color: Colors.black,
        size: 24,
      ),
      label: Text(
        hasPlayers
            ? 'LAUNCH RACE ($playerCount READY) 🚀'
            : 'WAITING FOR DEVELOPERS (0 JOINED)',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: 15,
          letterSpacing: 1.5,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            hasPlayers ? const Color(0xFF00FF88) : Colors.grey.shade600,
        disabledBackgroundColor: Colors.grey.shade700,
        padding: const EdgeInsets.symmetric(vertical: 18),
        elevation: hasPlayers ? 12 : 0,
        shadowColor: const Color(0xFF00FF88).withValues(alpha: 0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class WaitingForHostBanner extends StatelessWidget {
  const WaitingForHostBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D4FF)),
            ),
          ),
          SizedBox(width: 14),
          Text(
            'WAITING FOR HOST TO LAUNCH...',
            style: TextStyle(
              color: Color(0xFF00D4FF),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
