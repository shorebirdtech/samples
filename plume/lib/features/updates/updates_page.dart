import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/core/widgets/widgets.dart';
import 'package:plume/features/updates/restart_sheet.dart';
import 'package:plume/features/updates/update_cubit.dart';
import 'package:plume/l10n/l10n.dart';

/// Shows what's running and drives Shorebird updates by hand. This is the
/// screen to keep on stage during a release-and-patch demo.
class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<UpdateCubit>().state;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.updatesTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          _StatusHero(state: state),
          const SizedBox(height: 20),
          _VersionCard(state: state),
          const SizedBox(height: 20),
          if (state.phase != UpdatePhase.unavailable) ...[
            _Actions(state: state),
            const SizedBox(height: 28),
          ],
          const _HowItWorks(),
        ],
      ),
    );
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.state});

  final UpdateState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final (icon, title, body) = switch (state.phase) {
      UpdatePhase.unavailable => (
        Icons.developer_mode_rounded,
        l10n.updaterUnavailableTitle,
        l10n.updaterUnavailableBody,
      ),
      UpdatePhase.idle || UpdatePhase.checking => (
        Icons.radar_rounded,
        l10n.updateChecking,
        l10n.updateCheckingBody,
      ),
      UpdatePhase.upToDate => (
        Icons.verified_rounded,
        l10n.upToDateTitle,
        state.lastChecked == null
            ? l10n.upToDateBody
            : l10n.lastChecked(
                DateFormat.jms(locale).format(state.lastChecked!),
              ),
      ),
      UpdatePhase.available => (
        Icons.system_update_rounded,
        l10n.updateAvailableTitle,
        l10n.updateAvailableBody,
      ),
      UpdatePhase.downloading => (
        Icons.downloading_rounded,
        l10n.updateDownloading,
        l10n.updateDownloadingBody,
      ),
      UpdatePhase.readyToRestart => (
        Icons.restart_alt_rounded,
        l10n.updateReadyTitle,
        l10n.updateReadyBody,
      ),
      UpdatePhase.failed => (
        Icons.error_outline_rounded,
        l10n.updateFailedTitle,
        l10n.updateFailedBody,
      ),
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AuroraBackground(
        colors: const [Palette.ink, Palette.violet, Palette.aqua],
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _Orb(icon: icon, spinning: state.isBusy),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: Motion.of(context, Motion.medium),
                child: Column(
                  key: ValueKey(state.phase),
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A glowing orb with orbiting rings that spin while the updater works.
class _Orb extends StatefulWidget {
  const _Orb({required this.icon, required this.spinning});

  final IconData icon;
  final bool spinning;

  @override
  State<_Orb> createState() => _OrbState();
}

class _OrbState extends State<_Orb> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_Orb oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (Motion.reduced(context)) {
      _controller.stop();
      return;
    }
    _controller.duration = widget.spinning
        ? const Duration(milliseconds: 1400)
        : const Duration(seconds: 6);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 132,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          painter: _RingsPainter(_controller.value),
          child: child,
        ),
        child: Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: AnimatedSwitcher(
              duration: Motion.of(context, Motion.medium),
              transitionBuilder: (child, animation) => RotationTransition(
                turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: Icon(
                widget.icon,
                key: ValueKey(widget.icon),
                size: 38,
                color: Palette.violet,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (var i = 0; i < 2; i++) {
      final radius = size.width / 2 - i * 12;
      final start = (t + i * 0.5) * 2 * math.pi * (i.isEven ? 1 : -1);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        math.pi * 1.2,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            colors: [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: 0.8),
            ],
            transform: GradientRotation(start),
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }
  }

  @override
  bool shouldRepaint(_RingsPainter oldDelegate) => oldDelegate.t != t;
}

class _VersionCard extends StatefulWidget {
  const _VersionCard({required this.state});

  final UpdateState state;

  @override
  State<_VersionCard> createState() => _VersionCardState();
}

class _VersionCardState extends State<_VersionCard> {
  final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = widget.state;
    String patchLabel(int? number) =>
        number == null ? l10n.noPatch : l10n.patchNumber(number);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: FutureBuilder(
        future: _info,
        builder: (context, snapshot) {
          final info = snapshot.data;
          final rows = [
            (
              l10n.releaseVersion,
              info == null ? '…' : '${info.version} (${info.buildNumber})',
            ),
            (l10n.runningPatch, patchLabel(state.currentPatch)),
            if (state.nextPatch != null &&
                state.nextPatch != state.currentPatch)
              (l10n.nextLaunchPatch, patchLabel(state.nextPatch)),
          ];
          return Column(
            children: [
              for (final (label, value) in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: Motion.of(context, Motion.medium),
                        child: Text(
                          value,
                          key: ValueKey(value),
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.state});

  final UpdateState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<UpdateCubit>();
    return AnimatedSwitcher(
      duration: Motion.of(context, Motion.medium),
      child: switch (state.phase) {
        UpdatePhase.available || UpdatePhase.failed => FilledButton.icon(
          key: const ValueKey('download'),
          onPressed: () => unawaited(cubit.download()),
          icon: const Icon(Icons.download_rounded),
          label: Text(
            state.phase == UpdatePhase.failed ? l10n.retry : l10n.install,
          ),
        ),
        UpdatePhase.readyToRestart => FilledButton.icon(
          key: const ValueKey('restart'),
          onPressed: () => unawaited(showRestartSheet(context)),
          icon: const Icon(Icons.restart_alt_rounded),
          label: Text(l10n.restart),
        ),
        _ => OutlinedButton.icon(
          key: const ValueKey('check'),
          onPressed: state.isBusy ? null : () => unawaited(cubit.check()),
          icon: state.isBusy
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded),
          label: Text(l10n.checkForUpdates),
        ),
      },
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final steps = [
      (Icons.rocket_launch_rounded, l10n.howStep1Title, l10n.howStep1Body),
      (Icons.build_circle_rounded, l10n.howStep2Title, l10n.howStep2Body),
      (Icons.bolt_rounded, l10n.howStep3Title, l10n.howStep3Body),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.howItWorks, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        for (final (index, (icon, title, body)) in steps.indexed)
          Entrance(
            index: index,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Palette.violet.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: Palette.violet),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleSmall),
                        const SizedBox(height: 4),
                        Text(body, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
