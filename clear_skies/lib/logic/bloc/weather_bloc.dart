import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clear_skies/data/repositories/repositories.dart';
import 'package:clear_skies/logic/bloc/bloc.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc({required this.weatherRepository}) : super(WeatherInitial()) {
    on<WeatherRequested>(_onWeatherRequested);
    on<WeatherLocationRequested>(_onWeatherLocationRequested);
  }

  Future<void> _onWeatherRequested(WeatherRequested event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    try {
      final weather = await weatherRepository.getWeather(event.cityName);
      emit(WeatherLoaded(weather));
    } catch (e) {
      emit(WeatherError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onWeatherLocationRequested(WeatherLocationRequested event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    try {
      final weather = await weatherRepository.getWeatherByCoordinates(
        event.latitude, 
        event.longitude, 
        event.cityName,
      );
      emit(WeatherLoaded(weather));
    } catch (e) {
      emit(WeatherError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
