import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/features/solo_runner/bloc/solo_game_status.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';
import 'package:shorebird_runner/game/utils/level_config.dart';

class SoloRunnerState extends Equatable {
  final SoloGameStatus status;
  final int score;
  final int highScore;
  final int patches;
  final LevelConfig level;
  final bool isNewRecord;

  SoloRunnerState({
    this.status = SoloGameStatus.initial,
    this.score = 0,
    this.highScore = 0,
    this.patches = 0,
    LevelConfig? level,
    this.isNewRecord = false,
  }) : level = level ?? GameConfig.levels.first;

  SoloRunnerState copyWith({
    SoloGameStatus? status,
    int? score,
    int? highScore,
    int? patches,
    LevelConfig? level,
    bool? isNewRecord,
  }) {
    return SoloRunnerState(
      status: status ?? this.status,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      patches: patches ?? this.patches,
      level: level ?? this.level,
      isNewRecord: isNewRecord ?? this.isNewRecord,
    );
  }

  @override
  List<Object?> get props =>
      [status, score, highScore, patches, level, isNewRecord];
}
