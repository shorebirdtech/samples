import 'package:material_ui/material_ui.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/core/widgets/widgets.dart';

/// Product art that tilts in 3D under the user's finger and springs back.
class TiltArt extends StatefulWidget {
  const TiltArt({required this.icon, required this.color, super.key});

  final String icon;
  final Color color;

  @override
  State<TiltArt> createState() => _TiltArtState();
}

class _TiltArtState extends State<TiltArt> with SingleTickerProviderStateMixin {
  Offset _tilt = Offset.zero;
  late final _spring = AnimationController.unbounded(vsync: this);
  Offset _releaseFrom = Offset.zero;

  @override
  void initState() {
    super.initState();
    _spring.addListener(() {
      setState(
        () => _tilt = Offset.lerp(_releaseFrom, Offset.zero, _spring.value)!,
      );
    });
  }

  @override
  void dispose() {
    _spring.dispose();
    super.dispose();
  }

  void _update(Offset local, Size size) {
    _spring.stop();
    final dx = (local.dx / size.width - 0.5) * 2;
    final dy = (local.dy / size.height - 0.5) * 2;
    setState(() => _tilt = Offset(dx.clamp(-1.0, 1.0), dy.clamp(-1.0, 1.0)));
  }

  void _release() {
    _releaseFrom = _tilt;
    _spring
      ..value = 0
      ..animateTo(1, duration: Motion.slow, curve: Motion.spring);
  }

  @override
  Widget build(BuildContext context) {
    final reduced = Motion.reduced(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return GestureDetector(
          onPanStart: reduced ? null : (d) => _update(d.localPosition, size),
          onPanUpdate: reduced ? null : (d) => _update(d.localPosition, size),
          onPanEnd: reduced ? null : (_) => _release(),
          onPanCancel: reduced ? null : _release,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateX(-_tilt.dy * 0.28)
              ..rotateY(_tilt.dx * 0.28),
            child: AnimatedSwitcher(
              duration: Motion.of(context, Motion.medium),
              child: ProductArt(
                key: ValueKey(widget.color),
                icon: widget.icon,
                color: widget.color,
                borderRadius: 40,
                iconScale: 0.5,
                tilt: _tilt.dx,
              ),
            ),
          ),
        );
      },
    );
  }
}
