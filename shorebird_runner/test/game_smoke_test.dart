import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shorebird_runner/game/shorebird_runner_game.dart';

/// Drives the game through a real [GameWidget] so it is properly mounted.
///
/// Mounting matters: an unmounted Flame component adds children immediately
/// instead of queueing them, so spawning during a frame would corrupt the
/// iteration and throw in a way the real app never does.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The game loads its high score on start; without this the plugin channel
  // throws and onLoad never completes.
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('plays for several seconds without throwing', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final game = ShorebirdRunnerGame(onGameOver: (_, __, ___) {});

    // onLoad does real async work (loading the stored high score), which a
    // widget test only allows inside runAsync; without this the game sits on
    // its loading future instead of ticking.
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: GameWidget(game: game))),
      );
      // Wait for loading to actually finish rather than guessing a delay: a
      // fixed wait is long enough when this test runs alone and too short when
      // the whole suite is competing for the machine.
      final deadline = DateTime.now().add(const Duration(seconds: 15));
      while (!game.isLoaded && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 25));
      }
    });
    expect(game.isLoaded, isTrue, reason: 'game never finished loading');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    // Roughly ten seconds of play: obstacles and patches spawn, cross the
    // track and are recycled, and the HUD ticks over. Pump until the loop has
    // demonstrably run rather than asserting after a fixed count — how many
    // frames it takes to start varies with machine load.
    for (int i = 0; i < 1800 && game.score == 0 && !game.isOver; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    for (int i = 0; i < 600; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(tester.takeException(), isNull);
    // Either survival points accrued or the run ended in a crash. Asserting a
    // score alone was wrong: update() returns early once the game is over, so
    // an unlucky run that crashes in the opening frames legitimately scores
    // zero. What must hold is that the loop actually ran.
    expect(
      game.score > 0 || game.isOver,
      isTrue,
      reason: 'game loop should have advanced '
          '(loaded=${game.isLoaded} over=${game.isOver} '
          'score=${game.score} patches=${game.totalPatches})',
    );

    // Crashing schedules a game-over callback 650ms later, and that timer is
    // only created once the high-score save resolves. If the run ended just
    // after a crash, the timer would still be pending when the tree is
    // disposed and the binding asserts on it. Let the save settle for real
    // first, then advance the fake clock past the delay.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  });
}
