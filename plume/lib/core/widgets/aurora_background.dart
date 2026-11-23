import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:plume/core/theme/motion.dart';

/// A solid surface with one faint drifting light, used behind onboarding and
/// hero cards. Only the first of [colors] is painted.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({
    required this.colors,
    this.child,
    this.period = const Duration(seconds: 14),
    super.key,
  });

  final List<Color> colors;
  final Widget? child;
  final Duration period;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
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
    return CustomPaint(
      painter: _AuroraPainter(_controller, widget.colors),
      child: widget.child,
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter(this.animation, this.colors) : super(repaint: animation);

  final Animation<double> animation;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.first);
    // One faint, slow-moving light keeps the surface from feeling static
    // without adding colour.
    final t = animation.value * 2 * math.pi;
    final center = Offset(
      size.width * (0.5 + 0.3 * math.cos(t)),
      size.height * (0.3 + 0.15 * math.sin(t)),
    );
    final radius = size.longestSide * 0.6;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.06),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(_AuroraPainter oldDelegate) =>
      oldDelegate.colors != colors;
}
