import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/data/sources/catalog_api.dart';
import 'package:plume/features/settings/settings_cubit.dart';
import 'package:plume/l10n/l10n.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final settings = context.watch<SettingsCubit>().state;
    final cubit = context.read<SettingsCubit>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Label(l10n.appearance),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                icon: const Icon(Icons.brightness_auto_rounded),
                label: Text(l10n.themeSystem),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: const Icon(Icons.light_mode_rounded),
                label: Text(l10n.themeLight),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: const Icon(Icons.dark_mode_rounded),
                label: Text(l10n.themeDark),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (s) => unawaited(cubit.setThemeMode(s.first)),
          ),
          _Label(l10n.language),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: '', label: Text(l10n.languageSystem)),
              const ButtonSegment(value: 'en', label: Text('English')),
              const ButtonSegment(value: 'es', label: Text('Español')),
            ],
            selected: {settings.localeCode ?? ''},
            onSelectionChanged: (s) =>
                unawaited(cubit.setLocale(s.first.isEmpty ? null : s.first)),
          ),
          _Label(l10n.notifications),
          _Card(
            children: [
              SwitchListTile.adaptive(
                title: Text(l10n.orderUpdates),
                subtitle: Text(l10n.orderUpdatesBody),
                value: settings.orderNotifications,
                onChanged: (v) =>
                    unawaited(cubit.setOrderNotifications(enabled: v)),
              ),
              SwitchListTile.adaptive(
                title: Text(l10n.offers),
                subtitle: Text(l10n.offersBody),
                value: settings.promoNotifications,
                onChanged: (v) =>
                    unawaited(cubit.setPromoNotifications(enabled: v)),
              ),
            ],
          ),
          _Label(l10n.developer),
          _Card(
            children: [
              ListTile(
                leading: const Icon(Icons.wifi_off_rounded),
                title: Text(l10n.simulateOffline),
                subtitle: Text(l10n.simulateOfflineBody),
                onTap: () {
                  context.read<CatalogApi>().failNextRequest = true;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.simulateOfflineArmed)),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              l10n.madeWithShorebird,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(16),
    clipBehavior: Clip.antiAlias,
    child: Column(children: children),
  );
}
