import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
  })  : supabaseUrl = supabaseUrl ??
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

  bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

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
          return _localFallback.getScores(event: event);
        }

        return entries;
      } else {
        debugPrint(
          '[SupabaseLeaderboardRepository] Status ${response.statusCode}: ${response.body}. Using local fallback.',
        );
        return _localFallback.getScores(event: event);
      }
    } catch (e) {
      debugPrint(
        '[SupabaseLeaderboardRepository] Network exception: $e. Using local fallback.',
      );
      return _localFallback.getScores(event: event);
    }
  }

  @override
  Future<void> submitScore(LeaderboardEntryModel entry) async {
    // Always persist to local storage as well
    await _localFallback.submitScore(entry);

    if (!isConfigured) return;

    try {
      final sanitizedUrl = supabaseUrl.endsWith('/')
          ? supabaseUrl.substring(0, supabaseUrl.length - 1)
          : supabaseUrl;
      final uri = Uri.parse('$sanitizedUrl/rest/v1/leaderboard');

      final payload = entry.toJson()..remove('id');

      final response = await _httpClient
          .post(
            uri,
            headers: {
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
              'Content-Type': 'application/json',
              'Prefer': 'return=minimal',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint(
          '[SupabaseLeaderboardRepository] Score recorded on Supabase: ${entry.playerName} -> ${entry.score}',
        );
      } else {
        debugPrint(
          '[SupabaseLeaderboardRepository] Error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('[SupabaseLeaderboardRepository] Network exception: $e');
    }
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
