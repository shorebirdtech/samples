// ignore_for_file: avoid_web_libraries_in_flutter
import 'package:flutter/foundation.dart';
import 'dart:js_interop';

@JS('playArcadeSound')
external void _playArcadeSound(JSString type);

/// Cross-platform arcade sound service.
/// Uses Web Audio synthesis on web and fails silently on other platforms.
class AudioService {
  AudioService._();

  static void playSwitch() => _play('switch');
  static void playSelect() => _play('switch');
  static void playPatch() => _play('patch');
  static void playCombo() => _play('combo');
  static void playLevelUp() => _play('levelup');
  static void playJump() => _play('jump');
  static void playMiss() => _play('miss');
  static void playStomp() => _play('stomp');
  static void playCrash() => _play('crash');

  static void _play(String soundType) {
    if (!kIsWeb) return;
    try {
      _playArcadeSound(soundType.toJS);
    } catch (_) {
      // Graceful fallback if Web Audio is blocked or not available
    }
  }
}
