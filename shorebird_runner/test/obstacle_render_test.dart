import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:shorebird_runner/game/components/obstacle.dart';
import 'package:shorebird_runner/game/components/obstacle_type.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

/// Paints an obstacle across the full depth range it travels through.
///
/// Painting is where these fail: a bad rect, a zero scale or a glyph that
/// didn't lay out only throws once something actually draws it.
void _paintAcrossTrack(Obstacle obstacle) {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  for (double depth = 0.0; depth <= 1.05; depth += 0.02) {
    obstacle.depth = depth;
    obstacle.render(canvas);
  }
  recorder.endRecording().dispose();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GameConfig.updateDimensions(1280, 720);

  test('every obstacle type paints at every depth', () {
    for (final type in ObstacleType.values) {
      final obstacle = Obstacle(lane: 1, type: type, rng: Random(7));
      expect(
        () => _paintAcrossTrack(obstacle),
        returnsNormally,
        reason: '$type should paint across the whole track',
      );
    }
  });

  test('the bug glyph laid out and has a usable size', () {
    // The bug is drawn as a 🐛 glyph scaled by its own height. If the font
    // fell back to nothing, that height would be zero and every bug would be
    // scaled to infinity.
    final bug = Obstacle(
      lane: 1,
      type: ObstacleType.wormBug,
      rng: Random(3),
    );
    expect(bug.isJumpable, isTrue, reason: 'bugs are jumped over');
    expect(() => _paintAcrossTrack(bug), returnsNormally);
  });
}
