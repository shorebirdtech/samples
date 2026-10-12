import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shorebird_runner/features/leaderboard/data/i_leaderboard_repository.dart';
import 'package:shorebird_runner/features/leaderboard/data/local_leaderboard_repository.dart';
import 'package:shorebird_runner/features/leaderboard/models/leaderboard_entry_model.dart';

/// Supabase PostgREST implementation for Leaderboard.
class SupabaseLeaderboardRepository implements ILeaderboardRepository {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final http.Client _httpClient;
  final LocalLeaderboardRepository _localFallback;

  SupabaseLeaderboardRepository({
    String? supabaseUrl,
    String? supabaseAnonKey,
    http.Client? httpClient,
    LocalLeaderboardRepository? localFallback,
    @visibleForTesting bool enabledInDebug = false,
  })  : _enabledInDebug = enabledInDebug,
        supabaseUrl = supabaseUrl ??
            const String.fromEnvironment(
              'SUPABASE_URL',
              defaultValue: '',
            ),
        supabaseAnonKey = supabaseAnonKey ??
            const String.fromEnvironment(
              'SUPABASE_ANON_KEY',
              defaultValue: '',
            ),
        _httpClient = httpClient ?? http.Client(),
        _localFallback = localFallback ?? const LocalLeaderboardRepository();

  final bool _enabledInDebug;

  bool get isConfigured =>
      (!kDebugMode || _enabledInDebug) &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;

