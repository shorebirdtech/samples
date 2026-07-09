import 'package:equatable/equatable.dart';
import 'daily_forecast.dart';

class Weather extends Equatable {
  final String cityName;
  final double temperature;
  final int weatherCode;
  final bool isDay;
  final int humidity;
  final double feelsLike;
  final double windSpeed;
  final List<DailyForecast> forecast;

  const Weather({
    required this.cityName,
    required this.temperature,
    required this.weatherCode,
    required this.isDay,
    required this.humidity,
    required this.feelsLike,
    required this.windSpeed,
    required this.forecast,
  });

  @override
  List<Object?> get props => [
    cityName,
    temperature,
    weatherCode,
    isDay,
    humidity,
    feelsLike,
    windSpeed,
    forecast,
  ];

  factory Weather.fromJson(String cityName, Map<String, dynamic> json) {
    final current = json['current'] ?? {};
    final daily = json['daily'] ?? {};

    final List<DailyForecast> forecastList = [];
    final times = daily['time'] as List? ?? [];
    final codes = daily['weather_code'] as List? ?? [];
    final maxTemps = daily['temperature_2m_max'] as List? ?? [];
    final minTemps = daily['temperature_2m_min'] as List? ?? [];

    for (int i = 0; i < times.length; i++) {
      forecastList.add(
        DailyForecast(
          date: DateTime.parse(times[i]),
          weatherCode: (codes[i] as num).toInt(),
          maxTemp: (maxTemps[i] as num).toDouble(),
          minTemp: (minTemps[i] as num).toDouble(),
        ),
      );
    }

    return Weather(
      cityName: cityName,
      temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
      isDay: (current['is_day'] as num?)?.toInt() == 1,
      humidity: (current['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      feelsLike: (current['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      forecast: forecastList,
    );
  }
}
