import 'package:plume/core/logging/logger.dart';

/// Product analytics facade. Events go to the log until a vendor is wired in.
class Analytics {
  Analytics(this._logger);

  final AppLogger _logger;

  void screen(String name) => _logger.debug('screen_view: $name');

  void event(String name, [Map<String, Object?> params = const {}]) =>
      _logger.info('event: $name $params');
}
