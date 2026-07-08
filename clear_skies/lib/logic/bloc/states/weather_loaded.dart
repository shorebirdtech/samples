import 'package:clear_skies/data/models/models.dart';
import 'package:clear_skies/logic/bloc/bloc.dart';

class WeatherLoaded extends WeatherState {
  final Weather weather;

  const WeatherLoaded(this.weather);

  @override
  List<Object> get props => [weather];
}
