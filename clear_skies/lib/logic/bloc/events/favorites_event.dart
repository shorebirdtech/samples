import 'package:clear_skies/data/models/models.dart';
import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoritesEvent {}

class AddFavorite extends FavoritesEvent {
  final Weather weather;

  const AddFavorite(this.weather);

  @override
  List<Object?> get props => [weather];
}

class RemoveFavorite extends FavoritesEvent {
  final String cityName;

  const RemoveFavorite(this.cityName);

  @override
  List<Object?> get props => [cityName];
}
