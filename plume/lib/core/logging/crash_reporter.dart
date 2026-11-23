import 'package:plume/core/logging/logger.dart';

/// Reports unexpected errors. The default implementation logs locally; wire a
/// crash reporting SDK in here for production telemetry.
class CrashReporter {
  CrashReporter(this._logger);

  final AppLogger _logger;
  final _breadcrumbs = <String>[];

  List<String> get breadcrumbs => List.unmodifiable(_breadcrumbs);

  void breadcrumb(String message) {
    _breadcrumbs.add(message);
    if (_breadcrumbs.length > 50) _breadcrumbs.removeAt(0);
  }

  void recordError(Object error, StackTrace? stackTrace, {bool fatal = false}) {
    _logger.error(
      '${fatal ? 'Fatal' : 'Non-fatal'} error '
      '(last steps: ${_breadcrumbs.reversed.take(5).join(' < ')})',
      error,
      stackTrace,
    );
  }
}
