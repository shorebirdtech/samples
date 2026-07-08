import 'package:clear_skies/logic/bloc/bloc.dart';

class WeatherError extends WeatherState {
  final String message;

  const WeatherError(this.message);

  @override
  List<Object> get props => [message];
}
