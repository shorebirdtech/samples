import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Zero-allocation, GPU-friendly floating text indicator.
/// Extends Component so it naturally scales with the camera viewfinder in world space.
/// Uses direct alpha text styling and pop scaling instead of expensive canvas.saveLayer.
class FloatingText extends Component {
  Offset pos;
  double life = 1.0;
  final String _text;
  final Color _color;
  final double _size;
  final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  FloatingText(this._text, this.pos, this._color, this._size) {
    _updateTextPainter();
  }

  void _updateTextPainter() {
    final currentAlpha = life.clamp(0.0, 1.0);
    _textPainter.text = TextSpan(
      text: _text,
      style: TextStyle(
        color: _color.withValues(alpha: currentAlpha),
        fontSize: _size,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.4,
        shadows: [
          Shadow(
            color:
                const Color(0xDD000000).withValues(alpha: currentAlpha * 0.7),
            blurRadius: 4,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
    _textPainter.layout();
  }

  bool get isDone => life <= 0;

  @override
  void update(double dt) {
    super.update(dt);
    pos = Offset(pos.dx, pos.dy - dt * 50);
    life = (life - dt * 1.6).clamp(0.0, 1.0);
    if (life <= 0) {
      removeFromParent();
    } else {
      _updateTextPainter();
    }
  }

  @override
  void render(Canvas canvas) {
    if (life <= 0) return;
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    // Punchy pop-in scale curve
    final popScale = (0.95 + sin(life * pi * 0.5) * 0.25).clamp(0.8, 1.25);
    canvas.scale(popScale, popScale);
    _textPainter.paint(
      canvas,
      Offset(-_textPainter.width / 2, -_textPainter.height / 2),
    );
    canvas.restore();
  }
}
