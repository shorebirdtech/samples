import 'package:material_ui/material_ui.dart';
import 'package:plume/core/theme/motion.dart';

/// A shimmering placeholder shown while content loads.
class Skeleton extends StatefulWidget {
  const Skeleton({this.width, this.height, this.radius = 20, super.key});

  final double? width;
  final double? height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!Motion.reduced(context) && !_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainer;
    final highlight = Color.lerp(base, Colors.white, 0.18)!;
    return Semantics(
      label: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final x = _controller.value * 3 - 1.5;
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              gradient: LinearGradient(
                begin: Alignment(x - 1, -0.3),
                end: Alignment(x + 1, 0.3),
                colors: [base, highlight, base],
              ),
            ),
          );
        },
      ),
    );
  }
}
