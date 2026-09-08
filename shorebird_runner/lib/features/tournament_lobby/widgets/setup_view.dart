import 'package:flutter/material.dart';
import 'package:shorebird_runner/features/start_menu/start_menu.dart';
import 'package:shorebird_runner/features/tournament_lobby/widgets/skin_choice_chip.dart';
import 'package:shorebird_runner/game/game.dart';

class SetupView extends StatelessWidget {
  final TextEditingController nameController;
  final VoidCallback onCreateAsSpectator;
  final VoidCallback onCreateAsRacer;
  final VoidCallback onJoinRoom;
  final TextEditingController codeController;

  const SetupView({
    super.key,
    required this.nameController,
    required this.onCreateAsSpectator,
    required this.onCreateAsRacer,
    required this.onJoinRoom,
    required this.codeController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Setup Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A192F).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'DEVELOPER PROFILE',
                      style: TextStyle(
                        color: Color(0xFF00D4FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => showGameRulesDialog(context),
                      icon: const Icon(Icons.menu_book,
                          size: 15, color: Color(0xFF00FF88)),
                      label: const Text(
                        'Rules',
                        style: TextStyle(
                          color: Color(0xFF00FF88),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'DEVELOPER HANDLE',
                    labelStyle:
                        const TextStyle(color: Colors.white60, fontSize: 12),
                    prefixIcon: const Icon(Icons.sports_esports,
                        color: Color(0xFF00D4FF)),
                    filled: true,
                    fillColor: const Color(0xFF050F1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFF00D4FF), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'CHOOSE DEVELOPER PERSONA',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    SkinChoiceChip(
                        skin: PlayerSkin.blueBird,
                        label: '👨‍💻 Shorebird Dev',
                        color: Color(0xFF00D4FF)),
                    SkinChoiceChip(
                        skin: PlayerSkin.goldPhoenix,
                        label: '🧑‍💻 Frontend Ninja',
                        color: Color(0xFFFFB347)),
                    SkinChoiceChip(
                        skin: PlayerSkin.emeraldFalcon,
                        label: '⚡ Fullstack Hero',
                        color: Color(0xFF00FF88)),
                    SkinChoiceChip(
                        skin: PlayerSkin.violetRaven,
                        label: '👾 Bug Hunter',
                        color: Color(0xFFA855F7)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action Split: Create vs Join
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 650;
              final cards = [
                Expanded(
                  flex: isNarrow ? 0 : 1,
                  child: _CreateCard(
                    onCreateAsSpectator: onCreateAsSpectator,
                    onCreateAsRacer: onCreateAsRacer,
                  ),
                ),
                if (!isNarrow)
                  const SizedBox(width: 20)
                else
                  const SizedBox(height: 16),
                Expanded(
                  flex: isNarrow ? 0 : 1,
                  child: _JoinCard(
                    codeController: codeController,
                    onJoinRoom: onJoinRoom,
                  ),
                ),
              ];

              return isNarrow
                  ? Column(children: cards)
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: cards);
            },
          ),
        ],
      ),
    );
  }
}

class _CreateCard extends StatelessWidget {
  final VoidCallback onCreateAsSpectator;
  final VoidCallback onCreateAsRacer;

  const _CreateCard({
    required this.onCreateAsSpectator,
    required this.onCreateAsRacer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0A192F).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFF00FF88).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              _CardIcon(
                  icon: Icons.add_circle_outline, color: Color(0xFF00FF88)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOST TOURNAMENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Create room without participant; attendees join from devices',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onCreateAsSpectator,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4FF),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              elevation: 8,
              shadowColor: const Color(0xFF00D4FF).withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Row(
              children: [
                Icon(Icons.tv, color: Colors.black, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HOST AS SPECTATOR (BOOTH DISPLAY)',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Creates room with 0 racers. Attendees join from their phones!',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black54),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onCreateAsRacer,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF00FF88),
              side: const BorderSide(color: Color(0xFF00FF88), width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Row(
              children: [
                Icon(Icons.sports_esports, color: Color(0xFF00FF88), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HOST & RACE ON THIS DEVICE',
                        style: TextStyle(
                          color: Color(0xFF00FF88),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Creates room and adds you as Racer #1 on this screen.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 14, color: Color(0xFF00FF88)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinCard extends StatelessWidget {
  final TextEditingController codeController;
  final VoidCallback onJoinRoom;

  const _JoinCard({
    required this.codeController,
    required this.onJoinRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0A192F).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFFFFB347).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              _CardIcon(icon: Icons.vpn_key_outlined, color: Color(0xFFFFB347)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JOIN ROOM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Enter 4-character code from host',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: codeController,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFB347),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.0,
                  ),
                  decoration: InputDecoration(
                    hintText: 'CODE',
                    hintStyle: const TextStyle(
                        color: Colors.white24, letterSpacing: 2.0),
                    filled: true,
                    fillColor: const Color(0xFF050F1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onJoinRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB347),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'JOIN',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _CardIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
