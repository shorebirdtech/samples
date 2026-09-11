import 'package:equatable/equatable.dart';

/// Represents a single recorded score entry on the leaderboard.
class LeaderboardEntryModel extends Equatable {
  final int? id;
  final String playerName;
  final int score;
  final int patches;
  final String organization;
  final String event;
  final DateTime createdAt;

  const LeaderboardEntryModel({
    this.id,
    required this.playerName,
    required this.score,
    this.patches = 0,
    this.organization = '',
    this.event = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'player_name': playerName.trim(),
      'score': score,
      'patches': patches,
      'organization': organization.trim(),
      'event': event.trim(),
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      playerName: (json['player_name'] as String?)?.trim() ??
          (json['name'] as String?)?.trim() ??
          'Anonymous Runner',
      score: (json['score'] as num?)?.toInt() ?? 0,
      patches: (json['patches'] as num?)?.toInt() ?? 0,
      organization: (json['organization'] as String?)?.trim() ?? '',
      event: (json['event'] as String?)?.trim() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        playerName,
        score,
        patches,
        organization,
        event,
        createdAt,
      ];
}
