import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shorebird_runner/features/lead_capture/data/i_lead_repository.dart';
import 'package:shorebird_runner/features/lead_capture/models/lead_model.dart';

class LocalLeadRepository implements ILeadRepository {
  static const _storageKey = 'shorebird_runner_leads';

  const LocalLeadRepository();

  @override
  Future<void> submitLead(LeadModel lead) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = prefs.getStringList(_storageKey) ?? [];
      currentList.add(jsonEncode(lead.toJson()));
      await prefs.setStringList(_storageKey, currentList);
      debugPrint('[LocalLeadRepository] Saved lead locally: ${lead.email}');
    } catch (e) {
      debugPrint('[LocalLeadRepository] Error saving lead locally: $e');
    }
  }

  @override
  Future<List<LeadModel>> getLeads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_storageKey) ?? [];
      return list
          .map(
            (item) =>
                LeadModel.fromJson(jsonDecode(item) as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('[LocalLeadRepository] Error fetching local leads: $e');
      return [];
    }
  }
}
