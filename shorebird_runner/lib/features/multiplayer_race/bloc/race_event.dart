import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/features/tournament_lobby/models/models.dart';

abstract class RaceEvent extends Equatable {
  const RaceEvent();

  @override
  List<Object?> get props => [];
}

class UpdateRacerScore extends RaceEvent {
  final int score;
  final int patches;
  final int level;
  final bool isAlive;

  const UpdateRacerScore({
    required this.score,
    required this.patches,
    required this.level,
    required this.isAlive,
  });

  @override
  List<Object?> get props => [score, patches, level, isAlive];
}

class StandingsUpdated extends RaceEvent {
  final List<RacerStanding> standings;

  const StandingsUpdated(this.standings);

  @override
  List<Object?> get props => [standings];
}

class MatchFinishedReceived extends RaceEvent {
  final List<RacerStanding> rankings;

  const MatchFinishedReceived(this.rankings);

  @override
  List<Object?> get props => [rankings];
}

class PlayerCrashedEvent extends RaceEvent {
  final int finalScore;
  final int finalPatches;

  const PlayerCrashedEvent({
    required this.finalScore,
    required this.finalPatches,
  });

  @override
  List<Object?> get props => [finalScore, finalPatches];
}
