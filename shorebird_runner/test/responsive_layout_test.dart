import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shorebird_runner/features/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:shorebird_runner/features/leaderboard/data/local_leaderboard_repository.dart';
import 'package:shorebird_runner/features/leaderboard/widgets/leaderboard_dialog.dart';
import 'package:shorebird_runner/features/start_menu/widgets/game_rules_dialog.dart';
import 'package:shorebird_runner/features/solo_runner/widgets/game_over_overlay.dart';
import 'package:shorebird_runner/features/solo_runner/widgets/pause_overlay.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

/// Screen sizes the booth build has to survive: a small phone, a large phone,
/// a tablet and a desktop window.
const _sizes = <String, Size>{
  'small phone': Size(360, 640),
  'large phone': Size(414, 896),
  'tablet portrait': Size(768, 1024),
  'desktop': Size(1440, 900),
};

Future<void> _pumpAt(
  WidgetTester tester,
  Size size,
  Widget child,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  // takeException() only surfaces the error string, which does not say which
  // widget overflowed. Capture the full diagnostics — including the creator
  // chain and source line — before the assertion consumes it.
  // takeException() surfaces only the first error and only its message, which
  // says how many pixels overflowed but not which widget. Collect every error
  // so one run reports the full set of culprits with their source lines,
  // instead of revealing them one cycle at a time.
  // takeException() surfaces only the first error and only its message, which
  // says how many pixels overflowed but not which widget. Log every error with
  // its source line, then chain to the default handler so the test still
  // fails — logging alone would leave an assertion that can never fail.
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    final text = details.toString();
    final widget = RegExp(r'(Row|Column|Flex):file:[^\s)]+').firstMatch(text);
    final amount =
        RegExp(r'overflowed by [\d.]+ pixels on the \w+').firstMatch(text);
    if (amount != null) {
      debugPrint(
        'OVERFLOW | ${amount.group(0)} | ${widget?.group(0) ?? "unknown widget"}',
      );
    }
    previous?.call(details);
  };
  addTearDown(() => FlutterError.onError = previous);

  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('overlays lay out without overflowing', () {
    for (final entry in _sizes.entries) {
      testWidgets('pause overlay on ${entry.key}', (tester) async {
        await _pumpAt(
          tester,
          entry.value,
          PauseOverlay(
            score: 1234,
            totalPatches: 12,
            level: GameConfig.levels.first,
            onResume: () {},
            onRestart: () {},
            onMenu: () {},
          ),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('game over overlay on ${entry.key}', (tester) async {
        await _pumpAt(
          tester,
          entry.value,
          GameOverOverlay(
            score: 4321,
            highScore: 9000,
            totalPatches: 21,
            level: GameConfig.levels.last,
            onRestart: () {},
            onMenu: () {},
          ),
        );
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('dialogs lay out without overflowing', () {
    for (final entry in _sizes.entries) {
      testWidgets('game rules on ${entry.key}', (tester) async {
        await _pumpAt(tester, entry.value, const GameRulesDialog());
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('leaderboard on ${entry.key}', (tester) async {
        // Reads LeaderboardBloc from context on init, so it needs a real one;
        // the local repository is what the rest of the suite uses.
        await _pumpAt(
          tester,
          entry.value,
          BlocProvider(
            create: (_) => LeaderboardBloc(
              repository: const LocalLeaderboardRepository(),
            ),
            child: const LeaderboardDialog(),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('lane layout adapts to the viewport', () {
    for (final entry in _sizes.entries) {
      test('lanes stay on screen on ${entry.key}', () {
        final size = entry.value;
        GameConfig.updateDimensions(size.width, size.height);

        for (final laneX in GameConfig.nearLaneX) {
          expect(
            laneX,
            inInclusiveRange(0, size.width),
            reason: 'near lane off screen on ${entry.key}',
          );
        }
        for (final laneX in GameConfig.farLaneX) {
          expect(laneX, inInclusiveRange(0, size.width));
        }
        expect(GameConfig.horizonY, lessThan(GameConfig.nearY));
        expect(GameConfig.nearY, lessThanOrEqualTo(size.height));
        // The player must not be wider than a lane, or lanes visually merge.
        final laneWidth =
            (GameConfig.nearLaneX[1] - GameConfig.nearLaneX[0]).abs();
        expect(GameConfig.playerNearSize, lessThan(laneWidth));
      });
    }
  });
}
