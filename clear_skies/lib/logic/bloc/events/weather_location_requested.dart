import 'package:clear_skies/logic/bloc/bloc.dart';

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
