import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shorebird_runner/features/leaderboard/leaderboard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  LeaderboardEntryModel run(String name, int score) => LeaderboardEntryModel(
        playerName: name,
        score: score,
        event: 'FlutterCon',
        createdAt: DateTime.utc(2026, 10, 8),
      );

  late bool online;
  late List<Map<String, dynamic>> posted;

  SupabaseLeaderboardRepository repo() => SupabaseLeaderboardRepository(
        supabaseUrl: 'https://example.supabase.co',
        supabaseAnonKey: 'anon',
        enabledInDebug: true,
        httpClient: MockClient((request) async {
          if (!online) throw http.ClientException('offline');
          posted.add(jsonDecode(request.body) as Map<String, dynamic>);
          return http.Response('', 204);
        }),
      );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    online = true;
    posted = [];
  });

  test('posts a score straight away when online', () async {
    await repo().submitScore(run('Ada', 1200));

    expect(posted.single['p_score'], 1200);
    expect(await repo().syncPendingScores(), 0);
  });

  test('queues an offline score and posts it once back online', () async {
    online = false;
    await expectLater(
      repo().submitScore(run('Ada', 12000)),
      throwsA(isA<ScoreSyncException>()),
    );
    expect(await repo().syncPendingScores(), 1);

    online = true;
    expect(await repo().syncPendingScores(), 0);
    expect(posted.single['p_player_name'], 'Ada');
    expect(posted.single['p_score'], 12000);
  });

  test('only the best queued score per player is posted', () async {
    online = false;
    for (final score in [500, 12000, 800]) {
      await expectLater(
        repo().submitScore(run('Ada', score)),
        throwsA(isA<ScoreSyncException>()),
      );
    }

    online = true;
    await repo().syncPendingScores();
    expect(posted.map((p) => p['p_score']), [12000]);
  });

  test('backfills scores stored locally before the outbox existed', () async {
    // A run from an older build: saved locally, never posted, and no queue.
    await const LocalLeaderboardRepository().submitScore(run('Ada', 12000));

    expect(await repo().syncPendingScores(), 0);
    // Seeded benchmark rows are not real runs and must not be posted.
    expect(posted.map((p) => p['p_player_name']), ['Ada']);

    posted.clear();
    await repo().syncPendingScores();
    expect(posted, isEmpty, reason: 'backfill runs only once');
  });

  test('bloc flags the failure and clears it after a successful retry',
      () async {
    online = false;
    final bloc = LeaderboardBloc(repository: repo());
    addTearDown(bloc.close);

    bloc.add(RecordScore(run('Ada', 12000)));
    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<LeaderboardState>(
          (s) =>
              s.scoreSyncStatus == ScoreSyncStatus.failed &&
              s.pendingScore?.score == 12000,
        ),
      ),
    );

    online = true;
    bloc.add(const RetryScoreSync());
    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<LeaderboardState>(
          (s) =>
              s.scoreSyncStatus == ScoreSyncStatus.synced &&
              s.pendingScore == null,
        ),
      ),
    );
    expect(posted.single['p_score'], 12000);
  });
}
