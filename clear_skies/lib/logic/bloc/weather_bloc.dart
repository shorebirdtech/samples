import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clear_skies/data/repositories/repositories.dart';
import 'package:clear_skies/logic/bloc/bloc.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc({required this.weatherRepository}) : super(const WeatherState()) {
    on<WeatherRequested>(_onWeatherRequested);
    on<WeatherLocationRequested>(_onWeatherLocationRequested);
    on<ResetWeather>((event, emit) => emit(const WeatherState()));
  }

  Future<void> _onWeatherRequested(
    WeatherRequested event,
    Emitter<WeatherState> emit,
  ) async {
    emit(state.copyWith(status: WeatherStatus.loading));
    try {
      final weather = await weatherRepository.getWeather(event.cityName);
      emit(state.copyWith(status: WeatherStatus.loaded, weather: weather));
    } catch (e) {
      emit(state.copyWith(
        status: WeatherStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onWeatherLocationRequested(
    WeatherLocationRequested event,
    Emitter<WeatherState> emit,
  ) async {
    emit(state.copyWith(status: WeatherStatus.loading));
    try {
      final weather = await weatherRepository.getWeatherByCoordinates(
        event.latitude,
        event.longitude,
        event.cityName,
      );
      emit(state.copyWith(status: WeatherStatus.loaded, weather: weather));
    } catch (e) {
      emit(state.copyWith(
        status: WeatherStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
