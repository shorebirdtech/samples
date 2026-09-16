import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shorebird_runner/game/components/obstacle.dart';
import 'package:shorebird_runner/game/components/obstacle_type.dart';
import 'package:shorebird_runner/game/components/perspective_helper.dart';
import 'package:shorebird_runner/game/components/player.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

/// Advances the player by [seconds] in frame-sized steps.
void _advance(Player player, double seconds) {
  const step = 1 / 60;
  for (double t = 0; t < seconds; t += step) {
    player.update(step);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('jump input buffering', () {
    test('a jump pressed just before landing still fires', () {
      final player = Player();
      player.jump();
      expect(player.isJumping, isTrue);

      // Press again while airborne, close enough to landing to be buffered.
      _advance(player, 0.52);
      expect(player.isJumping, isTrue, reason: 'still mid-jump');
      player.jump();

      // Land, then give the buffer a frame to fire.
      _advance(player, 0.15);
      expect(
        player.isJumping,
        isTrue,
        reason: 'buffered press should start a new jump on landing',
      );
    });

    test('a jump pressed far too early is not held forever', () {
      final player = Player();
      player.jump();
      // Early in the arc, well outside the buffer window.
      _advance(player, 0.05);
      player.jump();

      // Land and wait past the buffer.
      _advance(player, 0.75);
      expect(
        player.isJumping,
        isFalse,
        reason: 'a stale press should expire rather than queue a jump',
      );
    });
  });

  test('a freshly spawned obstacle is inside the patch-blocking window', () {
    // The spawn guard treats obstacles below depth 0.35 as blocking their
    // lane. Obstacles enter play at depth 0, so a patch spawned in the same
    // tick would otherwise land behind one.
    final obstacle = Obstacle(
      lane: 1,
      type: ObstacleType.appStore,
      rng: Random(1),
    );
    expect(obstacle.depth, lessThan(0.35));
  });

  group('lane changes move the player before the lane index catches up', () {
    test('the player is already in the new lane while currentLane lags', () {
      GameConfig.updateDimensions(430, 932);
      final player = Player(currentLane: 1);
      final lane0X = PerspectiveHelper.lanePosition(0, 1.0).dx;
      final lane1X = PerspectiveHelper.lanePosition(1, 1.0).dx;

      player.moveLeft();

      // Step until the index flips, remembering where the player was on the
      // last frame that still reported the old lane. Driving it this way keeps
      // the test honest if laneChangeDuration is ever retuned.
      var lastX = player.worldPosition.dx;
      var frames = 0;
      while (player.currentLane == 1 && frames < 200) {
        lastX = player.worldPosition.dx;
        player.update(1 / 60);
        frames++;
      }

      expect(player.currentLane, 0, reason: 'the tween should finish');
      expect(
        (lastX - lane0X).abs(),
        lessThan((lastX - lane1X).abs()),
        reason: 'on the last frame reporting lane 1 the player was already '
            'standing in lane 0 — gating collisions on currentLane is what '
            'hit players for obstacles they had visibly dodged',
      );
    });

    test('an out-of-range lane is clamped onto the track', () {
      GameConfig.updateDimensions(430, 932);
      final player = Player(currentLane: 1);

      // Tap steering derives a lane from an x coordinate, so a bad value must
      // never walk the player off the edge of the road.
      player.moveToLane(7);
      _advance(player, 0.5);
      expect(player.currentLane, GameConfig.laneCount - 1);

      player.moveToLane(-3);
      _advance(player, 0.5);
      expect(player.currentLane, 0);
    });
  });
}
