import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages booth event configuration (e.g. "FlutterCon", "Google I/O").
/// Persists across browser sessions in SharedPreferences.
class EventConfigService {
  static const _eventKey = 'shorebird_runner_booth_event';

  const EventConfigService();

  Future<String> getActiveEvent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_eventKey) ?? '';
    } catch (e) {
      debugPrint('[EventConfigService] Error reading active event: $e');
      return '';
    }
  }

  Future<void> setActiveEvent(String eventName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trimmed = eventName.trim();
      if (trimmed.isEmpty) {
        await prefs.remove(_eventKey);
        debugPrint('[EventConfigService] Cleared active event.');
      } else {
        await prefs.setString(_eventKey, trimmed);
        debugPrint('[EventConfigService] Set active event: $trimmed');
      }
    } catch (e) {
      debugPrint('[EventConfigService] Error saving active event: $e');
    }
  }
}
