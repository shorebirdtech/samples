import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/app/app.dart';
import 'package:plume/app/dependencies.dart';
import 'package:plume/core/logging/app_bloc_observer.dart';

/// Sets up error reporting and dependencies, then runs the app.
Future<void> bootstrap() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      final dependencies = AppDependencies.production();
      final crashReporter = dependencies.crashReporter;

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        crashReporter.recordError(
          details.exception,
          details.stack,
          fatal: !kReleaseMode,
        );
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        crashReporter.recordError(error, stack, fatal: true);
        return true;
      };
      Bloc.observer = AppBlocObserver(dependencies.logger, crashReporter);

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      );
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      runApp(App(dependencies: dependencies));
    },
    (error, stack) {
      // Errors before dependencies exist only reach the console.
      debugPrint('Uncaught zone error: $error\n$stack');
    },
  );
}
