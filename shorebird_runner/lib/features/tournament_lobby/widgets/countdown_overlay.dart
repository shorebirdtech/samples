import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/core.dart';

class CountdownOverlay extends StatelessWidget {
  final int count;

  const CountdownOverlay({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GET READY!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$count',
              style: const TextStyle(
                color: AppColors.neonGreen,
                fontSize: 120,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(color: AppColors.neonGreen, blurRadius: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
