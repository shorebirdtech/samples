import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/core/core.dart';
import 'package:shorebird_runner/features/app_shell/bloc/app_shell_bloc.dart';
import 'package:shorebird_runner/features/app_shell/screens/app_shell_screen.dart';
import 'package:shorebird_runner/features/lead_capture/lead_capture.dart';
import 'package:shorebird_runner/features/leaderboard/leaderboard.dart';
import 'package:shorebird_runner/features/solo_runner/bloc/solo_runner_bloc.dart';
import 'package:shorebird_runner/features/start_menu/bloc/start_menu_bloc.dart';

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
        RepositoryProvider<IHighScoreRepository>(
          create: (_) => const HighScoreRepository(),
        ),
        RepositoryProvider<ILeadRepository>(
          create: (_) => SupabaseLeadRepository(),
        ),
        RepositoryProvider<ILeaderboardRepository>(
          create: (_) => SupabaseLeaderboardRepository(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final highScoreRepo = context.read<IHighScoreRepository>();
          final leadRepo = context.read<ILeadRepository>();
          final leaderboardRepo = context.read<ILeaderboardRepository>();

          return MultiBlocProvider(
            providers: [
              BlocProvider<AppShellBloc>(
                create: (_) => AppShellBloc(initialMode: AppMode.menu),
              ),
              BlocProvider<LeadCaptureBloc>(
                create: (_) => LeadCaptureBloc(leadRepository: leadRepo),
              ),
              BlocProvider<SoloRunnerBloc>(
                create: (_) =>
                    SoloRunnerBloc(highScoreRepository: highScoreRepo),
              ),
              BlocProvider<StartMenuBloc>(
                create: (_) => StartMenuBloc(),
              ),
              BlocProvider<LeaderboardBloc>(
                create: (_) => LeaderboardBloc(repository: leaderboardRepo),
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
