import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shorebird_runner/features/leaderboard/leaderboard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LeaderboardEntryModel', () {
    test('toJson and fromJson work symmetrically', () {
      final now = DateTime.now();
      final entry = LeaderboardEntryModel(
        id: 42,
        playerName: 'Abhishek Doshi',
        score: 4500,
        patches: 72,
        organization: 'Shorebird',
        event: 'Droidcon London',
        createdAt: now,
      );

      final json = entry.toJson();
      expect(json['id'], 42);
      expect(json['player_name'], 'Abhishek Doshi');
      expect(json['score'], 4500);
      expect(json['patches'], 72);
      expect(json['organization'], 'Shorebird');
      expect(json['event'], 'Droidcon London');

      final parsed = LeaderboardEntryModel.fromJson(json);
      expect(parsed.id, 42);
      expect(parsed.playerName, 'Abhishek Doshi');
      expect(parsed.score, 4500);
      expect(parsed.patches, 72);
      expect(parsed.organization, 'Shorebird');
      expect(parsed.event, 'Droidcon London');
    });
  });

  group('LocalLeaderboardRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('retrieves seeded benchmark scores on initial run', () async {
      const repo = LocalLeaderboardRepository();
      final scores = await repo.getScores();

      expect(scores, isNotEmpty);
      expect(scores.first.score, greaterThan(0));
      // Verify sorted descending
      for (int i = 0; i < scores.length - 1; i++) {
        expect(scores[i].score, greaterThanOrEqualTo(scores[i + 1].score));
      }
    });

    test('filters scores by event', () async {
      const repo = LocalLeaderboardRepository();
      final droidconScores = await repo.getScores(event: 'Droidcon London');

      expect(droidconScores, isNotEmpty);
      for (final s in droidconScores) {
        expect(s.event.toLowerCase(), 'droidcon london');
      }
    });

    test('submits new score and preserves ranking order', () async {
      const repo = LocalLeaderboardRepository();
      final newChamp = LeaderboardEntryModel(
        playerName: 'Top Player',
        score: 99999,
        patches: 200,
        organization: 'Shorebird HighFlyers',
        event: 'Droidcon London',
        createdAt: DateTime.now(),
      );

      await repo.submitScore(newChamp);
      final scores = await repo.getScores();

      expect(scores.first.playerName, 'Top Player');
      expect(scores.first.score, 99999);
    });

    test('extracts distinct events', () async {
      const repo = LocalLeaderboardRepository();
      final events = await repo.getEvents();

      expect(events, contains('Droidcon London'));
      expect(events, contains('FlutterCon'));
      expect(events, contains('Global'));
    });
  });

  group('LeaderboardBloc', () {
    late LocalLeaderboardRepository repo;
    late LeaderboardBloc bloc;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repo = const LocalLeaderboardRepository();
      bloc = LeaderboardBloc(repository: repo);
    });

    tearDown(() {
      bloc.close();
    });

    test('fetches leaderboard scores and populates state', () async {
      bloc.add(const FetchLeaderboard());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<LeaderboardState>(
            (state) =>
                state.status == LeaderboardStatus.success &&
                state.allEntries.isNotEmpty &&
                state.filteredEntries.isNotEmpty &&
                state.availableEvents.contains('All Events'),
          ),
        ),
      );
    });

    test('filters leaderboard by event', () async {
      bloc.add(const FetchLeaderboard());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<LeaderboardState>(
            (state) => state.status == LeaderboardStatus.success,
          ),
        ),
      );

      bloc.add(const FilterLeaderboardByEvent('FlutterCon'));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<LeaderboardState>(
            (state) =>
                state.selectedEvent == 'FlutterCon' &&
                state.filteredEntries.every(
                  (e) => e.event.toLowerCase() == 'fluttercon',
                ),
          ),
        ),
      );
    });

    test('searches leaderboard by player name or organization', () async {
      bloc.add(const FetchLeaderboard());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<LeaderboardState>(
            (state) => state.status == LeaderboardStatus.success,
          ),
        ),
      );

      bloc.add(const SearchLeaderboard('Sarah'));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<LeaderboardState>(
            (state) =>
                state.searchQuery == 'Sarah' &&
                state.filteredEntries.every(
                  (e) =>
                      e.playerName.contains('Sarah') ||
                      e.organization.contains('Sarah'),
                ),
          ),
        ),
      );
    });
  });
}
