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
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 48),
                      Expanded(
                        child: Text(
                          weather.cityName,
                          style: GoogleFonts.outfit(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: textColor,
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
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDetailItem(
                        Icons.water_drop_outlined,
                        '${weather.humidity}%',
                        'Humidity',
                        textColor,
                      ),
                      _buildDetailItem(
                        Icons.air_rounded,
                        '${weather.windSpeed.round()} km/h',
                        'Wind',
                        textColor,
                      ),
                      _buildDetailItem(
                        Icons.thermostat_outlined,
                        '${weather.feelsLike.round()}°',
                        'Feels',
                        textColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: textColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: textColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            WeatherHelper.getWeatherSuggestion(
                              weather.weatherCode,
                              weather.temperature,
                            ),
                            style: GoogleFonts.inter(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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

  Widget _buildDetailItem(
    IconData icon,
    String value,
    String label,
    Color textColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: textColor.withValues(alpha: 0.7), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: textColor.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
