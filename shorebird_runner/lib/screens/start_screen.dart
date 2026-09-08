import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shorebird_runner/widgets/game_rules_dialog.dart';

/// Full Shorebird-branded start screen with cinematic parallax background,
/// golden bird logo, animated title, and glassmorphic mode selection cards.
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
  late AnimationController _bgCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _pulse;
  late Animation<double> _float;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF0C0D10),
      body: Stack(
        children: [
          // === ANIMATED BACKGROUND ===
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => CustomPaint(
              painter: _BackgroundPainter(_bgCtrl.value),
              size: size,
            ),
          ),

          // === MAIN CONTENT ===
          FadeTransition(
            opacity: _fade,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Shorebird Logo
                        AnimatedBuilder(
                          animation: _floatCtrl,
                          builder: (_, __) => Transform.translate(
                            offset: Offset(0, _float.value),
                            child: const _ShorebirdLogo(),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // PATCH RUSH title
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFFFC107),
                              Color(0xFFFFE082),
                              Color(0xFFFFC107),
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ).createShader(bounds),
                          child: const Text(
                            'PATCH RUSH',
                            style: TextStyle(
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 10,
                              height: 1.0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Subtitle
                        const Text(
                          'BY SHOREBIRD',
                          style: TextStyle(
                            color: Color(0xFF78909C),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 6,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Tagline
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFFC107).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFFFC107)
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Text(
                            'Run as a Developer · Collect 🐤 Patches · Dodge App Store Delays',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF90A4AE),
                              fontSize: 13,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Stage Progression roadmap
                        const _StagesRoadmap(),

                        const SizedBox(height: 28),

                        // Mode selection buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              // Primary CTA
                              AnimatedBuilder(
                                animation: _pulseCtrl,
                                builder: (_, __) => Transform.scale(
                                  scale: _pulse.value,
                                  child: _PrimaryButton(
                                    icon: '▶',
                                    title: 'SOLO RUN',
                                    subtitle: '1 PLAYER · CAMPAIGN MODE',
                                    onTap: () => showGameRulesDialog(context,
                                        onStart: widget.onStartSolo),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Secondary buttons row
                              Row(
                                children: [
                                  Expanded(
                                    child: _SecondaryButton(
                                      icon: '🌐',
                                      title: 'MULTIPLAYER',
                                      subtitle: 'LOBBY · COMPETE',
                                      color: const Color(0xFF26C6DA),
                                      onTap: widget.onOpenLobby,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _SecondaryButton(
                                      icon: '📜',
                                      title: 'HOW TO PLAY',
                                      subtitle: 'RULES · CONTROLS',
                                      color: const Color(0xFF66BB6A),
                                      onTap: () => showGameRulesDialog(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Controls hint
                        const _ControlsHint(),

                        const SizedBox(height: 24),

                        // Shorebird footer
                        const _ShorebirdFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SHOREBIRD LOGO
// ─────────────────────────────────────────────────────────────
class _ShorebirdLogo extends StatelessWidget {
  const _ShorebirdLogo();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 148,
          height: 148,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFC107).withValues(alpha: 0.30),
                blurRadius: 60,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
        // Logo container
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFF1A1C20), Color(0xFF0C0D10)],
              center: Alignment.topLeft,
              radius: 1.5,
            ),
            border: Border.all(
              color: const Color(0xFFFFC107).withValues(alpha: 0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFC107).withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Developer avatar
              const Text('👨‍💻', style: TextStyle(fontSize: 52)),
              // Shorebird badge
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0D10),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFC107),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFC107).withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Text('🐤', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PRIMARY PLAY BUTTON
// ─────────────────────────────────────────────────────────────
class _PrimaryButton extends StatefulWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: _hovered
                  ? [const Color(0xFFFFD54F), const Color(0xFFFFA000)]
                  : [const Color(0xFFFFC107), const Color(0xFFFF8F00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFC107)
                    .withValues(alpha: _hovered ? 0.65 : 0.40),
                blurRadius: _hovered ? 40 : 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.icon,
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF1A1200),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1200),
                      letterSpacing: 3,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5D4037),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SECONDARY BUTTON
// ─────────────────────────────────────────────────────────────
class _SecondaryButton extends StatefulWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<_SecondaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: _hovered
                ? widget.color.withValues(alpha: 0.14)
                : widget.color.withValues(alpha: 0.07),
            border: Border.all(
              color: widget.color.withValues(alpha: _hovered ? 0.7 : 0.35),
              width: 1.5,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.2),
                      blurRadius: 20,
                    )
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(widget.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 6),
              Text(
                widget.title,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.subtitle,
                style: TextStyle(
                  color: const Color(0xFF607D8B).withValues(alpha: 0.9),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CONTROLS HINT
// ─────────────────────────────────────────────────────────────
class _ControlsHint extends StatelessWidget {
  const _ControlsHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF12141A),
        border: Border.all(color: const Color(0xFF263238)),
      ),
      child: Column(
        children: [
          const _ControlRow(
            keys: ['A', 'D', '◀▶'],
            label: 'Switch lanes',
            color: Color(0xFFFFC107),
          ),
          const SizedBox(height: 8),
          const _ControlRow(
            keys: ['W', '↑', 'Space'],
            label: 'Jump over obstacles',
            color: Color(0xFF26C6DA),
          ),
          const SizedBox(height: 8),
          const _ControlRow(
            keys: ['S', '↓'],
            label: 'Slide under obstacles',
            color: Color(0xFF66BB6A),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5252).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.25)),
            ),
            child: const Text(
              '⚠️  HIGH DIFFICULTY — Missing a patch costs -15 pts & resets combo!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFEF9A9A),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlRow extends StatelessWidget {
  final List<String> keys;
  final String label;
  final Color color;

  const _ControlRow({
    required this.keys,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...keys.map(
          (k) => Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              k,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF78909C),
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STAGES ROADMAP
// ─────────────────────────────────────────────────────────────
class _StagesRoadmap extends StatelessWidget {
  const _StagesRoadmap();

  @override
  Widget build(BuildContext context) {
    const plans = [
      ('🐣', 'HOBBY', '5,000', Color(0xFF00BCD4)),
      ('⚡', 'PRO', '50K', Color(0xFF4CAF50)),
      ('💼', 'BUSINESS', '1M', Color(0xFFFFC107)),
      ('👑', 'ENTERPRISE', 'CUSTOM', Color(0xFF9C27B0)),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF12141A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2730)),
      ),
      child: Column(
        children: [
          const Text(
            'PATCH QUOTAS — SHOREBIRD PLANS',
            style: TextStyle(
              color: Color(0xFF546E7A),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: plans.map((p) {
              final isLast = p == plans.last;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PlanChip(emoji: p.$1, name: p.$2, quota: p.$3, color: p.$4),
                  if (!isLast)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 8,
                        color: Color(0xFF37474F),
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PlanChip extends StatelessWidget {
  final String emoji;
  final String name;
  final String quota;
  final Color color;

  const _PlanChip({
    required this.emoji,
    required this.name,
    required this.quota,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 3),
          Text(
            name,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          Text(
            quota,
            style: const TextStyle(
              color: Color(0xFF546E7A),
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SHOREBIRD FOOTER
// ─────────────────────────────────────────────────────────────
class _ShorebirdFooter extends StatelessWidget {
  const _ShorebirdFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🐤', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        const Text(
          'shorebird.dev',
          style: TextStyle(
            color: Color(0xFF37474F),
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFFFFC107),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Code Push · OTA Updates',
          style: TextStyle(
            color: Color(0xFF37474F),
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ANIMATED BACKGROUND PAINTER
// ─────────────────────────────────────────────────────────────
class _BackgroundPainter extends CustomPainter {
  final double progress;
  static final _rng = Random(42);
  static final _stars = List.generate(180, (_) => _StarData(_rng));
  static final _particles = List.generate(25, (i) => _ParticleData(_rng, i));

  _BackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Deep space gradient background
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.3),
        radius: 1.2,
        colors: [
          Color(0xFF141820),
          Color(0xFF0C0D10),
          Color(0xFF080910),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Subtle golden aurora glow at top
    final auroraPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -1.0),
        radius: 0.8,
        colors: [
          const Color(0xFFFFC107).withValues(alpha: 0.06),
          const Color(0xFFFFC107).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), auroraPaint);

    // Stars
    for (final star in _stars) {
      final y = (star.y + progress * star.speed * 0.008) % 1.0;
      final twinkleVal =
          (0.4 + 0.6 * sin(progress * star.twinkleSpeed * pi * 2 + star.phase))
              .clamp(0.0, 1.0);
      final alpha = star.brightness * twinkleVal;
      canvas.drawCircle(
        Offset(star.x * size.width, y * size.height),
        star.size,
        Paint()
          ..color = Color.fromARGB(
            (alpha * 255).round(),
            star.isGolden ? 255 : 180,
            star.isGolden ? 220 : 210,
            star.isGolden ? 100 : 255,
          ),
      );
    }

    // Drifting golden particles (like code patches floating)
    for (final p in _particles) {
      final y = (p.startY - progress * p.speed) % 1.0;
      final x = p.startX + sin(progress * p.wobble * pi * 2) * 0.03;
      final lifeAlpha = sin(y * pi).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.size,
        Paint()
          ..color = const Color(0xFFFFC107).withValues(alpha: lifeAlpha * 0.35),
      );
    }

    // Subtle perspective grid at bottom
    final gridPaint = Paint()
      ..color = const Color(0xFFFFC107).withValues(alpha: 0.04)
      ..strokeWidth = 1;
    final cx = size.width / 2;
    final cy = size.height * 0.72;
    for (int i = 0; i <= 8; i++) {
      final x = size.width * i / 8;
      canvas.drawLine(Offset(x, size.height), Offset(cx, cy), gridPaint);
    }
    for (int i = 0; i <= 5; i++) {
      final y = cy + (size.height - cy) * i / 5;
      final spread = ((size.height - y) / (size.height - cy)).clamp(0.0, 1.0) *
          size.width *
          0.5;
      canvas.drawLine(
          Offset(cx - spread, y), Offset(cx + spread, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) => true;
}

class _StarData {
  final double x, y, speed, size, twinkle, twinkleSpeed, phase, brightness;
  final bool isGolden;

  _StarData(Random rng)
      : x = rng.nextDouble(),
        y = rng.nextDouble(),
        speed = 0.3 + rng.nextDouble() * 1.5,
        size = 0.4 + rng.nextDouble() * 1.8,
        twinkle = rng.nextDouble(),
        twinkleSpeed = 0.5 + rng.nextDouble() * 3,
        phase = rng.nextDouble() * pi * 2,
        brightness = 0.4 + rng.nextDouble() * 0.6,
        isGolden = rng.nextDouble() < 0.08;
}

class _ParticleData {
  final double startX, startY, speed, size, wobble;

  _ParticleData(Random rng, int i)
      : startX = rng.nextDouble(),
        startY = rng.nextDouble(),
        speed = 0.04 + rng.nextDouble() * 0.08,
        size = 1.5 + rng.nextDouble() * 3.0,
        wobble = 0.3 + rng.nextDouble() * 0.7;
}
