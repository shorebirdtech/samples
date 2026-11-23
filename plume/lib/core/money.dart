import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// An amount of money stored as integer cents to avoid floating point drift.
class Money extends Equatable implements Comparable<Money> {
  const Money.cents(this.cents);

  /// Builds an amount from major currency units (dollars).
  factory Money.fromMajor(num major) => Money.cents((major * 100).round());

  static const zero = Money.cents(0);

  final int cents;

  bool get isZero => cents == 0;
  bool get isNegative => cents < 0;

  Money operator +(Money other) => Money.cents(cents + other.cents);
  Money operator -(Money other) => Money.cents(cents - other.cents);
  Money operator *(int factor) => Money.cents(cents * factor);
  bool operator >(Money other) => cents > other.cents;
  bool operator >=(Money other) => cents >= other.cents;
  bool operator <(Money other) => cents < other.cents;

  /// Returns [percent] percent of this amount, rounded to the nearest cent.
  Money percentage(num percent) => Money.cents((cents * percent / 100).round());

  Money clamp(Money min, Money max) =>
      Money.cents(cents.clamp(min.cents, max.cents));

  String format([String? locale]) => NumberFormat.simpleCurrency(
    locale: locale,
    name: 'USD',
  ).format(cents / 100);

  @override
  int compareTo(Money other) => cents.compareTo(other.cents);

  @override
  List<Object> get props => [cents];

  @override
  String toString() => 'Money(${format('en_US')})';
}
