import 'package:equatable/equatable.dart';

/// The shopper. Plume has no sign-in: everyone shops as the demo shopper.
class User extends Equatable {
  const User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
  );

  static const demo = User(
    id: 'demo',
    name: 'Alex Morgan',
    email: 'alex.morgan@example.com',
  );

  final String id;
  final String name;
  final String email;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join().toUpperCase();
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};

  @override
  List<Object> get props => [id, name, email];
}