  @override
  Future<List<LeaderboardEntryModel>> getScores({String? event}) async {
    if (!isConfigured) {
      return _localFallback.getScores(event: event);
    }

    try {
      final sanitizedUrl = supabaseUrl.endsWith('/')
          ? supabaseUrl.substring(0, supabaseUrl.length - 1)
          : supabaseUrl;

      final queryParams = <String>[
        'select=*',
        'order=score.desc',
        'limit=100',
      ];

      if (event != null && event.trim().isNotEmpty && event != 'All Events') {
        queryParams.add('event=eq.${Uri.encodeQueryComponent(event.trim())}');
      }

      final uri = Uri.parse(
        '$sanitizedUrl/rest/v1/leaderboard?${queryParams.join('&')}',
      );

      final response = await _httpClient.get(
        uri,
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final list = jsonDecode(response.body) as List<dynamic>;
        final entries = list
            .map(
              (e) => LeaderboardEntryModel.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();

        // If remote is empty, fall back to local seed so new users see benchmark targets
        if (entries.isEmpty) {
          return await _localFallback.getScores(event: event);
        }

        return entries;
      } else {
        debugPrint(
          '[SupabaseLeaderboardRepository] Status ${response.statusCode}: ${response.body}. Using local fallback.',
        );
        return await _localFallback.getScores(event: event);
      }
    } catch (e) {
      debugPrint(
        '[SupabaseLeaderboardRepository] Network exception: $e. Using local fallback.',
      );
      return await _localFallback.getScores(event: event);
    }
  }

  @override
  Future<void> submitScore(LeaderboardEntryModel entry) async {
    // Always persist to local storage as well
    await _localFallback.submitScore(entry);

    if (!isConfigured) return;

    // Queue first so the score survives a failed post (or the app closing)
    // and is retried automatically once the device is back online.
    final prefs = await SharedPreferences.getInstance();
    await _savePending(prefs, _mergeBest([..._loadPending(prefs), entry]));

    await syncPendingScores();

    final stillPending = _loadPending(
      prefs,
    ).any((e) => e.identityKey == entry.identityKey && e.score >= entry.score);
    if (stillPending) {
      throw const ScoreSyncException(
        'Score saved locally; it will be posted once back online.',
      );
    }
  }

  Future<int>? _syncInFlight;

  @override
  Future<int> syncPendingScores() {
    if (!isConfigured) return Future.value(0);
    // Concurrent callers (startup, periodic retry, a new run) share one flush
    // so the same score isn't posted twice.
    return _syncInFlight ??=
        _flushPending().whenComplete(() => _syncInFlight = null);
  }

  Future<int> _flushPending() async {
    final prefs = await SharedPreferences.getInstance();
    await _backfillLocalScores(prefs);

    final pending = _loadPending(prefs);
    if (pending.isEmpty) return 0;

    final remaining = <LeaderboardEntryModel>[];
    var offline = false;
    for (final entry in pending) {
      if (offline) {
        remaining.add(entry);
        continue;
      }
      switch (await _postScore(entry)) {
        case _PostResult.posted:
          debugPrint(
            '[SupabaseLeaderboardRepository] Score recorded on Supabase: ${entry.playerName} -> ${entry.score}',
          );
        case _PostResult.rejected:
          // Retrying a request Supabase refuses would never succeed and would
          // block the rest of the queue, so drop it.
          break;
        case _PostResult.retryLater:
          // Most likely offline: stop hammering and keep the rest queued.
          offline = true;
          remaining.add(entry);
      }
    }

    // A run may have been queued while this flush was posting; keep it.
    final queuedMeanwhile =
        _loadPending(prefs).where((e) => !pending.contains(e));
    final updated = _mergeBest([...remaining, ...queuedMeanwhile]);
    await _savePending(prefs, updated);
    return updated.length;
  }

  Future<_PostResult> _postScore(LeaderboardEntryModel entry) async {
    try {
      final sanitizedUrl = supabaseUrl.endsWith('/')
          ? supabaseUrl.substring(0, supabaseUrl.length - 1)
          : supabaseUrl;
      final headers = {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal',
      };
      final payload = entry.toJson()..remove('id');

      // `submit_score` keeps one row per player per event and only replaces
      // it when the new score is higher (see README for the SQL).
      var response = await _httpClient
          .post(
            Uri.parse('$sanitizedUrl/rest/v1/rpc/submit_score'),
            headers: headers,
            body: jsonEncode({
              for (final e in payload.entries) 'p_${e.key}': e.value,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) {
        debugPrint(
          '[SupabaseLeaderboardRepository] submit_score RPC not found; '
          'falling back to a plain insert. Run the README SQL to stop '
          'duplicate leaderboard rows.',
        );
        response = await _httpClient
            .post(
              Uri.parse('$sanitizedUrl/rest/v1/leaderboard'),
              headers: headers,
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 10));
      }

      final status = response.statusCode;
      if (status >= 200 && status < 300) return _PostResult.posted;

      debugPrint(
        '[SupabaseLeaderboardRepository] Error $status: ${response.body}',
      );
      final transient = status >= 500 || status == 408 || status == 429;
      return transient ? _PostResult.retryLater : _PostResult.rejected;
    } catch (e) {
      debugPrint('[SupabaseLeaderboardRepository] Network exception: $e');
      return _PostResult.retryLater;
    }
  }

  /// Scores recorded before the outbox existed were only kept locally when
  /// the post failed. Queue the real (non-seed) ones once; `submit_score`
  /// keeps the best per player, so re-posting a synced score is harmless.
  Future<void> _backfillLocalScores(SharedPreferences prefs) async {
    if (prefs.getBool(_backfillDoneKey) ?? false) return;
    final local = await _localFallback.getScores();
    // Seeded benchmark rows carry ids; scores from real runs never do.
    final played = local.where((e) => e.id == null);
    await _savePending(
      prefs,
      _mergeBest([..._loadPending(prefs), ...played]),
    );
    await prefs.setBool(_backfillDoneKey, true);
  }

  static const _pendingKey = 'shorebird_runner_pending_scores_v1';
  static const _backfillDoneKey = 'shorebird_runner_pending_backfill_done_v1';

  List<LeaderboardEntryModel> _loadPending(SharedPreferences prefs) {
    final raw = prefs.getString(_pendingKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map(
            (e) => LeaderboardEntryModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _savePending(
    SharedPreferences prefs,
    List<LeaderboardEntryModel> entries,
  ) =>
      prefs.setString(
        _pendingKey,
        jsonEncode(entries.map((e) => e.toJson()).toList()),
      );

  /// Keeps only each player's best score per event, mirroring `submit_score`.
  static List<LeaderboardEntryModel> _mergeBest(
    Iterable<LeaderboardEntryModel> entries,
  ) {
    final best = <String, LeaderboardEntryModel>{};
    for (final e in entries) {
      final current = best[e.identityKey];
      if (current == null || e.score > current.score) best[e.identityKey] = e;
    }
    return best.values.toList();
  }

  @override
  Future<List<String>> getEvents() async {
    final scores = await getScores();
    final events = <String>{};
    for (final s in scores) {
      if (s.event.trim().isNotEmpty) {
        events.add(s.event.trim());
      }
    }
    // Also include events from local fallback
    final localEvents = await _localFallback.getEvents();
    events.addAll(localEvents);

    return events.toList()..sort();
  }
}

enum _PostResult { posted, rejected, retryLater }
