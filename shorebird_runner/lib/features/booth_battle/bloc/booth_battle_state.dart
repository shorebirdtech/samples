import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/game/game.dart';

class BoothBattleState extends Equatable {
  final int p1Score;
  final int p1Patches;
  final LevelConfig p1Level;
  final bool p1Crashed;

  final int p2Score;
  final int p2Patches;
  final LevelConfig p2Level;
  final bool p2Crashed;

  BoothBattleState({
    this.p1Score = 0,
    this.p1Patches = 0,
    LevelConfig? p1Level,
    this.p1Crashed = false,
    this.p2Score = 0,
    this.p2Patches = 0,
    LevelConfig? p2Level,
    this.p2Crashed = false,
  })  : p1Level = p1Level ?? GameConfig.levels.first,
        p2Level = p2Level ?? GameConfig.levels.first;

  bool get isMatchOver => p1Crashed && p2Crashed;

  BoothBattleState copyWith({
    int? p1Score,
    int? p1Patches,
    LevelConfig? p1Level,
    bool? p1Crashed,
    int? p2Score,
    int? p2Patches,
    LevelConfig? p2Level,
    bool? p2Crashed,
  }) {
    return BoothBattleState(
      p1Score: p1Score ?? this.p1Score,
      p1Patches: p1Patches ?? this.p1Patches,
      p1Level: p1Level ?? this.p1Level,
      p1Crashed: p1Crashed ?? this.p1Crashed,
      p2Score: p2Score ?? this.p2Score,
      p2Patches: p2Patches ?? this.p2Patches,
      p2Level: p2Level ?? this.p2Level,
      p2Crashed: p2Crashed ?? this.p2Crashed,
    );
  }

  @override
  List<Object?> get props => [
        p1Score,
        p1Patches,
        p1Level,
        p1Crashed,
        p2Score,
        p2Patches,
        p2Level,
        p2Crashed,
      ];
}
