import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/constants/constants.dart';
import 'package:shorebird_runner/features/start_menu/widgets/widgets.dart';

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
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // === ANIMATED BACKGROUND ===
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => CustomPaint(
              painter: StartBackgroundPainter(_bgCtrl.value),
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
                            child: const ShorebirdLogo(),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // PATCH RUSH title
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              AppColors.shorebirdGold,
                              AppColors.goldPale,
                              AppColors.shorebirdGold,
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
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Subtitle
                        const Text(
                          'BY SHOREBIRD',
                          style: TextStyle(
                            color: AppColors.slateMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 6,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Tagline
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.shorebirdGold.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.shorebirdGold
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Text(
                            'Run as a Developer · Collect 🐤 Patches · Dodge App Store Delays',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.slateSubtle,
                              fontSize: 13,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Stage Progression roadmap
                        const StagesRoadmap(),

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
                                  child: StartMenuPrimaryButton(
                                    icon: '▶',
                                    title: 'SOLO RUN',
                                    subtitle: '1 PLAYER · CAMPAIGN MODE',
                                    onTap: () => showGameRulesDialog(
                                      context,
                                      onStart: widget.onStartSolo,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Secondary buttons row
                              Row(
                                children: [
                                  Expanded(
                                    child: StartMenuSecondaryButton(
                                      icon: '🌐',
                                      title: 'MULTIPLAYER',
                                      subtitle: 'LOBBY · COMPETE',
                                      color: AppColors.lightCyan,
                                      onTap: widget.onOpenLobby,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: StartMenuSecondaryButton(
                                      icon: '📜',
                                      title: 'HOW TO PLAY',
                                      subtitle: 'RULES · CONTROLS',
                                      color: AppColors.lightGreen,
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
                        const ControlsHint(),

                        const SizedBox(height: 24),

                        // Shorebird footer
                        const ShorebirdFooter(),
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
