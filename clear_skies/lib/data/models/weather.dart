import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final String cityName;
  final double temperature;
  final int weatherCode;
  final bool isDay;

  const Weather({
    required this.cityName,
    required this.temperature,
    required this.weatherCode,
    required this.isDay,
  });

  @override
  List<Object?> get props => [cityName, temperature, weatherCode, isDay];

  factory Weather.fromJson(String cityName, Map<String, dynamic> json) {
    final current = json['current_weather'] ?? {};
    return Weather(
      cityName: cityName,
      temperature: (current['temperature'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (current['weathercode'] as num?)?.toInt() ?? 0,
      isDay: (current['is_day'] as num?)?.toInt() == 1,
    );
  }
}
