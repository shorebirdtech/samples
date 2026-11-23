import 'package:material_ui/material_ui.dart';
import 'package:plume/core/storage/key_value_store.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.localeCode,
    this.onboardingComplete = false,
    this.orderNotifications = true,
    this.promoNotifications = false,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    themeMode: ThemeMode.values.byName(
      json['themeMode'] as String? ?? ThemeMode.system.name,
    ),
    localeCode: json['localeCode'] as String?,
    onboardingComplete: json['onboardingComplete'] as bool? ?? false,
    orderNotifications: json['orderNotifications'] as bool? ?? true,
    promoNotifications: json['promoNotifications'] as bool? ?? false,
  );

  final ThemeMode themeMode;

  /// `null` follows the device language.
  final String? localeCode;
  final bool onboardingComplete;
  final bool orderNotifications;
  final bool promoNotifications;

  Locale? get locale => localeCode == null ? null : Locale(localeCode!);

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? Function()? localeCode,
    bool? onboardingComplete,
    bool? orderNotifications,
    bool? promoNotifications,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    localeCode: localeCode != null ? localeCode() : this.localeCode,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    orderNotifications: orderNotifications ?? this.orderNotifications,
    promoNotifications: promoNotifications ?? this.promoNotifications,
  );

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'localeCode': localeCode,
    'onboardingComplete': onboardingComplete,
    'orderNotifications': orderNotifications,
    'promoNotifications': promoNotifications,
  };
}

class SettingsRepository {
  SettingsRepository(this._store);

  static const _key = 'settings.v1';

  final KeyValueStore _store;

  Future<AppSettings> load() async {
    final json = await _store.readJson(_key);
    return json is Map<String, dynamic>
        ? AppSettings.fromJson(json)
        : const AppSettings();
  }

  Future<void> save(AppSettings settings) =>
      _store.writeJson(_key, settings.toJson());
}
