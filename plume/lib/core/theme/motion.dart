import 'package:flutter/widgets.dart';

/// Durations and curves used across the app so motion feels consistent.
abstract final class Motion {
  static const fast = Duration(milliseconds: 180);
  static const medium = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 560);
  static const page = Duration(milliseconds: 420);

  static const Cubic emphasized = Curves.easeOutCubic;
  static const ElasticOutCurve spring = Curves.elasticOut;
  static const Cubic standard = Curves.easeInOutCubic;

  /// Whether the user asked the OS to reduce motion.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Returns [duration], or zero when the user prefers reduced motion.
  static Duration of(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}
