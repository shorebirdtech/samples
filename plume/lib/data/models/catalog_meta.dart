import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';
import 'package:plume/core/theme/palette.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: json['icon'] as String,
    color: Palette.fromHex(json['color'] as String),
  );

  final String id;
  final String name;
  final String icon;
  final Color color;

  @override
  List<Object> get props => [id];
}

class Collection extends Equatable {
  const Collection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.icon,
    required this.productIds,
  });

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
    id: json['id'] as String,
    title: json['title'] as String,
    subtitle: json['subtitle'] as String,
    colors: (json['colors'] as List<dynamic>)
        .map((e) => Palette.fromHex(e as String))
        .toList(),
    icon: json['icon'] as String,
    productIds: (json['productIds'] as List<dynamic>).cast<String>(),
  );

  final String id;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final String icon;
  final List<String> productIds;

  @override
  List<Object> get props => [id];
}

class Review extends Equatable {
  const Review({
    required this.id,
    required this.productId,
    required this.author,
    required this.rating,
    required this.title,
    required this.body,
    required this.daysAgo,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'] as String,
    productId: json['productId'] as String,
    author: json['author'] as String,
    rating: json['rating'] as int,
    title: json['title'] as String,
    body: json['body'] as String,
    daysAgo: json['daysAgo'] as int,
  );

  final String id;
  final String productId;
  final String author;
  final int rating;
  final String title;
  final String body;
  final int daysAgo;

  @override
  List<Object> get props => [id];
}
