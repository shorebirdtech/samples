import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shorebird_runner/features/lead_capture/data/i_lead_repository.dart';
import 'package:shorebird_runner/features/lead_capture/data/local_lead_repository.dart';
import 'package:shorebird_runner/features/lead_capture/models/lead_model.dart';

/// Supabase REST API implementation for Lead Capture.
///
/// Uses standard Supabase PostgREST table endpoint:
///   `POST https://<project-ref>.supabase.co/rest/v1/leads`
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

  bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

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
      final uri = Uri.parse('$sanitizedUrl/rest/v1/leads');

      final response = await _httpClient
          .post(
            uri,
            headers: {
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
              'Content-Type': 'application/json',
              'Prefer': 'return=minimal',
            },
            body: jsonEncode(lead.toJson()),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint(
          '[SupabaseLeadRepository] Lead recorded successfully on Supabase: ${lead.email}',
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
