import 'audio_service_stub.dart'
    if (dart.library.js_interop) 'audio_service_web.dart';

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
  static void playSlide() => _play('slide');
  static void playPowerUp() => _play('powerup');
  static void playMiss() => _play('miss');
  static void playStomp() => _play('stomp');
  static void playCrash() => _play('crash');

  static void _play(String soundType) {
    playArcadeSoundImpl(soundType);
  }
}
