import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/data/repositories/settings_repository.dart';

class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(this._repository) : super(const AppSettings());

  final SettingsRepository _repository;

  Future<void> load() async => emit(await _repository.load());

  Future<void> setThemeMode(ThemeMode mode) =>
      _save(state.copyWith(themeMode: mode));

  Future<void> setLocale(String? code) =>
      _save(state.copyWith(localeCode: () => code));

  Future<void> completeOnboarding() =>
      _save(state.copyWith(onboardingComplete: true));

  Future<void> setOrderNotifications({required bool enabled}) =>
      _save(state.copyWith(orderNotifications: enabled));

  Future<void> setPromoNotifications({required bool enabled}) =>
      _save(state.copyWith(promoNotifications: enabled));

  Future<void> _save(AppSettings settings) async {
    emit(settings);
    await _repository.save(settings);
  }
}
