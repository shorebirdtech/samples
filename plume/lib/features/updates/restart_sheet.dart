import 'package:material_ui/material_ui.dart';
import 'package:plume/app/router.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/l10n/l10n.dart';

/// Explains how to restart so the downloaded patch takes effect.
///
/// Flutter apps can't relaunch themselves, and iOS forbids apps from quitting
/// programmatically, so we ask the user to close and reopen the app.
Future<void> showRestartSheet(BuildContext context) {
  final navigatorContext = rootNavigatorKey.currentContext ?? context;
  return showModalBottomSheet<void>(
    context: navigatorContext,
    showDragHandle: true,
    builder: (context) {
      final l10n = context.l10n;
      final theme = Theme.of(context);
      final steps = [
        (Icons.swipe_up_rounded, l10n.restartStep1),
        (Icons.close_rounded, l10n.restartStep2),
        (Icons.touch_app_rounded, l10n.restartStep3),
      ];
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.restartTitle, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(l10n.restartBody, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 20),
              for (final (index, (icon, text)) in steps.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Palette.violet.withValues(alpha: 0.15),
                        child: Icon(icon, color: Palette.violet),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          '${index + 1}. $text',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.gotIt),
              ),
            ],
          ),
        ),
      );
    },
  );
}
