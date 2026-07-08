import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clear_skies/features/features.dart';

export 'favorites_event.dart';
export 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final WeatherRepository weatherRepository;
  final FavoritesRepository favoritesRepository;

  FavoritesBloc({
    required this.weatherRepository,
    required this.favoritesRepository,
  }) : super(const FavoritesState()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddFavorite>(_onAddFavorite);
    on<RemoveFavorite>(_onRemoveFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(status: FavoritesStatus.loading));
    try {
      final favoriteCities = await favoritesRepository.getFavorites();
      final List<Weather> loadedFavorites = [];
      for (final city in favoriteCities) {
        try {
          final weather = await weatherRepository.getWeather(city);
          loadedFavorites.add(weather);
        } catch (_) {
          // If one fails, skip it
        }
      }
      emit(
        state.copyWith(
          status: FavoritesStatus.loaded,
          favorites: loadedFavorites,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FavoritesStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddFavorite(
    AddFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final favoriteCities = await favoritesRepository.getFavorites();
      final cityName = event.weather.cityName;
      if (!favoriteCities.contains(cityName)) {
        favoriteCities.add(cityName);

        if (state.status == FavoritesStatus.loaded) {
          final currentFavorites = state.favorites;
          emit(state.copyWith(favorites: [...currentFavorites, event.weather]));
        } else {
          add(LoadFavorites());
        }

        await favoritesRepository.saveFavorites(favoriteCities);
      }
    } catch (_) {}
  }

  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final favoriteCities = await favoritesRepository.getFavorites();
      if (favoriteCities.contains(event.cityName)) {
        favoriteCities.remove(event.cityName);

        if (state.status == FavoritesStatus.loaded) {
          final currentFavorites = state.favorites;
          final updatedFavorites = currentFavorites
              .where((w) => w.cityName != event.cityName)
              .toList();
          emit(state.copyWith(favorites: updatedFavorites));
        } else {
          add(LoadFavorites());
        }

        await favoritesRepository.saveFavorites(favoriteCities);
      }
    } catch (_) {}
  }
}
