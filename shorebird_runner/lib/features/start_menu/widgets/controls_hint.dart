import 'package:flutter/material.dart';
import 'package:shorebird_runner/features/start_menu/widgets/control_row.dart';

class ControlsHint extends StatelessWidget {
  const ControlsHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF12141A),
        border: Border.all(color: const Color(0xFF263238)),
      ),
      child: Column(
        children: [
          const ControlRow(
            keys: ['A', 'D', '◀▶'],
            label: 'Switch lanes',
            color: Color(0xFFFFC107),
          ),
          const SizedBox(height: 8),
          const ControlRow(
            keys: ['W', '↑', 'Space'],
            label: 'Jump over obstacles',
            color: Color(0xFF26C6DA),
          ),
          const SizedBox(height: 8),
          const ControlRow(
            keys: ['S', '↓'],
            label: 'Slide under obstacles',
            color: Color(0xFF66BB6A),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5252).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.25)),
            ),
            child: const Text(
              '⚠️  HIGH DIFFICULTY — Missing a patch costs -15 pts & resets combo!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFEF9A9A),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
