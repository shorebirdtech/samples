import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/features/app_shell/bloc/app_mode.dart';
import 'package:shorebird_runner/features/tournament_lobby/models/models.dart';

abstract class AppShellEvent extends Equatable {
  const AppShellEvent();

  @override
  List<Object?> get props => [];
}

class NavigateToMode extends AppShellEvent {
  final AppMode mode;
  final List<RacerStanding>? podiumRankings;

  const NavigateToMode(this.mode, {this.podiumRankings});

  @override
  List<Object?> get props => [mode, podiumRankings];
}

class AppRematchTriggered extends AppShellEvent {
  const AppRematchTriggered();
}
