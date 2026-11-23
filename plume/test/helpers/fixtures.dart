import 'package:flutter/painting.dart';
import 'package:plume/core/money.dart';
import 'package:plume/data/models/models.dart';

Product product({
  String id = 'p1',
  int priceCents = 2500,
  int? compareAtCents,
  List<String> tags = const [],
  String categoryId = 'audio',
}) => Product(
  id: id,
  name: 'Product $id',
  brand: 'Brand',
  categoryId: categoryId,
  price: Money.cents(priceCents),
  compareAtPrice: compareAtCents == null ? null : Money.cents(compareAtCents),
  icon: 'headphones',
  colors: const [
    ProductColor(name: 'Ink', color: Color(0xFF111111)),
    ProductColor(name: 'Sand', color: Color(0xFFDDCCAA)),
  ],
  description: 'A product.',
  highlights: const ['Great'],
  rating: 4.5,
  reviewCount: 10,
  stock: 20,
  tags: tags,
);

CartItem item(Product product, {int quantity = 1, String color = 'Ink'}) =>
    CartItem(product: product, colorName: color, quantity: quantity);

const save10 = Promotion(
  code: 'SAVE10',
  kind: PromotionKind.fixed,
  amount: 10,
  minSubtotal: 50,
  description: r'$10 off orders over $50',
);

const welcome15 = Promotion(
  code: 'WELCOME15',
  kind: PromotionKind.percent,
  amount: 15,
  minSubtotal: 0,
  description: '15% off',
);

const freeShip = Promotion(
  code: 'FREESHIP',
  kind: PromotionKind.shipping,
  amount: 0,
  minSubtotal: 0,
  description: 'Free shipping',
);

const address = Address(
  fullName: 'Ada Lovelace',
  line1: '1 Analytical Way',
  city: 'London',
  postalCode: 'N1',
  country: 'United Kingdom',
);
