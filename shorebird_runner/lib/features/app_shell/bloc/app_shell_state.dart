import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/features/app_shell/bloc/app_mode.dart';
import 'package:shorebird_runner/features/lead_capture/models/lead_model.dart';

class AppShellState extends Equatable {
  final AppMode mode;
  final LeadModel? currentLead;

  const AppShellState({
    this.mode = AppMode.menu,
    this.currentLead,
  });

  AppShellState copyWith({
    AppMode? mode,
    LeadModel? currentLead,
  }) {
    return AppShellState(
      mode: mode ?? this.mode,
      currentLead: currentLead ?? this.currentLead,
    );
  }

  @override
  List<Object?> get props => [mode, currentLead];
}
