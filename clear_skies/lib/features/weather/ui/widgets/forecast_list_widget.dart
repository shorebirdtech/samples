import 'package:flutter/material.dart';
import 'package:clear_skies/features/features.dart';
import 'package:clear_skies/core/core.dart';
import 'package:google_fonts/google_fonts.dart';

class ForecastListWidget extends StatelessWidget {
  final List<DailyForecast> forecast;
  final Color textColor;

  const ForecastListWidget({
    super.key,
    required this.forecast,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecast.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final day = forecast[index];
          final dateString = index == 0
              ? 'Today'
              : _getWeekday(day.date.weekday);

          return Container(
            width: 80,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  dateString,
                  style: GoogleFonts.inter(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                Text(
                  WeatherHelper.getWeatherIcon(day.weatherCode),
                  style: const TextStyle(fontSize: 28),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${day.maxTemp.round()}°',
                      style: GoogleFonts.inter(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${day.minTemp.round()}°',
                      style: GoogleFonts.inter(
                        color: textColor.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }
}
