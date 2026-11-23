import 'package:material_ui/material_ui.dart';
import 'package:plume/core/theme/palette.dart';

/// The Plume mark: a feather on a brand-gradient tile.
class PlumeLogo extends StatelessWidget {
  const PlumeLogo({this.size = 72, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: Palette.brandGradient,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: const CustomPaint(painter: PlumeFeatherPainter()),
    );
  }
}

/// Draws the Plume feather, scaled to fill its canvas. Shared by the in-app
/// logo and the launcher icon generator.
class PlumeFeatherPainter extends CustomPainter {
  const PlumeFeatherPainter();

  static const _vane = Color(0xFFF7F7F5);
  static const _shaft = Color(0xFFC9CCD3);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final vane = Path()
      ..moveTo(w * 0.28, h * 0.78)
      ..cubicTo(w * 0.22, h * 0.48, w * 0.42, h * 0.22, w * 0.74, h * 0.2)
      ..cubicTo(w * 0.78, h * 0.48, w * 0.58, h * 0.72, w * 0.28, h * 0.78)
      ..close();
    canvas.drawPath(vane, Paint()..color = _vane);
    // Barbs on both sides of the quill, swept towards the tip and clipped to
    // the vane so they read as its texture.
    final barbs = Paint()
      ..color = _shaft
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.022;
    const along = Offset(0.637, -0.77);
    const across = Offset(0.77, 0.637);
    canvas
      ..save()
      ..clipPath(vane);
    for (var i = 1; i <= 4; i++) {
      final t = i / 5;
      final start = Offset(w * (0.22 + 0.48 * t), h * (0.84 - 0.58 * t));
      for (final side in const [1.0, -1.0]) {
        final reach = across * side * 0.12 + along * 0.12;
        canvas.drawLine(
          start,
          start + Offset(w * reach.dx, h * reach.dy),
          barbs,
        );
      }
    }
    canvas.restore();
    final quill = Path()
      ..moveTo(w * 0.22, h * 0.84)
      ..quadraticBezierTo(w * 0.46, h * 0.56, w * 0.7, h * 0.26);
    // The stem shows white against the tile; inside the vane the shaft is a
    // fine grey line.
    canvas
      ..drawPath(
        quill,
        Paint()
          ..color = _vane
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = w * 0.04,
      )
      ..save()
      ..clipPath(vane)
      ..drawPath(
        quill,
        Paint()
          ..color = _shaft
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = w * 0.018,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(PlumeFeatherPainter oldDelegate) => false;
}
