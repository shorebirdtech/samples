import 'package:shorebird_runner/features/lead_capture/models/lead_model.dart';

abstract class ILeadRepository {
  /// Submits lead details to database or local fallback storage.
  Future<void> submitLead(LeadModel lead);

  /// Retrieves cached leads (for local fallback / review).
  Future<List<LeadModel>> getLeads();
}
