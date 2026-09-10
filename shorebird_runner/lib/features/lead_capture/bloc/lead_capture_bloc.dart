import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/features/lead_capture/bloc/lead_capture_event.dart';
import 'package:shorebird_runner/features/lead_capture/bloc/lead_capture_state.dart';
import 'package:shorebird_runner/features/lead_capture/data/event_config_service.dart';
import 'package:shorebird_runner/features/lead_capture/data/i_lead_repository.dart';
import 'package:shorebird_runner/features/lead_capture/models/lead_model.dart';

export 'lead_capture_event.dart';
export 'lead_capture_state.dart';

class LeadCaptureBloc extends Bloc<LeadCaptureEvent, LeadCaptureState> {
  final ILeadRepository leadRepository;
  final EventConfigService eventConfigService;

  LeadCaptureBloc({
    required this.leadRepository,
    this.eventConfigService = const EventConfigService(),
  }) : super(const LeadCaptureState()) {
    on<LeadNameChanged>(_onNameChanged);
    on<LeadEmailChanged>(_onEmailChanged);
    on<LeadPhoneChanged>(_onPhoneChanged);
    on<LeadOrgChanged>(_onOrgChanged);
    on<LeadEventUpdated>(_onEventUpdated);
    on<LeadSubmitted>(_onSubmitted);
    on<LeadCaptureReset>(_onReset);

    _initEvent();
  }

  Future<void> _initEvent() async {
    final active = await eventConfigService.getActiveEvent();
    if (active.isNotEmpty) {
      add(LeadEventUpdated(active));
    }
  }

  void _onNameChanged(LeadNameChanged event, Emitter<LeadCaptureState> emit) {
    emit(
      state.copyWith(
        name: event.name,
        status: LeadSubmissionStatus.initial,
      ),
    );
  }

  void _onEmailChanged(LeadEmailChanged event, Emitter<LeadCaptureState> emit) {
    emit(
      state.copyWith(
        email: event.email,
        status: LeadSubmissionStatus.initial,
      ),
    );
  }

  void _onPhoneChanged(LeadPhoneChanged event, Emitter<LeadCaptureState> emit) {
    emit(
      state.copyWith(
        phone: event.phone,
        status: LeadSubmissionStatus.initial,
      ),
    );
  }

  void _onOrgChanged(LeadOrgChanged event, Emitter<LeadCaptureState> emit) {
    emit(
      state.copyWith(
        organization: event.organization,
        status: LeadSubmissionStatus.initial,
      ),
    );
  }

  void _onEventUpdated(LeadEventUpdated event, Emitter<LeadCaptureState> emit) {
    emit(
      state.copyWith(
        event: event.event,
        status: LeadSubmissionStatus.initial,
      ),
    );
  }

  void _onReset(LeadCaptureReset event, Emitter<LeadCaptureState> emit) {
    emit(LeadCaptureState(event: state.event));
  }

  Future<void> _onSubmitted(
    LeadSubmitted event,
    Emitter<LeadCaptureState> emit,
  ) async {
    if (!state.isValid) {
      emit(
        state.copyWith(
          status: LeadSubmissionStatus.failure,
          errorMessage: 'Please fill in all fields with valid information.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: LeadSubmissionStatus.submitting));

    final activeEvent = state.event.isNotEmpty
        ? state.event
        : await eventConfigService.getActiveEvent();

    final lead = LeadModel(
      name: state.name.trim(),
      email: state.email.trim(),
      phone: state.phone.trim(),
      organization: state.organization.trim(),
      event: activeEvent,
      createdAt: DateTime.now(),
    );

    try {
      await leadRepository.submitLead(lead);
      emit(
        state.copyWith(
          status: LeadSubmissionStatus.success,
          submittedLead: lead,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LeadSubmissionStatus.success,
          submittedLead: lead,
        ),
      );
    }
  }
}
