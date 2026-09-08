import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/audio/audio_service.dart';
import 'package:shorebird_runner/core/constants/app_colors.dart';
import 'package:shorebird_runner/core/constants/app_strings.dart';

/// Tactile mobile bottom bar for one-handed thumb steering, jumping, and sliding.
class MobileTouchBar extends StatelessWidget {
  final VoidCallback onLeft;
  final VoidCallback onMid;
  final VoidCallback onRight;
  final VoidCallback onJump;
  final VoidCallback onSlide;

  const MobileTouchBar({
    super.key,
    required this.onLeft,
    required this.onMid,
    required this.onRight,
    required this.onJump,
    required this.onSlide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.controlBarBg,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _buildTouchButton(
                label: AppStrings.left,
                icon: Icons.arrow_left,
                color: AppColors.cyan,
                onTap: onLeft,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildTouchButton(
                label: AppStrings.mid,
                icon: Icons.adjust,
                color: AppColors.shorebirdGold,
                onTap: onMid,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildTouchButton(
                label: AppStrings.right,
                icon: Icons.arrow_right,
                color: AppColors.cyan,
                onTap: onRight,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTouchButton(
                label: AppStrings.jump,
                icon: Icons.keyboard_double_arrow_up,
                color: AppColors.neonGreen,
                onTap: onJump,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildTouchButton(
                label: AppStrings.slide,
                icon: Icons.keyboard_double_arrow_down,
                color: AppColors.hotReloadOrange,
                onTap: onSlide,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTouchButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AudioService.playSelect();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.45)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
