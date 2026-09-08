import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/game/utils/level_config.dart';

abstract class SoloRunnerEvent extends Equatable {
  const SoloRunnerEvent();

  @override
  List<Object?> get props => [];
}

class StartSoloGame extends SoloRunnerEvent {
  const StartSoloGame();
}

class RestartSoloGame extends SoloRunnerEvent {
  const RestartSoloGame();
}

class SoloGameOver extends SoloRunnerEvent {
  final int score;
  final int patches;
  final LevelConfig level;

  const SoloGameOver({
    required this.score,
    required this.patches,
    required this.level,
  });

  @override
  List<Object?> get props => [score, patches, level];
}
