import 'package:equatable/equatable.dart';

class DailyForecast extends Equatable {
  final DateTime date;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
  });

  @override
  List<Object?> get props => [date, weatherCode, maxTemp, minTemp];
}
