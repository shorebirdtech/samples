import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/features/app_shell/bloc/app_shell_bloc.dart';
import 'package:shorebird_runner/features/booth_battle/booth_battle.dart';
import 'package:shorebird_runner/features/multiplayer_race/multiplayer_race.dart';
import 'package:shorebird_runner/features/solo_runner/solo_runner.dart';
import 'package:shorebird_runner/features/start_menu/start_menu.dart';
import 'package:shorebird_runner/features/tournament_lobby/tournament_lobby.dart';
import 'package:shorebird_runner/features/tournament_podium/tournament_podium.dart';

class AppShellScreen extends StatelessWidget {
  const AppShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppShellBloc, AppShellState>(
      builder: (context, state) {
        switch (state.mode) {
          case AppMode.menu:
            return StartScreen(
              onStartSolo: () {
                context
                    .read<AppShellBloc>()
                    .add(const NavigateToMode(AppMode.solo));
              },
              onOpenLobby: () {
                context
                    .read<AppShellBloc>()
                    .add(const NavigateToMode(AppMode.lobby));
              },
            );

          case AppMode.solo:
            return SoloRunnerScreen(
              onBackToMenu: () {
                context
                    .read<AppShellBloc>()
                    .add(const NavigateToMode(AppMode.menu));
              },
            );

          case AppMode.lobby:
            return LobbyScreen(
              onBackToMenu: () {
                context
                    .read<AppShellBloc>()
                    .add(const NavigateToMode(AppMode.menu));
              },
              onRaceStarted: () {
                context
                    .read<AppShellBloc>()
                    .add(const NavigateToMode(AppMode.race));
              },
            );

          case AppMode.race:
            return MultiplayerRaceScreen(
              onLeaveRace: () {
                context.read<ILobbyRepository>().leaveRoom();
                context
                    .read<AppShellBloc>()
                    .add(const NavigateToMode(AppMode.lobby));
              },
              onRaceFinished: (rankings) {
                context.read<AppShellBloc>().add(
                      NavigateToMode(
                        AppMode.podium,
                        podiumRankings: rankings,
                      ),
                    );
              },
            );

          case AppMode.podium:
            final repo = context.read<ILobbyRepository>();
            return TournamentPodiumScreen(
              isHost: repo.isHost,
              rankings: state.podiumRankings,
              onRematch: () {
                repo.requestRematch();
              },
              onReturnToLobby: () {
                repo.leaveRoom();
                context
                    .read<AppShellBloc>()
                    .add(const NavigateToMode(AppMode.lobby));
              },
            );

          case AppMode.boothBattle:
            return BoothBattleScreen(
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
