import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoritesEvent {}

class AddFavorite extends FavoritesEvent {
  final String cityName;

  const AddFavorite(this.cityName);

  @override
  List<Object?> get props => [cityName];
}

class RemoveFavorite extends FavoritesEvent {
  final String cityName;

  const RemoveFavorite(this.cityName);

  @override
  List<Object?> get props => [cityName];
}
