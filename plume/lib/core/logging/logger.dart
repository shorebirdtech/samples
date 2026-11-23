import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

/// Small structured logger. Swap the sink for a remote logging service in a
/// real deployment.
class AppLogger {
  AppLogger({this.minLevel = kReleaseMode ? LogLevel.info : LogLevel.debug});

  final LogLevel minLevel;

  void debug(String message) => _log(LogLevel.debug, message);
  void info(String message) => _log(LogLevel.info, message);
  void warning(String message, [Object? error]) =>
      _log(LogLevel.warning, message, error);
  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.error, message, error, stackTrace);

  void _log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (level.index < minLevel.index) return;
    developer.log(
      message,
      name: 'plume.${level.name}',
      level: 300 + level.index * 300,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
