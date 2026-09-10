import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/features/app_shell/bloc/app_shell_bloc.dart';
import 'package:shorebird_runner/features/lead_capture/models/lead_model.dart';
import 'package:shorebird_runner/features/solo_runner/solo_runner.dart';
import 'package:shorebird_runner/features/start_menu/start_menu.dart';

class AppShellScreen extends StatelessWidget {
  const AppShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppShellBloc, AppShellState>(
      builder: (context, state) {
        switch (state.mode) {
          case AppMode.menu:
            return StartScreen(
              onStartPatching: (LeadModel lead) {
                context.read<AppShellBloc>().add(
                      NavigateToMode(
                        AppMode.solo,
                        lead: lead,
                      ),
                    );
              },
            );

          case AppMode.solo:
            return SoloRunnerScreen(
              lead: state.currentLead,
              onBackToMenu: () {
                context
                    .read<AppShellBloc>()
                    .add(const NavigateToMode(AppMode.menu));
              },
            );
        }
      },
    );
  }
}
