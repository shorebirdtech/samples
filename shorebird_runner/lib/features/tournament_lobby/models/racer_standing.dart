import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/game/game.dart';

/// Real-time standing item in the live leaderboard.
class RacerStanding extends Equatable {
  final int rank;
  final String id;
  final String name;
  final PlayerSkin skin;
  final int score;
  final int patches;
  final int level;
  final bool isAlive;

  const RacerStanding({
    required this.rank,
    required this.id,
    required this.name,
    required this.skin,
    required this.score,
    required this.patches,
    required this.level,
    this.isAlive = true,
  });

  factory RacerStanding.fromJson(Map<String, dynamic> json, int defaultRank) {
    final skinStr = json['skin'] as String? ?? 'blueBird';
    final skin = PlayerSkin.values.firstWhere(
      (s) => s.name == skinStr,
      orElse: () => PlayerSkin.blueBird,
    );
    return RacerStanding(
      rank: (json['rank'] as num? ?? defaultRank).toInt(),
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Pilot',
      skin: skin,
      score: (json['score'] as num? ?? 0).toInt(),
      patches: (json['patches'] as num? ?? 0).toInt(),
      level: (json['level'] as num? ?? 1).toInt(),
      isAlive: json['isAlive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'id': id,
        'name': name,
        'skin': skin.name,
        'score': score,
        'patches': patches,
        'level': level,
        'isAlive': isAlive,
      };

  @override
  List<Object?> get props =>
      [rank, id, name, skin, score, patches, level, isAlive];
}
