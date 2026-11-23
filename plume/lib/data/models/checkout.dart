import 'package:equatable/equatable.dart';
import 'package:plume/core/money.dart';

class Address extends Equatable {
  const Address({
    required this.fullName,
    required this.line1,
    required this.city,
    required this.postalCode,
    required this.country,
    this.line2 = '',
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    fullName: json['fullName'] as String,
    line1: json['line1'] as String,
    line2: json['line2'] as String? ?? '',
    city: json['city'] as String,
    postalCode: json['postalCode'] as String,
    country: json['country'] as String,
  );

  final String fullName;
  final String line1;
  final String line2;
  final String city;
  final String postalCode;
  final String country;

  String get singleLine => [
    line1,
    if (line2.isNotEmpty) line2,
    '$city $postalCode',
    country,
  ].join(', ');

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'line1': line1,
    'line2': line2,
    'city': city,
    'postalCode': postalCode,
    'country': country,
  };

  @override
  List<Object> get props => [fullName, line1, line2, city, postalCode, country];
}

enum ShippingMethod {
  standard(days: 5, priceCents: 599),
  express(days: 2, priceCents: 1499);

  ShippingMethod({required this.days, required this.priceCents});

  final int days;
  final int priceCents;

  Money get price => Money.cents(priceCents);
}

class PaymentCard extends Equatable {
  const PaymentCard({
    required this.holder,
    required this.number,
    required this.expiry,
  });

  final String holder;
  final String number;
  final String expiry;

  String get digits => number.replaceAll(RegExp(r'\D'), '');
  String get last4 =>
      digits.length >= 4 ? digits.substring(digits.length - 4) : digits;

  CardBrand get brand => CardBrand.detect(digits);

  @override
  List<Object> get props => [holder, number, expiry];
}

enum CardBrand {
  visa('Visa'),
  mastercard('Mastercard'),
  amex('Amex'),
  unknown('Card');

  CardBrand(this.label);

  final String label;

  static CardBrand detect(String digits) {
    if (digits.startsWith('4')) return visa;
    if (RegExp('^(5[1-5]|2[2-7])').hasMatch(digits)) return mastercard;
    if (RegExp('^3[47]').hasMatch(digits)) return amex;
    return unknown;
  }
}
