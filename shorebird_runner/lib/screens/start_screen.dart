import 'dart:math';
import 'package:flutter/material.dart';

/// Animated start screen with parallax stars, animated title,
/// and a glowing "TAP TO PLAY" prompt.
class StartScreen extends StatefulWidget {
  final VoidCallback onStartSolo;
  final VoidCallback onOpenLobby;

  const StartScreen({
    super.key,
    required this.onStartSolo,
    required this.onOpenLobby,
  });

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _pulse;
  late Animation<double> _float;
  late Animation<double> _fade;
  late AnimationController _starCtrl;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    _fadeCtrl.dispose();
    _starCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // Animated starfield background
          AnimatedBuilder(
            animation: _starCtrl,
            builder: (_, __) => CustomPaint(
              painter: _StarfieldPainter(_starCtrl.value),
              size: Size.infinite,
            ),
          ),

          // Grid lines converging to center
          CustomPaint(
            painter: _GridPainter(),
            size: Size.infinite,
          ),

          // Main content
          FadeTransition(
            opacity: _fade,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated bird logo
                  AnimatedBuilder(
                    animation: _floatCtrl,
                    builder: (_, __) => Transform.translate(
                      offset: Offset(0, _float.value),
                      child: _BirdLogo(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF00D4FF), Color(0xFF8B5CF6)],
                    ).createShader(bounds),
                    child: const Text(
                      'PATCH RUSH',
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fly as Shorebird (🐤). Dodge stores & bugs. Deploy patches.',
                    style: TextStyle(
                      color: Color(0xFF8892B0),
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stage Progression Roadmap Chips
                  const _StagesRoadmap(),

                  const SizedBox(height: 32),

                  // Mode selection buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, __) => Transform.scale(
                          scale: _pulse.value,
                          child: _PlayButton(
                            title: '▶  SOLO RUN',
                            subtitle: '1 PLAYER CAMPAIGN',
                            color: const Color(0xFF00D4FF),
                            onTap: widget.onStartSolo,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      _PlayButton(
                        title: '🌐  MULTIPLAYER LOBBY',
                        subtitle: 'ENTER CODE • COMPETE TOGETHER',
                        color: const Color(0xFFFFB347),
                        onTap: widget.onOpenLobby,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Controls hint
                  _ControlsHint(),

                  const SizedBox(height: 32),

                  // Shorebird credit
                  const Text(
                    'by Shorebird',
                    style: TextStyle(
                      color: Color(0xFF4A5568),
                      fontSize: 12,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BirdLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF1A3A5C), Color(0xFF0A0E1A)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withValues(alpha: 0.4),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: CustomPaint(painter: _BirdPainter()),
    );
  }
}

class _BirdPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.3;

    // Glow
    canvas.drawCircle(
      Offset(cx, cy),
      r * 1.3,
      Paint()
        ..color = const Color(0xFF00D4FF).withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Body
    final bodyPath = Path();
    bodyPath.moveTo(cx, cy - r * 1.4);
    bodyPath.cubicTo(
        cx + r, cy - r * 0.4, cx + r * 0.7, cy + r, cx, cy + r * 1.1);
    bodyPath.cubicTo(
        cx - r * 0.7, cy + r, cx - r, cy - r * 0.4, cx, cy - r * 1.4);

    canvas.drawPath(
      bodyPath,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF00D4FF), Color(0xFF8B5CF6)],
          center: Alignment(0, -0.3),
        ).createShader(
            Rect.fromCircle(center: Offset(cx, cy), radius: r * 1.5)),
    );

    // Eye
    canvas.drawCircle(
      Offset(cx + r * 0.28, cy - r * 0.2),
      r * 0.25,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(cx + r * 0.28, cy - r * 0.2),
      r * 0.13,
      Paint()..color = const Color(0xFF0A0E1A),
    );

    // Wings
    final wingPaint = Paint()
      ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final leftWing = Path()
      ..moveTo(cx - r * 0.3, cy)
      ..cubicTo(cx - r * 1.6, cy - r * 0.6, cx - r * 1.8, cy + 0, cx - r * 0.5,
          cy + r * 0.4);
    canvas.drawPath(leftWing, wingPaint);

    final rightWing = Path()
      ..moveTo(cx + r * 0.3, cy)
      ..cubicTo(cx + r * 1.6, cy - r * 0.6, cx + r * 1.8, cy + 0, cx + r * 0.5,
          cy + r * 0.4);
    canvas.drawPath(rightWing, wingPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlayButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PlayButton({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [color, Color.lerp(color, Colors.black, 0.35)!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0A0E1A),
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: const Color(0xFF0A0E1A).withValues(alpha: 0.75),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlsHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A3A5C)),
        color: const Color(0xFF111827).withValues(alpha: 0.75),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _KeyHint(label: '← A / D → or Tap Left/Right'),
              SizedBox(width: 8),
              Text(
                'Dodge Obstacles by Lane Switching',
                style: TextStyle(
                    color: Color(0xFF94A3B8), fontSize: 12, letterSpacing: 1),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '⚠️ HIGH DIFFICULTY: ',
                style: TextStyle(
                    color: Color(0xFFFF416C),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1),
              ),
              Text(
                'Missing a patch gives -15 pts penalty & resets combo!',
                style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11, letterSpacing: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeyHint extends StatelessWidget {
  final String label;
  const _KeyHint({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: const Color(0xFF1A2A4A),
        border:
            Border.all(color: const Color(0xFF00D4FF).withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF00D4FF),
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  final double progress;
  static final _rng = Random(99);
  static final _stars = List.generate(120, (_) => _StarData(_rng));

  _StarfieldPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in _stars) {
      final y = (star.y + progress * star.speed * 0.01) % 1.0;
      final alpha = (0.3 +
              0.7 * star.twinkle * sin(progress * star.twinkleSpeed * pi * 2))
          .clamp(0, 1);
      canvas.drawCircle(
        Offset(star.x * size.width, y * size.height),
        star.size,
        Paint()
          ..color = Color.fromARGB(
            (alpha * 255).round(),
            180,
            220,
            255,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter oldDelegate) => true;
}

class _StarData {
  final double x, y, speed, size, twinkle, twinkleSpeed;
  _StarData(Random rng)
      : x = rng.nextDouble(),
        y = rng.nextDouble(),
        speed = 0.5 + rng.nextDouble() * 2,
        size = 0.5 + rng.nextDouble() * 2,
        twinkle = rng.nextDouble(),
        twinkleSpeed = 1 + rng.nextDouble() * 4;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.55;
    const lineCount = 10;
    final paint = Paint()
      ..color = const Color(0xFF00D4FF).withValues(alpha: 0.07)
      ..strokeWidth = 1;

    for (int i = 0; i <= lineCount; i++) {
      final x = size.width * i / lineCount;
      canvas.drawLine(Offset(x, 0), Offset(cx, cy), paint);
    }

    for (int i = 0; i <= 6; i++) {
      final y = size.height * i / 6;
      final spread = ((cy - y).abs() / cy).clamp(0, 1) * size.width * 0.4;
      canvas.drawLine(
        Offset(cx - spread, y),
        Offset(cx + spread, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StagesRoadmap extends StatelessWidget {
  const _StagesRoadmap();

  @override
  Widget build(BuildContext context) {
    const plans = [
      ('🐣', 'HOBBY', '5,000', Color(0xFF00D4FF)),
      ('⚡', 'PRO', '50K', Color(0xFF00FF88)),
      ('💼', 'BUSINESS', '1,000,000', Color(0xFFFFB347)),
      ('👑', 'ENTERPRISE', 'CUSTOM', Color(0xFFA855F7)),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1527).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: plans.map((p) {
          final isLast = p == plans.last;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: p.$4.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: p.$4.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    Text(p.$1, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.$2,
                          style: TextStyle(
                            color: p.$4,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '${p.$3} patches',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.arrow_forward_ios_rounded,
                      size: 9, color: Color(0xFF475569)),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
