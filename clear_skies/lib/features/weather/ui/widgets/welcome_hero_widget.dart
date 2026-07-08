import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clear_skies/core/core.dart';

class WelcomeHeroWidget extends StatefulWidget {
  final Color textColor;
  final void Function(String)? onCityTapped;

  const WelcomeHeroWidget({
    super.key, 
    required this.textColor,
    this.onCityTapped,
  });

  @override
  State<WelcomeHeroWidget> createState() => _WelcomeHeroWidgetState();
}

class _WelcomeHeroWidgetState extends State<WelcomeHeroWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Elegant Typography
                Text(
                  AppStrings.welcomeTitle,
                  style: GoogleFonts.outfit(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                    color: widget.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.welcomeSubtitle,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                    color: widget.textColor.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Popular Destinations
                Text(
                  'Popular Destinations',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                    color: widget.textColor.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    'Tokyo',
                    'London',
                    'New York',
                    'Paris',
                    'Dubai',
                  ].map((city) => _buildCityChip(city)).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCityChip(String city) {
    return GestureDetector(
      onTap: () {
        if (widget.onCityTapped != null) {
          widget.onCityTapped!(city);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: widget.textColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.textColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              city,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: widget.textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
