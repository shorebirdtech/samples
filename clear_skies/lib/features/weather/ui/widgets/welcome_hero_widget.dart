import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clear_skies/core/core.dart';

class WelcomeHeroWidget extends StatefulWidget {
  final Color textColor;

  const WelcomeHeroWidget({super.key, required this.textColor});

  @override
  State<WelcomeHeroWidget> createState() => _WelcomeHeroWidgetState();
}

class _WelcomeHeroWidgetState extends State<WelcomeHeroWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Add slight shadow for better contrast against vibrant gradients
    final shadowColor = widget.textColor == AppColors.textDay
        ? Colors.black12
        : Colors.black45;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Floating Elements
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final offset = math.sin(_controller.value * math.pi) * 15;
                return Transform.translate(
                  offset: Offset(0, offset),
                  child: child,
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.cloud_rounded,
                    size: 160,
                    color: Colors.white.withValues(alpha: 0.9),
                    shadows: [Shadow(color: shadowColor, blurRadius: 20)],
                  ),
                  Positioned(
                    top: -10,
                    right: 20,
                    child: Icon(
                      Icons.wb_sunny_rounded,
                      size: 90,
                      color: Colors.amber.shade400,
                      shadows: [Shadow(color: shadowColor, blurRadius: 15)],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 64),

            // Typography without card background
            Text(
              AppStrings.welcomeTitle,
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: widget.textColor,
                shadows: [Shadow(color: shadowColor, blurRadius: 10)],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.welcomeSubtitle,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: widget.textColor.withValues(alpha: 0.9),
                shadows: [Shadow(color: shadowColor, blurRadius: 5)],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
