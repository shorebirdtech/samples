import 'package:equatable/equatable.dart';
import 'package:clear_skies/data/models/models.dart';

enum FavoritesStatus { initial, loading, loaded, error }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<Weather> favorites;
  final String? errorMessage;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const [],
    this.errorMessage,
  });

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<Weather>? favorites,
    String? errorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, favorites, errorMessage];
}
