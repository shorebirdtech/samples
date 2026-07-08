import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:clear_skies/features/features.dart';
import 'package:clear_skies/core/core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WeatherDisplay extends StatelessWidget {
  final Weather weather;

  const WeatherDisplay({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final isDay = weather.isDay;
    final textColor = isDay ? AppColors.textDay : AppColors.textNight;
    final cardColor = isDay ? AppColors.cardDay : AppColors.cardNight;
    final shadowColor = isDay ? Colors.black12 : Colors.black45;

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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top area directly on background
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 48), // balance heart icon
                Expanded(
                  child: Text(
                    weather.cityName,
                    style: GoogleFonts.outfit(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      shadows: [Shadow(color: shadowColor, blurRadius: 10)],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                BlocBuilder<FavoritesBloc, FavoritesState>(
                  builder: (context, state) {
                    bool isFav = false;
                    if (state.status == FavoritesStatus.loaded) {
                      isFav = state.favorites.any(
                        (w) => w.cityName == weather.cityName,
                      );
                    }
                    return IconButton(
                      icon: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav ? Colors.redAccent : textColor,
                        size: 32,
                        shadows: [Shadow(color: shadowColor, blurRadius: 10)],
                      ),
                      onPressed: () {
                        if (isFav) {
                          context.read<FavoritesBloc>().add(
                            RemoveFavorite(weather.cityName),
                          );
                        } else {
                          context.read<FavoritesBloc>().add(
                            AddFavorite(weather),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              WeatherHelper.getWeatherIcon(weather.weatherCode),
              style: TextStyle(
                fontSize: 120,
                shadows: [Shadow(color: shadowColor, blurRadius: 20)],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${weather.temperature.round()}°',
              style: GoogleFonts.inter(
                fontSize: 96,
                fontWeight: FontWeight.w200,
                color: textColor,
                shadows: [Shadow(color: shadowColor, blurRadius: 10)],
              ),
            ),
            Text(
              WeatherHelper.getWeatherDescription(weather.weatherCode),
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: textColor.withValues(alpha: 0.9),
                shadows: [Shadow(color: shadowColor, blurRadius: 5)],
              ),
            ),
            const SizedBox(height: 48),

            // Secondary Details Micro-cards
            Row(
              children: [
                Expanded(
                  child: _buildGlassCard(
                    cardColor: cardColor,
                    child: _buildDetailItem(
                      Icons.water_drop_outlined,
                      '${weather.humidity}%',
                      'Humidity',
                      textColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGlassCard(
                    cardColor: cardColor,
                    child: _buildDetailItem(
                      Icons.air_rounded,
                      '${weather.windSpeed.round()} km/h',
                      'Wind',
                      textColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGlassCard(
                    cardColor: cardColor,
                    child: _buildDetailItem(
                      Icons.thermostat_outlined,
                      '${weather.feelsLike.round()}°',
                      'Feels Like',
                      textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Suggestion Tile
            _buildGlassCard(
              cardColor: cardColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: textColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        WeatherHelper.getWeatherSuggestion(
                          weather.weatherCode,
                          weather.temperature,
                        ),
                        style: GoogleFonts.inter(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, required Color cardColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String value,
    String label,
    Color textColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: textColor.withValues(alpha: 0.8), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: textColor.withValues(alpha: 0.7),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
