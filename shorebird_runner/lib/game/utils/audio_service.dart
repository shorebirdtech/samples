import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_service_stub.dart'
    if (dart.library.js_interop) 'audio_service_web.dart';

/// Cross-platform arcade sound service.
/// Uses Web Audio synthesis on web and fails silently on other platforms.
class AudioService {
  AudioService._();

  static const String _prefMutedKey = 'patch_rush_audio_muted';
  static final ValueNotifier<bool> isMutedNotifier = ValueNotifier<bool>(false);

  static bool get isMuted => isMutedNotifier.value;

  /// Loads saved mute preference from storage.
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final muted = prefs.getBool(_prefMutedKey) ?? false;
      isMutedNotifier.value = muted;
    } catch (_) {
      // Memory fallback if storage is restricted
    }
  }

  /// Toggles mute state and persists preference.
  static Future<void> toggleMute() async {
    await setMuted(!isMutedNotifier.value);
  }

  /// Sets mute state explicitly.
  static Future<void> setMuted(bool muted) async {
    isMutedNotifier.value = muted;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefMutedKey, muted);
    } catch (_) {
      // Graceful fallback
    }
  }

  static void playSwitch() => _play('switch');
  static void playSelect() => _play('switch');
  static void playPatch() => _play('patch');
  static void playCombo() => _play('combo');
  static void playLevelUp() => _play('levelup');
  static void playJump() => _play('jump');
  static void playSlide() => _play('slide');
  static void playPowerUp() => _play('powerup');
  static void playMiss() => _play('miss');
  static void playStomp() => _play('stomp');
  static void playCrash() => _play('crash');
  static void playCloseCall() => _play('slide');

  static void _play(String soundType) {
    if (isMuted) return;
    playArcadeSoundImpl(soundType);
  }
}
