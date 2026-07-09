import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

class ResetWeather extends WeatherEvent {}

class WeatherRequested extends WeatherEvent {
  final String cityName;

  const WeatherRequested(this.cityName);

  @override
  List<Object> get props => [cityName];
}

class WeatherLocationRequested extends WeatherEvent {
  final double latitude;
  final double longitude;
  final String cityName;

  const WeatherLocationRequested({
    required this.latitude,
    required this.longitude,
    required this.cityName,
  });

  @override
  List<Object> get props => [latitude, longitude, cityName];
}
