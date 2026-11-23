import 'package:material_ui/material_ui.dart';
import 'package:plume/core/theme/motion.dart';

/// Fades and slides its child in once, delayed by [index] for staggering.
class Entrance extends StatefulWidget {
  const Entrance({
    required this.child,
    this.index = 0,
    this.offset = const Offset(0, 0.12),
    this.stagger = const Duration(milliseconds: 55),
    this.duration = Motion.slow,
    super.key,
  });

  final Widget child;
  final int index;
  final Offset offset;
  final Duration stagger;
  final Duration duration;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: Motion.emphasized,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.status != AnimationStatus.dismissed) return;
    if (Motion.reduced(context)) {
      _controller.value = 1;
      return;
    }
    final delay = widget.stagger * widget.index.clamp(0, 12);
    Future<void>.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween(begin: widget.offset, end: Offset.zero).animate(_curve),
        child: widget.child,
      ),
    );
  }
}
