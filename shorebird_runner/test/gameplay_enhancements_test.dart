import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shorebird_runner/core/audio/audio.dart';
import 'package:shorebird_runner/core/storage/storage.dart';
import 'package:shorebird_runner/features/solo_runner/bloc/solo_runner_bloc.dart';
import 'package:shorebird_runner/features/solo_runner/widgets/pause_overlay.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';

class _FakeHighScoreRepository implements IHighScoreRepository {
  int _score = 0;

  @override
  Future<int> loadHighScore() async => _score;

  @override
  Future<void> saveHighScore(int score) async {
    _score = score;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initializes and toggles mute state correctly', () async {
      await AudioService.init();
      expect(AudioService.isMuted, isFalse);

      await AudioService.toggleMute();
      expect(AudioService.isMuted, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('patch_rush_audio_muted'), isTrue);

      await AudioService.setMuted(false);
      expect(AudioService.isMuted, isFalse);
      expect(prefs.getBool('patch_rush_audio_muted'), isFalse);
    });
  });

  group('SoloRunnerBloc - Pause / Resume Flow', () {
    late IHighScoreRepository highScoreRepo;
    late SoloRunnerBloc bloc;

    setUp(() {
      highScoreRepo = _FakeHighScoreRepository();
      bloc = SoloRunnerBloc(highScoreRepository: highScoreRepo);
    });

    tearDown(() {
      bloc.close();
    });

    test('transitions between playing and paused smoothly', () async {
      expect(bloc.state.status, SoloGameStatus.initial);

      bloc.add(const StartSoloGame());
      await expectLater(
        bloc.stream,
        emits(
          predicate<SoloRunnerState>(
            (s) => s.status == SoloGameStatus.playing,
          ),
        ),
      );

      bloc.add(const PauseSoloGame());
      await expectLater(
        bloc.stream,
        emits(
          predicate<SoloRunnerState>(
            (s) => s.status == SoloGameStatus.paused,
          ),
        ),
      );

      bloc.add(const ResumeSoloGame());
      await expectLater(
        bloc.stream,
        emits(
          predicate<SoloRunnerState>(
            (s) => s.status == SoloGameStatus.playing,
          ),
        ),
      );
    });
  });

  group('PauseOverlay Widget', () {
    testWidgets('renders telemetry, buttons, and handles callbacks',
        (tester) async {
      bool resumed = false;
      bool restarted = false;
      bool menuReturned = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PauseOverlay(
              score: 1250,
              totalPatches: 18,
              level: GameConfig.levels.first,
              onResume: () => resumed = true,
              onRestart: () => restarted = true,
              onMenu: () => menuReturned = true,
            ),
          ),
        ),
      );

      expect(find.text('GAME PAUSED'), findsOneWidget);
      expect(find.text('1250'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('RESUME RUN'), findsOneWidget);
      expect(find.text('RESTART'), findsOneWidget);
      expect(find.text('LEADERBOARD'), findsOneWidget);

      await tester.tap(find.text('RESUME RUN'));
      await tester.pump();
      expect(resumed, isTrue);

      await tester.tap(find.text('RESTART'));
      await tester.pump();
      expect(restarted, isTrue);

      await tester.tap(find.text('BACK TO MENU'));
      await tester.pump();
      expect(menuReturned, isTrue);
    });
  });
}
