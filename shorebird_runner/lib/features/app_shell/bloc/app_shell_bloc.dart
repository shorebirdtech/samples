import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/features/app_shell/bloc/app_mode.dart';
import 'package:shorebird_runner/features/app_shell/bloc/app_shell_event.dart';
import 'package:shorebird_runner/features/app_shell/bloc/app_shell_state.dart';

export 'app_mode.dart';
export 'app_shell_event.dart';
export 'app_shell_state.dart';

class AppShellBloc extends Bloc<AppShellEvent, AppShellState> {
  AppShellBloc({AppMode initialMode = AppMode.menu})
      : super(AppShellState(mode: initialMode)) {
    on<NavigateToMode>(_onNavigateToMode);
    on<AppRematchTriggered>(_onRematchTriggered);
  }

  void _onNavigateToMode(
    NavigateToMode event,
    Emitter<AppShellState> emit,
  ) {
    emit(state.copyWith(
      mode: event.mode,
      podiumRankings: event.podiumRankings,
    ));
  }

  void _onRematchTriggered(
    AppRematchTriggered event,
    Emitter<AppShellState> emit,
  ) {
    emit(state.copyWith(mode: AppMode.race));
  }
}
