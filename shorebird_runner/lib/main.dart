import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/core/core.dart';
import 'package:shorebird_runner/features/app_shell/bloc/app_shell_bloc.dart';
import 'package:shorebird_runner/features/app_shell/screens/app_shell_screen.dart';
import 'package:shorebird_runner/features/booth_battle/bloc/booth_battle_bloc.dart';
import 'package:shorebird_runner/features/multiplayer_race/bloc/race_bloc.dart';
import 'package:shorebird_runner/features/solo_runner/bloc/solo_runner_bloc.dart';
import 'package:shorebird_runner/features/start_menu/bloc/start_menu_bloc.dart';
import 'package:shorebird_runner/features/tournament_lobby/bloc/lobby_bloc.dart';
import 'package:shorebird_runner/features/tournament_lobby/data/data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PatchRushApp());
}

class PatchRushApp extends StatelessWidget {
  const PatchRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ILobbyRepository>(
          create: (_) => WebSocketLobbyRepository(),
        ),
        RepositoryProvider<IHighScoreRepository>(
          create: (_) => const HighScoreRepository(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final lobbyRepo = context.read<ILobbyRepository>();
          final highScoreRepo = context.read<IHighScoreRepository>();

          final hasInvite =
              kIsWeb && Uri.base.queryParameters.containsKey('room');
          final initialMode = hasInvite ? AppMode.lobby : AppMode.menu;

          return MultiBlocProvider(
            providers: [
              BlocProvider<AppShellBloc>(
                create: (_) => AppShellBloc(initialMode: initialMode),
              ),
              BlocProvider<LobbyBloc>(
                create: (_) => LobbyBloc(lobbyRepository: lobbyRepo),
              ),
              BlocProvider<RaceBloc>(
                create: (_) => RaceBloc(lobbyRepository: lobbyRepo),
              ),
              BlocProvider<SoloRunnerBloc>(
                create: (_) =>
                    SoloRunnerBloc(highScoreRepository: highScoreRepo),
              ),
              BlocProvider<BoothBattleBloc>(
                create: (_) => BoothBattleBloc(),
              ),
              BlocProvider<StartMenuBloc>(
                create: (_) => StartMenuBloc(),
              ),
            ],
            child: MaterialApp(
              title: AppStrings.appTitle,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.darkTheme,
              home: const AppShellScreen(),
            ),
          );
        },
      ),
    );
  }
}
