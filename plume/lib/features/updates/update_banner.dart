import 'dart:async';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/app/router.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/features/updates/restart_sheet.dart';
import 'package:plume/features/updates/update_cubit.dart';
import 'package:plume/l10n/l10n.dart';

/// Slides a pill in from the top when a patch is available or installed,
/// above every screen in the app.
class UpdateBanner extends StatefulWidget {
  const UpdateBanner({required this.router, required this.child, super.key});

  final GoRouter router;
  final Widget child;

  @override
  State<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends State<UpdateBanner> {
  UpdatePhase? _dismissedFor;

  static const Set<UpdatePhase> _visiblePhases = {
    UpdatePhase.available,
    UpdatePhase.downloading,
    UpdatePhase.readyToRestart,
  };

  @override
  Widget build(BuildContext context) {
    final phase = context.select<UpdateCubit, UpdatePhase>(
      (c) => c.state.phase,
    );
    final visible = _visiblePhases.contains(phase) && _dismissedFor != phase;
    final top = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        widget.child,
        AnimatedPositioned(
          duration: Motion.of(context, Motion.slow),
          curve: visible ? Motion.spring : Motion.emphasized,
          left: 12,
          right: 12,
          top: visible ? top + 8 : -140,
          child: AnimatedOpacity(
            duration: Motion.of(context, Motion.medium),
            opacity: visible ? 1 : 0,
            child: _BannerCard(
              phase: phase,
              onDismiss: () => setState(() => _dismissedFor = phase),
              onOpen: () => unawaited(widget.router.push(Routes.updates)),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.phase,
    required this.onDismiss,
    required this.onOpen,
  });

  final UpdatePhase phase;
  final VoidCallback onDismiss;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cubit = context.read<UpdateCubit>();
    final (title, subtitle, action) = switch (phase) {
      UpdatePhase.downloading => (
        l10n.updateDownloading,
        l10n.updateDownloadingBody,
        null,
      ),
      UpdatePhase.readyToRestart => (
        l10n.updateReadyTitle,
        l10n.updateReadyBody,
        (l10n.restart, () => unawaited(showRestartSheet(context))),
      ),
      _ => (
        l10n.updateAvailableTitle,
        l10n.updateAvailableBody,
        (l10n.install, () => unawaited(cubit.download())),
      ),
    };
    return Material(
      type: MaterialType.transparency,
      child: Semantics(
        liveRegion: true,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: InkWell(
              onTap: onOpen,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                decoration: BoxDecoration(
                  color: Palette.ink.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: Palette.brandGradient,
                        shape: BoxShape.circle,
                      ),
                      child: phase == UpdatePhase.downloading
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              phase == UpdatePhase.readyToRestart
                                  ? Icons.restart_alt_rounded
                                  : Icons.system_update_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (action != null)
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Palette.aqua,
                        ),
                        onPressed: action.$2,
                        child: Text(action.$1),
                      ),
                    // No tooltip: the banner sits above the Navigator, so
                    // there is no Overlay for one to render into.
                    Semantics(
                      label: l10n.dismiss,
                      button: true,
                      excludeSemantics: true,
                      child: IconButton(
                        color: Colors.white60,
                        onPressed: onDismiss,
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
