import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shorebird_runner/game/components/obstacle.dart';
import 'package:shorebird_runner/game/components/obstacle_type.dart';
import 'package:shorebird_runner/game/components/player.dart';

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
}
