import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/game/game.dart';

abstract class BoothBattleEvent extends Equatable {
  const BoothBattleEvent();

  @override
  List<Object?> get props => [];
}

class UpdateP1Score extends BoothBattleEvent {
  final int score;
  final int patches;
  final LevelConfig level;
  final bool isAlive;

  const UpdateP1Score({
    required this.score,
    required this.patches,
    required this.level,
    required this.isAlive,
  });

  @override
  List<Object?> get props => [score, patches, level, isAlive];
}

class UpdateP2Score extends BoothBattleEvent {
  final int score;
  final int patches;
  final LevelConfig level;
  final bool isAlive;

  const UpdateP2Score({
    required this.score,
    required this.patches,
    required this.level,
    required this.isAlive,
  });

  @override
  List<Object?> get props => [score, patches, level, isAlive];
}

class RestartBoothBattle extends BoothBattleEvent {
  const RestartBoothBattle();
}
