import 'package:equatable/equatable.dart';

class CitySuggestion extends Equatable {
  final String name;
  final String? admin1;
  final String? country;
  final double latitude;
  final double longitude;

  const CitySuggestion({
    required this.name,
    this.admin1,
    this.country,
    required this.latitude,
    required this.longitude,
  });

  String get displayName => [
    name,
    admin1,
    country,
  ].where((e) => e != null && e.toString().isNotEmpty).join(', ');

  @override
  List<Object?> get props => [name, admin1, country, latitude, longitude];

  Map<String, dynamic> toJson() => {
        'name': name,
        'admin1': admin1,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory CitySuggestion.fromJson(Map<String, dynamic> json) {
    return CitySuggestion(
      name: json['name'] as String,
      admin1: json['admin1'] as String?,
      country: json['country'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
