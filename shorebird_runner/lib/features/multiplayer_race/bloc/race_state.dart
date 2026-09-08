import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/features/tournament_lobby/models/models.dart';

class RaceState extends Equatable {
  final List<RacerStanding> standings;
  final bool isAlive;
  final bool hasCrashed;
  final int finalScore;
  final int finalPatches;
  final List<RacerStanding>? finalRankings;

  const RaceState({
    this.standings = const [],
    this.isAlive = true,
    this.hasCrashed = false,
    this.finalScore = 0,
    this.finalPatches = 0,
    this.finalRankings,
  });

  RaceState copyWith({
    List<RacerStanding>? standings,
    bool? isAlive,
    bool? hasCrashed,
    int? finalScore,
    int? finalPatches,
    List<RacerStanding>? finalRankings,
  }) {
    return RaceState(
      standings: standings ?? this.standings,
      isAlive: isAlive ?? this.isAlive,
      hasCrashed: hasCrashed ?? this.hasCrashed,
      finalScore: finalScore ?? this.finalScore,
      finalPatches: finalPatches ?? this.finalPatches,
      finalRankings: finalRankings ?? this.finalRankings,
    );
  }

  @override
  List<Object?> get props => [
        standings,
        isAlive,
        hasCrashed,
        finalScore,
        finalPatches,
        finalRankings,
      ];
}
