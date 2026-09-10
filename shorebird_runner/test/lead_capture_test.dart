import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shorebird_runner/features/lead_capture/lead_capture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LeadModel', () {
    test('toJson and fromJson work symmetrically including event', () {
      final now = DateTime.now();
      final lead = LeadModel(
        name: 'Alex Rivera',
        email: 'alex@shorebird.dev',
        phone: '+1 555-0192',
        organization: 'Shorebird Inc',
        event: 'FlutterCon Berlin',
        createdAt: now,
      );

      final json = lead.toJson();
      expect(json['name'], 'Alex Rivera');
      expect(json['email'], 'alex@shorebird.dev');
      expect(json['phone'], '+1 555-0192');
      expect(json['organization'], 'Shorebird Inc');
      expect(json['event'], 'FlutterCon Berlin');

      final parsed = LeadModel.fromJson(json);
      expect(parsed.name, lead.name);
      expect(parsed.email, lead.email);
      expect(parsed.phone, lead.phone);
      expect(parsed.organization, lead.organization);
      expect(parsed.event, lead.event);
    });

    test('playerTag formats name and organization cleanly', () {
      final lead = LeadModel(
        name: 'Linus Torvalds',
        email: 'linus@linux.org',
        phone: '12345678',
        organization: 'Linux Foundation',
        createdAt: DateTime.now(),
      );
      expect(lead.playerTag, 'Linus @ Linux Foundation');

      final soloLead = LeadModel(
        name: 'Ada',
        email: 'ada@lovelace.org',
        phone: '12345678',
        organization: '',
        createdAt: DateTime.now(),
      );
      expect(soloLead.playerTag, 'ADA');
    });
  });

  group('EventConfigService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('saves, retrieves, and clears active event', () async {
      const service = EventConfigService();
      expect(await service.getActiveEvent(), '');

      await service.setActiveEvent('Droidcon London');
      expect(await service.getActiveEvent(), 'Droidcon London');

      await service.setActiveEvent('');
      expect(await service.getActiveEvent(), '');
    });
  });

  group('LocalLeadRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('saves and retrieves leads from SharedPreferences', () async {
      const repo = LocalLeadRepository();
      final lead = LeadModel(
        name: 'Grace Hopper',
        email: 'grace@navy.mil',
        phone: '987654321',
        organization: 'US Navy',
        event: 'Grace Hopper Celebration',
        createdAt: DateTime.now(),
      );

      await repo.submitLead(lead);
      final leads = await repo.getLeads();

      expect(leads.length, 1);
      expect(leads.first.name, 'Grace Hopper');
      expect(leads.first.organization, 'US Navy');
      expect(leads.first.event, 'Grace Hopper Celebration');
    });
  });

  group('LeadCaptureBloc', () {
    late LocalLeadRepository repo;
    late EventConfigService eventService;
    late LeadCaptureBloc bloc;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repo = const LocalLeadRepository();
      eventService = const EventConfigService();
      bloc = LeadCaptureBloc(
        leadRepository: repo,
        eventConfigService: eventService,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state has empty fields and isValid is false', () {
      expect(bloc.state.isValid, isFalse);
      expect(bloc.state.status, LeadSubmissionStatus.initial);
    });

    test('validates inputs and submits successfully with active event',
        () async {
      bloc.add(const LeadNameChanged('Margaret Hamilton'));
      bloc.add(const LeadEmailChanged('margaret@mit.edu'));
      bloc.add(const LeadPhoneChanged('+1 617-253-1000'));
      bloc.add(const LeadOrgChanged('MIT Instrumentation Lab'));
      bloc.add(const LeadEventUpdated('Apollo 11 Launch'));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<LeadCaptureState>(
            (state) => state.isValid && state.event == 'Apollo 11 Launch',
          ),
        ),
      );

      bloc.add(const LeadSubmitted());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<LeadCaptureState>(
            (state) =>
                state.status == LeadSubmissionStatus.success &&
                state.submittedLead?.name == 'Margaret Hamilton' &&
                state.submittedLead?.event == 'Apollo 11 Launch',
          ),
        ),
      );
    });
  });
}
