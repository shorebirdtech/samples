import 'package:flutter_test/flutter_test.dart';
import 'package:shorebird_runner/game/components/player.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

/// Seconds an obstacle takes to travel from the horizon to the player.
///
/// Obstacles advance `scrollSpeed * 0.54` of the track per second, so this is
/// the whole window a player has to see one and react.
double _reactionWindow(int patches) =>
    1 / (GameConfig.scrollSpeed(patches) * 0.54);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every tier leaves at least a second to react', () {
    for (final level in GameConfig.levels) {
      final window = _reactionWindow(level.patchThreshold);
      expect(
        window,
        greaterThanOrEqualTo(1.0),
        reason: '${level.name} gives only '
            '${window.toStringAsFixed(2)}s from horizon to player',
      );
    }
  });

  test('difficulty still ramps across tiers', () {
    // The floor must not flatten progression: each tier should still be
    // quicker than the one before it.
    final windows = [
      for (final level in GameConfig.levels)
        _reactionWindow(level.patchThreshold),
    ];
    for (int i = 1; i < windows.length; i++) {
      expect(
        windows[i],
        lessThan(windows[i - 1]),
        reason: 'tier ${i + 1} should be tighter than tier $i',
      );
    }
  });

  test('jump progress peaks in the middle of the arc', () {
    final player = Player();
    expect(player.jumpProgress, 0.0, reason: 'grounded');

    player.jump();
    // Step to roughly the top of the arc.
    for (int i = 0; i < 19; i++) {
      player.update(1 / 60);
    }
    expect(
      (player.jumpProgress - 0.5).abs(),
      lessThan(0.18),
      reason: 'mid-arc should fall inside the apex bonus window',
    );

    // Just after take-off is outside it.
    final early = Player()..jump();
    early.update(1 / 60);
    expect((early.jumpProgress - 0.5).abs(), greaterThan(0.18));
  });
}
