import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/game/game.dart';

/// Represents a racer/participant inside a lobby.
class LobbyPlayer extends Equatable {
  final String id;
  final String name;
  final PlayerSkin skin;
  final bool isReady;
  final int score;
  final int patches;
  final int level;
  final bool isAlive;

  const LobbyPlayer({
    required this.id,
    required this.name,
    required this.skin,
    this.isReady = false,
    this.score = 0,
    this.patches = 0,
    this.level = 1,
    this.isAlive = true,
  });

  factory LobbyPlayer.fromJson(Map<String, dynamic> json) {
    final skinStr = json['skin'] as String? ?? 'blueBird';
    final skin = PlayerSkin.values.firstWhere(
      (s) => s.name == skinStr,
      orElse: () => PlayerSkin.blueBird,
    );
    return LobbyPlayer(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Pilot',
      skin: skin,
      isReady: json['isReady'] as bool? ?? false,
      score: (json['score'] as num? ?? 0).toInt(),
      patches: (json['patches'] as num? ?? 0).toInt(),
      level: (json['level'] as num? ?? 1).toInt(),
      isAlive: json['isAlive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'skin': skin.name,
        'isReady': isReady,
        'score': score,
        'patches': patches,
        'level': level,
        'isAlive': isAlive,
      };

  @override
  List<Object?> get props =>
      [id, name, skin, isReady, score, patches, level, isAlive];
}
