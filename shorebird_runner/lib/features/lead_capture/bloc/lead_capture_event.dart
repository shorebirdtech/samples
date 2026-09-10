import 'package:equatable/equatable.dart';

abstract class LeadCaptureEvent extends Equatable {
  const LeadCaptureEvent();

  @override
  List<Object?> get props => [];
}

class LeadNameChanged extends LeadCaptureEvent {
  final String name;
  const LeadNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class LeadEmailChanged extends LeadCaptureEvent {
  final String email;
  const LeadEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class LeadPhoneChanged extends LeadCaptureEvent {
  final String phone;
  const LeadPhoneChanged(this.phone);

  @override
  List<Object?> get props => [phone];
}

class LeadOrgChanged extends LeadCaptureEvent {
  final String organization;
  const LeadOrgChanged(this.organization);

  @override
  List<Object?> get props => [organization];
}

class LeadSubmitted extends LeadCaptureEvent {
  const LeadSubmitted();
}

class LeadCaptureReset extends LeadCaptureEvent {
  const LeadCaptureReset();
}

class LeadEventUpdated extends LeadCaptureEvent {
  final String event;
  const LeadEventUpdated(this.event);

  @override
  List<Object?> get props => [event];
}
