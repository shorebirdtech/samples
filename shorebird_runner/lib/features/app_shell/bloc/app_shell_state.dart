import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/features/app_shell/bloc/app_mode.dart';
import 'package:shorebird_runner/features/tournament_lobby/models/models.dart';

class AppShellState extends Equatable {
  final AppMode mode;
  final List<RacerStanding> podiumRankings;

  const AppShellState({
    this.mode = AppMode.menu,
    this.podiumRankings = const [],
  });

  AppShellState copyWith({
    AppMode? mode,
    List<RacerStanding>? podiumRankings,
  }) {
    return AppShellState(
      mode: mode ?? this.mode,
      podiumRankings: podiumRankings ?? this.podiumRankings,
    );
  }

  @override
  List<Object?> get props => [mode, podiumRankings];
}
