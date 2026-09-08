import 'package:flutter/material.dart';
import 'package:shorebird_runner/game/utils/audio_service.dart';

void showGameRulesDialog(BuildContext context, {VoidCallback? onStart}) {
  AudioService.playSelect();
  showDialog(
    context: context,
    builder: (ctx) => GameRulesDialog(onStart: onStart),
  );
}

class GameRulesDialog extends StatelessWidget {
  final VoidCallback? onStart;

  const GameRulesDialog({super.key, this.onStart});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 680),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A1324),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00D4FF).withValues(alpha: 0.6),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withValues(alpha: 0.25),
                blurRadius: 30,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 40,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1E38),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D4FF).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00D4FF).withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Text('📜', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RULES & MISSION BRIEFING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            'Shorebird Patch Rush • Developer Manual',
                            style: TextStyle(
                              color: Color(0xFF00D4FF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white60),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rule 1: The Character & Mission
                      _buildRuleCard(
                        icon: '👨‍💻',
                        title: 'YOU ARE THE DEVELOPER',
                        color: const Color(0xFF00D4FF),
                        content:
                            'You are a mobile engineer sprinting down the production highway. Your mission is to push instant updates directly to users via Shorebird CodePush while avoiding release bottlenecks.',
                      ),
                      const SizedBox(height: 14),

                      // Rule 2: Controls
                      _buildRuleCard(
                        icon: '🎮',
                        title: 'SUBWAY SURFERS STYLE CONTROLS',
                        color: const Color(0xFF00FF88),
                        content:
                            '• Steer Lanes: A / D or Arrow Keys (← / →), or Swipe Left / Right.\n'
                            '• Jump: W / Space / ArrowUp or Swipe Up to leap over low barricades & bugs (+150 LEAP!).\n'
                            '• Slide: S / ArrowDown or Swipe Down to crouch-slide under high review gates (+150 SLIDE!). In mid-air, slide triggers a fast dive-down.\n'
                            '• Mobile Touch: Tap top for Jump, bottom for Slide, left/right for lanes.',
                      ),
                      const SizedBox(height: 14),

                      // Rule 3: Collect Patches & Tier Up
                      _buildRuleCard(
                        icon: '🐤',
                        title: 'COLLECT 🐤 PATCHES & ⚡ HOT RELOAD',
                        color: const Color(0xFFFFD700),
                        content:
                            '• 🐤 Shorebird Patches: Grab patches to unlock higher plan tiers:\n'
                            '  - 🐣 HOBBY: 5,000 Patches\n'
                            '  - ⚡ PRO: 50,000 Patches\n'
                            '  - 💼 BUSINESS: 1,000,000 Patches\n'
                            '  - 👑 ENTERPRISE: Custom Patches (Apex Speed)\n'
                            '• ⚡ Hot Reload Booster: Grants 6s invincibility shield, speed boost, patch magnet, and smashes obstacles (+300 SMASH!).',
                      ),
                      const SizedBox(height: 14),

                      // Rule 4: Hazards to Avoid
                      _buildRuleCard(
                        icon: '⚠️',
                        title: 'HAZARDS & CLEARANCES',
                        color: const Color(0xFFFF2A4B),
                        content:
                            '• 🍏 / ▶️ App & Play Stores: Tall monoliths — must dodge sideways!\n'
                            '• 🐛 Worm Bugs & 🚧 Merge Barricades: Low hazards — jump over or steer around.\n'
                            '• 🚨 App Review Laser Gate: High barrier — slide underneath or steer around.\n'
                            '• 🔥 Near Miss: Weaving past obstacles at the last millisecond earns +250 NEAR MISS bonus!',
                      ),
                      const SizedBox(height: 14),

                      // Rule 5: Multiplayer & Tournaments
                      _buildRuleCard(
                        icon: '🏆',
                        title: 'MULTIPLAYER BOOTH TOURNAMENTS',
                        color: const Color(0xFFA855F7),
                        content:
                            '• Big-Screen Spectator Mode: Host creates a room with 0 racers for a booth TV display.\n'
                            '• Instant Join: Attendees scan the on-screen QR code from their mobile devices.\n'
                            '• Simultaneous Race: Everyone races live. Survivors climb the real-time leaderboard!',
                      ),
                    ],
                  ),
                ),
              ),

              // Footer Actions
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1E38),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(18)),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'BACK',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (onStart != null) {
                            onStart!();
                          }
                        },
                        icon: const Icon(Icons.rocket_launch,
                            color: Colors.black, size: 20),
                        label: Text(
                          onStart != null ? 'START RUN NOW 🚀' : 'GOT IT! 🚀',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FF88),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 6,
                          shadowColor:
                              const Color(0xFF00FF88).withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
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

  Widget _buildRuleCard({
    required String icon,
    required String title,
    required Color color,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF060D1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
