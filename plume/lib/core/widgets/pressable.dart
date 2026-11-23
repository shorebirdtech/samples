import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/core/theme/motion.dart';

/// Shrinks slightly while pressed, giving cards a tactile feel.
class Pressable extends StatefulWidget {
  const Pressable({
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.haptic = true,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _set(bool pressed) {
    if (widget.onTap == null || _pressed == pressed) return;
    setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapCancel: () => _set(false),
        onTapUp: (_) => _set(false),
        onTap: widget.onTap == null
            ? null
            : () {
                if (widget.haptic) unawaited(HapticFeedback.selectionClick());
                widget.onTap!();
              },
        child: AnimatedScale(
          scale: _pressed ? widget.scale : 1,
          duration: Motion.of(context, Motion.fast),
          curve: Motion.emphasized,
          child: widget.child,
        ),
      ),
    );
  }
}
