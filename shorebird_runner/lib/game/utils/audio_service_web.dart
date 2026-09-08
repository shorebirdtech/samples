import 'dart:js_interop';

@JS('playArcadeSound')
external void _playArcadeSound(JSString type);

void playArcadeSoundImpl(String soundType) {
  try {
    _playArcadeSound(soundType.toJS);
  } catch (_) {
    // Graceful fallback if Web Audio is blocked or not available
  }
}
