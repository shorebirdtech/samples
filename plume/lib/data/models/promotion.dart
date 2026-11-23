import 'package:equatable/equatable.dart';

enum PromotionKind { fixed, percent, shipping }

/// A promo code as returned by the promotions service.
///
/// Amounts follow the service's contract: [amount] is in major currency
/// units (dollars) for [PromotionKind.fixed] and a percentage for
/// [PromotionKind.percent]. [minSubtotal] is in dollars.
class Promotion extends Equatable {
  const Promotion({
    required this.code,
    required this.kind,
    required this.amount,
    required this.minSubtotal,
    required this.description,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
    code: json['code'] as String,
    kind: PromotionKind.values.byName(json['kind'] as String),
    amount: json['amount'] as num,
    minSubtotal: json['minSubtotal'] as num,
    description: json['description'] as String,
  );

  final String code;
  final PromotionKind kind;
  final num amount;
  final num minSubtotal;
  final String description;

  Map<String, dynamic> toJson() => {
    'code': code,
    'kind': kind.name,
    'amount': amount,
    'minSubtotal': minSubtotal,
    'description': description,
  };

  @override
  List<Object> get props => [code];
}
