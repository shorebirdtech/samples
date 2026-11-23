import 'package:equatable/equatable.dart';
import 'package:plume/core/money.dart';
import 'package:plume/data/models/product.dart';

class CartItem extends Equatable {
  const CartItem({
    required this.product,
    required this.colorName,
    required this.quantity,
  });

  final Product product;
  final String colorName;
  final int quantity;

  /// Identifies a line: the same product in two colours is two lines.
  String get key => '${product.id}::$colorName';

  Money get lineTotal => product.price * quantity;

  ProductColor get color => product.colors.firstWhere(
    (c) => c.name == colorName,
    orElse: () => product.colors.first,
  );

  CartItem copyWith({int? quantity}) => CartItem(
    product: product,
    colorName: colorName,
    quantity: quantity ?? this.quantity,
  );

  Map<String, dynamic> toJson() => {
    'productId': product.id,
    'colorName': colorName,
    'quantity': quantity,
  };

  @override
  List<Object> get props => [product, colorName, quantity];
}
