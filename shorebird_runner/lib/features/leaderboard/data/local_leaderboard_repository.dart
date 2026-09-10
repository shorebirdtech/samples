import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shorebird_runner/features/leaderboard/data/i_leaderboard_repository.dart';
import 'package:shorebird_runner/features/leaderboard/models/leaderboard_entry_model.dart';

/// Local SharedPreferences implementation of [ILeaderboardRepository].
class LocalLeaderboardRepository implements ILeaderboardRepository {
  static const String _storageKey = 'shorebird_runner_local_leaderboard_v1';

  const LocalLeaderboardRepository();

  @override
  Future<List<LeaderboardEntryModel>> getScores({String? event}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      List<LeaderboardEntryModel> entries = [];

      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        entries = list
            .map(
              (e) => LeaderboardEntryModel.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();
      } else {
        // Seed initial benchmark entries so the leaderboard has exciting targets
        entries = _initialSeedEntries;
        await _saveEntries(prefs, entries);
      }

      if (event != null && event.trim().isNotEmpty && event != 'All Events') {
        final normalized = event.trim().toLowerCase();
        entries = entries
            .where((e) => e.event.trim().toLowerCase() == normalized)
            .toList();
      }

      entries.sort((a, b) => b.score.compareTo(a.score));
      return entries;
    } catch (_) {
      return _initialSeedEntries;
    }
  }

  @override
  Future<void> submitScore(LeaderboardEntryModel entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = await getScores();
      final updated = List<LeaderboardEntryModel>.from(current)..add(entry);
      updated.sort((a, b) => b.score.compareTo(a.score));
      // Keep top 100
      final capped = updated.take(100).toList();
      await _saveEntries(prefs, capped);
    } catch (_) {}
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
    return events.toList()..sort();
  }

  Future<void> _saveEntries(
    SharedPreferences prefs,
    List<LeaderboardEntryModel> entries,
  ) async {
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  static final List<LeaderboardEntryModel> _initialSeedEntries = [
    LeaderboardEntryModel(
      id: 1,
      playerName: 'Felix Angelov',
      score: 3450,
      patches: 58,
      organization: 'Shorebird',
      event: 'Global',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    LeaderboardEntryModel(
      id: 2,
      playerName: 'Eric Seidel',
      score: 3120,
      patches: 52,
      organization: 'Shorebird',
      event: 'Global',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    LeaderboardEntryModel(
      id: 3,
      playerName: 'Bryan Oltman',
      score: 2890,
      patches: 47,
      organization: 'Shorebird',
      event: 'Droidcon London',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    LeaderboardEntryModel(
      id: 4,
      playerName: 'Sarah Chen',
      score: 2540,
      patches: 42,
      organization: 'Flutter Europe',
      event: 'FlutterCon',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    LeaderboardEntryModel(
      id: 5,
      playerName: 'Marcus Vance',
      score: 2180,
      patches: 36,
      organization: 'Acme Mobile',
      event: 'Droidcon London',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    LeaderboardEntryModel(
      id: 6,
      playerName: 'Elena Rostova',
      score: 1950,
      patches: 31,
      organization: 'Fintech Studio',
      event: 'FlutterCon',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
}
