import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/features/app_shell/bloc/app_mode.dart';
import 'package:shorebird_runner/features/lead_capture/models/lead_model.dart';

abstract class AppShellEvent extends Equatable {
  const AppShellEvent();

  @override
  List<Object?> get props => [];
}

class NavigateToMode extends AppShellEvent {
  final AppMode mode;
  final LeadModel? lead;

  const NavigateToMode(this.mode, {this.lead});

  @override
  List<Object?> get props => [mode, lead];
}
