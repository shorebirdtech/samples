import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/core/core.dart';
import 'package:shorebird_runner/features/lead_capture/lead_capture.dart';
import 'package:shorebird_runner/features/leaderboard/leaderboard.dart';
import 'package:shorebird_runner/features/start_menu/widgets/widgets.dart';

/// Full Shorebird-branded start screen with obsidian theme,
/// signature Shorebird golden emblem, stages roadmap, and "Start Patching" lead capture.
/// Includes a secret 3-tap trigger on the Shorebird Logo to configure the active event.
class StartScreen extends StatefulWidget {
  final void Function(LeadModel lead) onStartPatching;

  const StartScreen({
    super.key,
    required this.onStartPatching,
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

  int _logoTapCount = 0;
  DateTime? _lastLogoTap;

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
    _pulse = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -5, end: 5).animate(
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

  void _onStartPressed() {
    LeadCaptureDialog.show(
      context,
      onStartGame: widget.onStartPatching,
    );
  }

  /// Secret Easter Egg: Tapping the Shorebird logo 3 times opens the booth event configuration dialog.
  void _onLogoTapped() {
    final now = DateTime.now();
    if (_lastLogoTap == null ||
        now.difference(_lastLogoTap!) > const Duration(milliseconds: 1200)) {
      _logoTapCount = 1;
    } else {
      _logoTapCount++;
    }
    _lastLogoTap = now;

    if (_logoTapCount >= 3) {
      _logoTapCount = 0;
      EventConfigDialog.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // === ANIMATED AMBIENT BACKGROUND ===
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
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Shorebird Logo (with 3-tap secret trigger)
                          AnimatedBuilder(
                            animation: _floatCtrl,
                            builder: (_, __) => Transform.translate(
                              offset: Offset(0, _float.value),
                              child: Tooltip(
                                message: '',
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _onLogoTapped,
                                  child: const ShorebirdLogo(),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

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
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 10,
                                height: 1.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Subtitle
                          const Text(
                            'BY SHOREBIRD',
                            style: TextStyle(
                              color: AppColors.slateMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 6,
                            ),
                          ),

                          // Active Event Pill (visible only when event is configured)
                          BlocBuilder<LeadCaptureBloc, LeadCaptureState>(
                            buildWhen: (prev, cur) => prev.event != cur.event,
                            builder: (context, state) {
                              if (state.event.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.shorebirdGold
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.shorebirdGold
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        size: 12,
                                        color: AppColors.shorebirdGold,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        state.event.toUpperCase(),
                                        style: const TextStyle(
                                          color: AppColors.shorebirdGold,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 10),

                          // Refined Developer Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111827),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.shorebirdGold
                                    .withValues(alpha: 0.25),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shorebirdGold
                                      .withValues(alpha: 0.05),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  color: AppColors.shorebirdGold,
                                  size: 15,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Code Push Arcade · Dodge App Store Delays · Deploy Instantly',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.slateSubtle,
                                    fontSize: 11.5,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Stage Progression roadmap
                          const StagesRoadmap(),

                          const SizedBox(height: 18),

                          // Action Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                // Primary "START PATCHING" CTA
                                AnimatedBuilder(
                                  animation: _pulseCtrl,
                                  builder: (_, __) => Transform.scale(
                                    scale: _pulse.value,
                                    child: StartMenuPrimaryButton(
                                      icon: '⚡',
                                      title: 'START PATCHING',
                                      subtitle:
                                          'SOLO RUNNER · INSTANT OTA FIXES',
                                      onTap: _onStartPressed,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Secondary actions row
                                Row(
                                  children: [
                                    Expanded(
                                      child: StartMenuSecondaryButton(
                                        icon: Icons.emoji_events_rounded,
                                        title: 'LEADERBOARD',
                                        subtitle: 'TOP SCORES · RANKS',
                                        color: AppColors.shorebirdGold,
                                        onTap: () {
                                          final activeEvent = context
                                              .read<LeadCaptureBloc>()
                                              .state
                                              .event;
                                          LeaderboardDialog.show(
                                            context,
                                            initialEvent: activeEvent.isNotEmpty
                                                ? activeEvent
                                                : null,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: StartMenuSecondaryButton(
                                        icon: Icons.menu_book_rounded,
                                        title: 'HOW TO PLAY',
                                        subtitle: 'RULES · TIERS · CONTROLS',
                                        color: const Color(0xFF38BDF8),
                                        onTap: () => showGameRulesDialog(
                                          context,
                                          onStart: _onStartPressed,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Controls hint
                          const ControlsHint(),

                          const SizedBox(height: 14),

                          // Shorebird footer
                          const ShorebirdFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // === TOP RIGHT CONTROLS: AUDIO TOGGLE ===
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: ValueListenableBuilder<bool>(
                  valueListenable: AudioService.isMutedNotifier,
                  builder: (context, isMuted, _) {
                    return Material(
                      color: Colors.transparent,
                      child: Tooltip(
                        message: isMuted ? 'Unmute Audio' : 'Mute Audio',
                        child: InkWell(
                          onTap: () {
                            AudioService.playSelect();
                            AudioService.toggleMute();
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111827)
                                  .withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isMuted
                                    ? Colors.white12
                                    : AppColors.shorebirdGold
                                        .withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isMuted
                                      ? Icons.volume_off_rounded
                                      : Icons.volume_up_rounded,
                                  color: isMuted
                                      ? AppColors.slateMuted
                                      : AppColors.shorebirdGold,
                                  size: 16,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isMuted ? 'MUTED' : 'AUDIO',
                                  style: TextStyle(
                                    color: isMuted
                                        ? AppColors.slateMuted
                                        : AppColors.shorebirdGold,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
