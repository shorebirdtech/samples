import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shorebird_runner/game/shorebird_runner_game.dart';

/// Dart-side render cost. This does not measure GPU time, but it does measure
/// the work of building every frame's draw calls, which is where a runner with
/// a few hundred procedural paints actually spends its budget.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('render cost', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final game = ShorebirdRunnerGame(onGameOver: (_, __, ___) {});
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: GameWidget(game: game))),
      );
      final deadline = DateTime.now().add(const Duration(seconds: 15));
      while (!game.isLoaded && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 25));
      }
    });
    expect(game.isLoaded, isTrue);

    // Let the world populate so obstacles/patches are on screen.
    for (int i = 0; i < 240; i++) {
      game.update(1 / 60);
    }

    const frames = 600;
    final sw = Stopwatch()..start();
    for (int i = 0; i < frames; i++) {
      game.update(1 / 60);
      final recorder = PictureRecorder();
      game.renderTree(Canvas(recorder));
      recorder.endRecording().dispose();
    }
    sw.stop();
    final perFrame = sw.elapsedMicroseconds / frames;
    debugPrint('BENCH frames=$frames total=${sw.elapsedMilliseconds}ms '
        'perFrame=${perFrame.toStringAsFixed(1)}us '
        'budget60=16666us budget120=8333us');

    // 600 render passes over a live game is a real stress test of every paint
    // path, so assert that rather than the frame count, which cannot fail.
    expect(tester.takeException(), isNull);

    // Nobody is dodging, so the run has almost certainly crashed by now, and
    // _triggerCrash schedules the game-over callback 650ms after the high
    // score save resolves. Left pending, the binding asserts on teardown.
    // Drive the save to completion for real first, then advance the fake
    // clock past the delay — the same drain game_smoke_test.dart needs.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  });
}
