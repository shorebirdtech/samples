import 'package:clear_skies/logic/bloc/bloc.dart';

class WeatherRequested extends WeatherEvent {
  final String cityName;

  const WeatherRequested(this.cityName);

  @override
  List<Object> get props => [cityName];
}
