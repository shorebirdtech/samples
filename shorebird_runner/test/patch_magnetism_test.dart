import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shorebird_runner/game/components/patch.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';
import 'package:shorebird_runner/game/utils/high_score_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('hot reload magnetism releases the patch', () {
    test('a patch stops being magnetized once the pull stops', () {
      GameConfig.updateDimensions(430, 932);
      final patch = Patch(lane: 0, rng: Random(7));

      patch.attractTowards(1, 1 / 60);
      patch.update(1 / 60);
      expect(patch.isBeingMagnetized, isTrue, reason: 'pull is active');

      // Hot Reload ends: the game simply stops calling attractTowards.
      patch.update(1 / 60);
      expect(
        patch.isBeingMagnetized,
        isFalse,
        reason: 'nothing cleared this before, so the patch kept a permanent '
            '1.18x forward boost and its magnet glow for the rest of its life',
      );
    });

    test('a released patch travels at the same speed as an untouched one', () {
      GameConfig.updateDimensions(430, 932);
      final pulled = Patch(lane: 0, rng: Random(7));
      final untouched = Patch(lane: 0, rng: Random(7));

      // One frame of pull, then the booster expires for both.
      pulled.attractTowards(0, 1 / 60);
      pulled.update(1 / 60);
      untouched.update(1 / 60);

      // The pulled patch is legitimately one frame of boost ahead, and stays
      // ahead by that fixed amount. What must not happen is the gap *growing*,
      // which is what a stuck magnet flag caused. So compare how far each
      // travels from here rather than their absolute positions.
      final pulledStart = pulled.depth;
      final untouchedStart = untouched.depth;
      for (int i = 0; i < 30; i++) {
        pulled.update(1 / 60);
        untouched.update(1 / 60);
      }

      expect(
        pulled.depth - pulledStart,
        closeTo(untouched.depth - untouchedStart, 1e-9),
        reason: 'a patch that was briefly pulled must not keep outrunning the '
            'rest once Hot Reload is over',
      );
    });
  });

  test('the high score survives the move off the legacy key', () async {
    SharedPreferences.setMockInitialValues({
      'flutter.patch_rush_high_score': 4200,
    });

    expect(
      await HighScoreService.load(),
      4200,
      reason: 'a booth machine mid-event must not appear to lose its score',
    );

    // And it is carried onto the key the rest of the app reads.
    SharedPreferences.setMockInitialValues({
      'flutter.patch_rush_high_score': 4200,
      'flutter.shorebird_runner_high_score': 9000,
    });
    expect(
      await HighScoreService.load(),
      9000,
      reason: 'the newer key wins when it is already ahead',
    );
  });
}
