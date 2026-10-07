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

  /// Shortest and longest names accepted. The name is the only required
  /// field because it is what shows up on the leaderboard, and the cap keeps
  /// it from overflowing leaderboard rows and the HUD.
  static const minNameLength = 2;
  static const maxNameLength = 24;

  static final _emailPattern =
      RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');

  static bool nameIsValid(String value) {
    final length = value.trim().length;
    return length >= minNameLength && length <= maxNameLength;
  }

  /// Optional: blank is valid, anything typed must look like an email.
  static bool emailIsValid(String value) =>
      value.trim().isEmpty || _emailPattern.hasMatch(value.trim());

  /// Optional: blank is valid, anything typed needs at least 6 digits.
  static bool phoneIsValid(String value) =>
      value.trim().isEmpty ||
      value.replaceAll(RegExp(r'[^0-9]'), '').length >= 6;

  bool get isNameValid => nameIsValid(name);
  bool get isEmailValid => emailIsValid(email);
  bool get isPhoneValid => phoneIsValid(phone);

  /// Whether the player shared anything beyond their leaderboard name.
  bool get hasContactDetails =>
      email.trim().isNotEmpty ||
      phone.trim().isNotEmpty ||
      organization.trim().isNotEmpty;

  bool get isValid => isNameValid && isEmailValid && isPhoneValid;

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
