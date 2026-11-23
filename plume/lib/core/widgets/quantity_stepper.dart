import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/l10n/l10n.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 10,
    this.compact = false,
    super.key,
  });

  final int value;
  final int min;
  final int max;
  final bool compact;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = compact ? 32.0 : 44.0;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(size),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            size: size,
            tooltip: context.l10n.decreaseQuantity,
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: compact ? 26 : 34,
            child: AnimatedSwitcher(
              duration: Motion.of(context, Motion.fast),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Text(
                '$value',
                key: ValueKey(value),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            size: size,
            tooltip: context.l10n.increaseQuantity,
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.size,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final double size;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: IconButton(
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      iconSize: size * 0.5,
      onPressed: onPressed == null
          ? null
          : () {
              unawaited(HapticFeedback.lightImpact());
              onPressed!();
            },
      icon: Icon(icon),
    ),
  );
}
