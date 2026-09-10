import 'package:equatable/equatable.dart';

/// Represents a developer lead captured before starting the game.
class LeadModel extends Equatable {
  final String event;
  final String name;
  final String email;
  final String phone;
  final String organization;
  final DateTime createdAt;

  const LeadModel({
    this.event = '',
    required this.name,
    required this.email,
    required this.phone,
    required this.organization,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'event': event.trim(),
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'organization': organization.trim(),
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      event: json['event'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      organization: json['organization'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Formatted player tag to show in game HUD, e.g. "Abhishek @ Shorebird"
  String get playerTag {
    if (name.isEmpty) return 'DEVELOPER';
    final firstName = name.split(' ').first;
    if (organization.isNotEmpty) {
      return '$firstName @ $organization';
    }
    return firstName.toUpperCase();
  }

  @override
  List<Object?> get props => [
        event,
        name,
        email,
        phone,
        organization,
        createdAt,
      ];
}
