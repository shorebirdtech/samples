import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shorebird_runner/features/lead_capture/data/i_lead_repository.dart';
import 'package:shorebird_runner/features/lead_capture/data/local_lead_repository.dart';
import 'package:shorebird_runner/features/lead_capture/models/lead_model.dart';

/// Supabase REST API implementation for Lead Capture.
///
/// Uses standard Supabase PostgREST table endpoint:
///   `POST https://<project-ref>.supabase.co/rest/v1/rpc/upsert_lead`
///
/// which overwrites a returning player's lead (same name + event) rather
/// than inserting a duplicate. Falls back to `POST /rest/v1/leads` when the
/// function has not been created yet.
///
/// Secrets are injected securely via compile-time `--dart-define`:
///   --dart-define=SUPABASE_URL=https://xyz.supabase.co
///   --dart-define=SUPABASE_ANON_KEY=eyJhbGci...
///
/// If `--dart-define` keys are missing or network is unreachable, it
/// automatically falls back to [LocalLeadRepository] so OSS contributors
/// can run the game seamlessly with 0 configuration.
class SupabaseLeadRepository implements ILeadRepository {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final http.Client _httpClient;
  final LocalLeadRepository _localFallback;

  SupabaseLeadRepository({
    String? supabaseUrl,
    String? supabaseAnonKey,
    http.Client? httpClient,
    LocalLeadRepository? localFallback,
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
        _localFallback = localFallback ?? const LocalLeadRepository();

  bool get isConfigured =>
      !kDebugMode && supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  @override
  Future<void> submitLead(LeadModel lead) async {
    // Always persist to local storage as well for resilience
    await _localFallback.submitLead(lead);

    if (!isConfigured) {
      debugPrint(
        '[SupabaseLeadRepository] SUPABASE_URL or SUPABASE_ANON_KEY not configured. '
        'Saved to LocalLeadRepository fallback.',
      );
      return;
    }

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
      final json = lead.toJson();

      // `upsert_lead` overwrites the existing lead for the same player and
      // event instead of inserting a duplicate (see README for the SQL).
      var response = await _httpClient
          .post(
            Uri.parse('$sanitizedUrl/rest/v1/rpc/upsert_lead'),
            headers: headers,
            body: jsonEncode({
              for (final e in json.entries) 'p_${e.key}': e.value,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) {
        debugPrint(
          '[SupabaseLeadRepository] upsert_lead RPC not found; falling back '
          'to a plain insert. Run the README SQL to stop duplicate leads.',
        );
        response = await _httpClient
            .post(
              Uri.parse('$sanitizedUrl/rest/v1/leads'),
              headers: headers,
              body: jsonEncode(json),
            )
            .timeout(const Duration(seconds: 10));
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint(
          '[SupabaseLeadRepository] Lead recorded successfully on Supabase (${response.statusCode}): ${lead.name}',
        );
      } else {
        debugPrint(
          '[SupabaseLeadRepository] Supabase returned error status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint(
        '[SupabaseLeadRepository] Network exception syncing to Supabase: $e',
      );
      // Already saved to local fallback, so no exception thrown to avoid disrupting user experience
    }
  }

  @override
  Future<List<LeadModel>> getLeads() {
    return _localFallback.getLeads();
  }
}
