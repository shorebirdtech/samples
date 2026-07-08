import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:clear_skies/data/models/models.dart';
import 'package:clear_skies/core/core.dart';
import 'package:google_fonts/google_fonts.dart';

class WeatherDisplay extends StatelessWidget {
  final Weather weather;

  const WeatherDisplay({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final isDay = weather.isDay;
    final textColor = isDay ? AppColors.textDay : AppColors.textNight;
    final cardColor = isDay ? AppColors.cardDay : AppColors.cardNight;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weather.cityName,
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    WeatherHelper.getWeatherIcon(weather.weatherCode),
                    style: const TextStyle(fontSize: 100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${weather.temperature.round()}°',
                    style: GoogleFonts.inter(
                      fontSize: 84,
                      fontWeight: FontWeight.w200,
                      color: textColor,
                    ),
                  ),
                  Text(
                    WeatherHelper.getWeatherDescription(weather.weatherCode),
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
