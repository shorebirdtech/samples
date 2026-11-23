import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';
import 'package:plume/core/money.dart';
import 'package:plume/core/theme/palette.dart';

class ProductColor extends Equatable {
  const ProductColor({required this.name, required this.color});

  factory ProductColor.fromJson(Map<String, dynamic> json) => ProductColor(
    name: json['name'] as String,
    color: Palette.fromHex(json['hex'] as String),
  );

  final String name;
  final Color color;

  @override
  List<Object> get props => [name, color];
}

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.categoryId,
    required this.price,
    required this.icon,
    required this.colors,
    required this.description,
    required this.highlights,
    required this.rating,
    required this.reviewCount,
    required this.stock,
    this.compareAtPrice,
    this.sizes = const [],
    this.tags = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final compareAt = json['compareAtPriceCents'] as int?;
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      categoryId: json['categoryId'] as String,
      price: Money.cents(json['priceCents'] as int),
      compareAtPrice: compareAt == null ? null : Money.cents(compareAt),
      icon: json['icon'] as String,
      colors: (json['colors'] as List<dynamic>)
          .map((e) => ProductColor.fromJson(e as Map<String, dynamic>))
          .toList(),
      sizes: (json['sizes'] as List<dynamic>).cast<String>(),
      description: json['description'] as String,
      highlights: (json['highlights'] as List<dynamic>).cast<String>(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      stock: json['stock'] as int,
    );
  }

  final String id;
  final String name;
  final String brand;
  final String categoryId;
  final Money price;
  final Money? compareAtPrice;
  final String icon;
  final List<ProductColor> colors;
  final List<String> sizes;
  final String description;
  final List<String> highlights;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final int stock;

  bool get isOnSale => compareAtPrice != null && compareAtPrice! > price;
  bool get isNew => tags.contains('new');
  bool get isTrending => tags.contains('trending');
  bool get isBestseller => tags.contains('bestseller');

  int get discountPercent =>
      isOnSale ? ((1 - price.cents / compareAtPrice!.cents) * 100).round() : 0;

  @override
  List<Object?> get props => [id];
}
