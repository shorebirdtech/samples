import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plume/core/logging/crash_reporter.dart';
import 'package:plume/core/logging/logger.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver(this._logger, this._crashReporter);

  final AppLogger _logger;
  final CrashReporter _crashReporter;

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _logger.debug('${bloc.runtimeType} -> ${change.nextState.runtimeType}');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _crashReporter.recordError(error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
