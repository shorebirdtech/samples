import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/core/widgets/widgets.dart';

/// Animates a small copy of the product from [from] into [to], along an arc.
Future<void> flyToCart({
  required BuildContext context,
  required GlobalKey from,
  required GlobalKey to,
  required String icon,
  required Color color,
}) async {
  if (Motion.reduced(context)) return;
  final overlay = Overlay.of(context);
  final fromBox = from.currentContext?.findRenderObject() as RenderBox?;
  final toBox = to.currentContext?.findRenderObject() as RenderBox?;
  if (fromBox == null || toBox == null) return;
  final start = fromBox.localToGlobal(fromBox.size.center(Offset.zero));
  final end = toBox.localToGlobal(toBox.size.center(Offset.zero));

  final completer = Completer<void>();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _Flight(
      start: start,
      end: end,
      icon: icon,
      color: color,
      onDone: () {
        entry.remove();
        completer.complete();
      },
    ),
  );
  overlay.insert(entry);
  await completer.future;
}

class _Flight extends StatefulWidget {
  const _Flight({
    required this.start,
    required this.end,
    required this.icon,
    required this.color,
    required this.onDone,
  });

  final Offset start;
  final Offset end;
  final String icon;
  final Color color;
  final VoidCallback onDone;

  @override
  State<_Flight> createState() => _FlightState();
}

class _FlightState extends State<_Flight> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  )..forward().whenComplete(widget.onDone);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = Curves.easeInCubic.transform(_controller.value);
              // Quadratic Bézier with the control point lifted above both ends.
              final control = Offset(
                (widget.start.dx + widget.end.dx) / 2,
                widget.end.dy - 160,
              );
              final p =
                  widget.start * ((1 - t) * (1 - t)) +
                  control * (2 * (1 - t) * t) +
                  widget.end * (t * t);
              final size = 72 * (1 - t * 0.75);
              return Positioned(
                left: p.dx - size / 2,
                top: p.dy - size / 2,
                width: size,
                height: size,
                child: Opacity(opacity: 1 - t * 0.3, child: child),
              );
            },
            child: Material(
              type: MaterialType.transparency,
              elevation: 12,
              child: ProductArt(
                icon: widget.icon,
                color: widget.color,
                borderRadius: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
