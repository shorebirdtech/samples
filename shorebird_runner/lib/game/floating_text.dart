import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Zero-allocation, cached floating text indicator.
/// Extends Component so it naturally scales with the camera viewfinder in world space.
class FloatingText extends Component {
  Offset pos;
  double life = 1.0;
  final TextPainter textPainter;

  FloatingText(String text, this.pos, Color color, double size)
      : textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              color: color,
              fontSize: size,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
              shadows: const [
                Shadow(
                  color: Color(0xDD000000),
                  blurRadius: 4,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

  bool get isDone => life <= 0;

  @override
  void update(double dt) {
    super.update(dt);
    pos = Offset(pos.dx, pos.dy - dt * 45);
    life = (life - dt * 1.5).clamp(0.0, 1.0);
    if (life <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (life <= 0) return;
    final paintOffset = Offset(pos.dx - textPainter.width / 2, pos.dy);
    if (life >= 0.9) {
      textPainter.paint(canvas, paintOffset);
    } else {
      // Fade out cleanly without layout recalculation
      canvas.saveLayer(
        Rect.fromLTWH(paintOffset.dx - 8, paintOffset.dy - 4,
            textPainter.width + 16, textPainter.height + 8),
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: life),
      );
      textPainter.paint(canvas, paintOffset);
      canvas.restore();
    }
  }
}
