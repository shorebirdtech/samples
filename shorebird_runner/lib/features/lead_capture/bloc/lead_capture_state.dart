import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/features/lead_capture/models/lead_model.dart';

enum LeadSubmissionStatus { initial, submitting, success, failure }

class LeadCaptureState extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String organization;
  final String event;
  final LeadSubmissionStatus status;
  final String? errorMessage;
  final LeadModel? submittedLead;

  const LeadCaptureState({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.organization = '',
    this.event = '',
    this.status = LeadSubmissionStatus.initial,
    this.errorMessage,
    this.submittedLead,
  });

  bool get isNameValid => name.trim().length >= 2;
  bool get isEmailValid =>
      RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')
          .hasMatch(email.trim());
  bool get isPhoneValid =>
      phone.trim().isEmpty ||
      phone.trim().replaceAll(RegExp(r'[^0-9]'), '').length >= 6;
  bool get isOrgValid => organization.trim().isNotEmpty;

  bool get isValid => isNameValid && isEmailValid && isPhoneValid && isOrgValid;

  LeadCaptureState copyWith({
    String? name,
    String? email,
    String? phone,
    String? organization,
    String? event,
    LeadSubmissionStatus? status,
    String? errorMessage,
    LeadModel? submittedLead,
  }) {
    return LeadCaptureState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      organization: organization ?? this.organization,
      event: event ?? this.event,
      status: status ?? this.status,
      errorMessage: errorMessage,
      submittedLead: submittedLead ?? this.submittedLead,
    );
  }

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        organization,
        event,
        status,
        errorMessage,
        submittedLead,
      ];
}
