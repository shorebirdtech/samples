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

  String get displayName => [name, admin1, country].where((e) => e != null && e.toString().isNotEmpty).join(', ');

  @override
  List<Object?> get props => [name, admin1, country, latitude, longitude];
}
