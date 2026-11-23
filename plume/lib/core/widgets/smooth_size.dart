import 'package:flutter/widgets.dart';
import 'package:plume/core/theme/motion.dart';

/// [AnimatedSize] that steps aside when the user prefers reduced motion,
/// since a zero-duration [AnimatedSize] re-dirties its own layout.
class SmoothSize extends StatelessWidget {
  const SmoothSize({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return child;
    return AnimatedSize(
      duration: Motion.medium,
      curve: Motion.emphasized,
      alignment: Alignment.topCenter,
      child: child,
    );
  }
}
