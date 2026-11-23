import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/core/widgets/widgets.dart';
import 'package:plume/features/settings/settings_cubit.dart';
import 'package:plume/l10n/l10n.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  double _page = 0;

  static const _art = [
    [('headphones', Color(0xFF7C5CFF)), ('watch', Color(0xFF2DD4BF))],
    [('backpack', Color(0xFFFF8A5B)), ('luggage', Color(0xFF22314F))],
    [('keyboard', Color(0xFF4F8DFF)), ('lamp', Color(0xFFF6D776))],
  ];

  static const List<List<Color>> _backgrounds = [
    [Palette.ink, Palette.violet, Color(0xFFFF6FD8)],
    [Palette.ink, Color(0xFFFF8A5B), Color(0xFF7C3AED)],
    [Palette.ink, Palette.aqua, Palette.iris],
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() => _page = _controller.page!));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next(int count) {
    if (_page.round() >= count - 1) {
      unawaited(context.read<SettingsCubit>().completeOnboarding());
      return;
    }
    _controller.nextPage(duration: Motion.page, curve: Motion.emphasized);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pages = [
      (l10n.onboardingTitle1, l10n.onboardingBody1),
      (l10n.onboardingTitle2, l10n.onboardingBody2),
      (l10n.onboardingTitle3, l10n.onboardingBody3),
    ];
    final current = _page.round().clamp(0, pages.length - 1);
    final last = current == pages.length - 1;
    return Scaffold(
      body: Stack(
        children: [
          // Only the backdrop crossfades; the PageView must stay mounted.
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: Motion.of(context, Motion.slow),
              // The default layout centres children at their natural size,
              // which is zero for a childless backdrop. Stretch it instead.
              layoutBuilder: (current, previous) => Stack(
                fit: StackFit.expand,
                children: [...previous, ?current],
              ),
              child: AuroraBackground(
                key: ValueKey(current),
                colors: _backgrounds[current],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: () => unawaited(
                      context.read<SettingsCubit>().completeOnboarding(),
                    ),
                    child: Text(l10n.skip),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: pages.length,
                    itemBuilder: (context, index) => _OnboardingSlide(
                      title: pages[index].$1,
                      body: pages[index].$2,
                      art: _art[index],
                      offset: _page - index,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Row(
                    children: [
                      for (var i = 0; i < pages.length; i++)
                        AnimatedContainer(
                          duration: Motion.of(context, Motion.medium),
                          curve: Motion.emphasized,
                          margin: const EdgeInsets.only(right: 8),
                          height: 8,
                          width: i == current ? 28 : 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: i == current ? 1 : 0.35,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      const Spacer(),
                      AnimatedContainer(
                        duration: Motion.of(context, Motion.medium),
                        curve: Motion.emphasized,
                        width: last ? 180 : 64,
                        height: 64,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Palette.ink,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(64, 64),
                          ),
                          onPressed: () => _next(pages.length),
                          child: AnimatedSwitcher(
                            duration: Motion.of(context, Motion.fast),
                            child: last
                                ? Text(
                                    l10n.getStarted,
                                    key: const ValueKey('start'),
                                    maxLines: 1,
                                  )
                                : Icon(
                                    Icons.arrow_forward_rounded,
                                    key: const ValueKey('next'),
                                    semanticLabel: l10n.next,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.title,
    required this.body,
    required this.art,
    required this.offset,
  });

  final String title;
  final String body;
  final List<(String, Color)> art;

  /// How far this slide is from the centre, for parallax.
  final double offset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = math.min(constraints.maxWidth, 320) * 0.62;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(-size * 0.3 + offset * 160, -size * 0.18),
                      child: Transform.rotate(
                        angle: -0.14 + offset * 0.3,
                        child: SizedBox.square(
                          dimension: size,
                          child: ProductArt(
                            icon: art[0].$1,
                            color: art[0].$2,
                            borderRadius: 20,
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(size * 0.32 + offset * 60, size * 0.26),
                      child: Transform.rotate(
                        angle: 0.12 - offset * 0.2,
                        child: SizedBox.square(
                          dimension: size * 0.8,
                          child: ProductArt(
                            icon: art[1].$1,
                            color: art[1].$2,
                            borderRadius: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Opacity(
            opacity: (1 - offset.abs()).clamp(0, 1),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
