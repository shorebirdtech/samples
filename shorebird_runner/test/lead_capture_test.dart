import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

    test('overwrites the existing lead when the same player returns', () async {
      const repo = LocalLeadRepository();
      await repo.submitLead(
        LeadModel(
          name: 'Grace Hopper',
          email: 'grace@navy.mil',
          phone: '987654321',
          organization: 'US Navy',
          event: 'FlutterCon',
          createdAt: DateTime(2026, 10, 7, 9),
        ),
      );
      await repo.submitLead(
        LeadModel(
          name: '  grace   hopper ',
          email: '',
          phone: '',
          organization: 'Yale',
          event: 'fluttercon',
          createdAt: DateTime(2026, 10, 7, 10),
        ),
      );
      await repo.submitLead(
        LeadModel(
          name: 'Grace Hopper',
          email: '',
          phone: '',
          organization: '',
          event: 'Droidcon London',
          createdAt: DateTime(2026, 10, 7, 11),
        ),
      );

      final leads = await repo.getLeads();

      expect(leads.length, 2);
      final flutterCon = leads.first;
      expect(flutterCon.name, 'grace   hopper');
      expect(flutterCon.organization, 'Yale');
      // Blank optional fields keep the earlier values.
      expect(flutterCon.email, 'grace@navy.mil');
      expect(flutterCon.phone, '987654321');
      expect(leads.last.event, 'Droidcon London');
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

    test('validates and submits successfully when phone number is omitted',
        () async {
      bloc.add(const LeadNameChanged('Katherine Johnson'));
      bloc.add(const LeadEmailChanged('katherine@nasa.gov'));
      // Phone left empty
      bloc.add(const LeadPhoneChanged(''));
      bloc.add(const LeadOrgChanged('NASA'));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<LeadCaptureState>(
            (state) => state.isValid && state.phone.isEmpty,
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
                state.submittedLead?.name == 'Katherine Johnson' &&
                state.submittedLead?.phone == '',
          ),
        ),
      );
    });
    test('submits with only a name, all other fields optional', () async {
      bloc.add(const LeadNameChanged('Ada Lovelace'));

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<LeadCaptureState>((state) => state.isValid)),
      );
      expect(bloc.state.hasContactDetails, isFalse);

      bloc.add(const LeadSubmitted());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<LeadCaptureState>(
            (state) =>
                state.status == LeadSubmissionStatus.success &&
                state.submittedLead?.name == 'Ada Lovelace' &&
                state.submittedLead?.email == '' &&
                state.submittedLead?.organization == '',
          ),
        ),
      );
    });

    test('rejects a missing name or malformed optional fields', () {
      expect(const LeadCaptureState().isValid, isFalse);
      expect(const LeadCaptureState(name: 'A').isValid, isFalse);
      expect(
        LeadCaptureState(
          name: 'A' * (LeadCaptureState.maxNameLength + 1),
        ).isValid,
        isFalse,
      );
      expect(
        const LeadCaptureState(name: 'Ada', email: 'not-an-email').isValid,
        isFalse,
      );
      expect(
        const LeadCaptureState(name: 'Ada', phone: '12').isValid,
        isFalse,
      );
      expect(
        const LeadCaptureState(name: 'Ada', email: 'ada@lovelace.org').isValid,
        isTrue,
      );
    });
  });

  group('LeadCaptureDialog', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<List<LeadModel>> pumpDialog(WidgetTester tester) async {
      // Tall enough that the whole form, CTA included, is on screen.
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final started = <LeadModel>[];
      await tester.pumpWidget(
        BlocProvider(
          create: (_) =>
              LeadCaptureBloc(leadRepository: const LocalLeadRepository()),
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () =>
                      LeadCaptureDialog.show(context, onStartGame: started.add),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return started;
    }

    Finder field(String hint) => find.widgetWithText(TextFormField, hint);

    testWidgets('starts the game with just a name, no consent needed',
        (tester) async {
      final started = await pumpDialog(tester);
      expect(find.text('Shown on the leaderboard.'), findsOneWidget);

      await tester.enterText(field('e.g. Alex Rivera'), 'Ada');
      await tester.tap(find.text('START PATCHING'));
      await tester.pumpAndSettle();

      expect(started.single.name, 'Ada');
    });

    testWidgets('requires a name', (tester) async {
      final started = await pumpDialog(tester);

      await tester.tap(find.text('START PATCHING'));
      await tester.pumpAndSettle();

      expect(started, isEmpty);
      expect(find.textContaining('Enter a name'), findsOneWidget);
    });

    testWidgets('asks for consent once contact details are shared',
        (tester) async {
      final started = await pumpDialog(tester);

      await tester.enterText(field('e.g. Alex Rivera'), 'Ada');
      await tester.enterText(field('e.g. alex@company.com'), 'ada@x.org');
      await tester.tap(find.text('START PATCHING'));
      await tester.pumpAndSettle();
      expect(started, isEmpty);

      await tester.tap(find.byType(Checkbox));
      await tester.tap(find.text('START PATCHING'));
      await tester.pumpAndSettle();
      expect(started.single.email, 'ada@x.org');
    });
  });
}
