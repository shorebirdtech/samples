import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plume/core/logging/analytics.dart';
import 'package:plume/core/logging/logger.dart';
import 'package:plume/features/updates/update_cubit.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class _MockUpdater extends Mock implements ShorebirdUpdater;

class _MockAnalytics extends Mock implements Analytics;

void main() {
  late _MockUpdater updater;
  final now = DateTime(2026, 11, 20, 10);

  setUp(() {
    updater = _MockUpdater();
    when(() => updater.isAvailable).thenReturn(true);
    when(updater.readCurrentPatch).thenAnswer((_) async => null);
    when(updater.readNextPatch).thenAnswer((_) async => null);
  });

  UpdateCubit build() => UpdateCubit(
    updater: updater,
    logger: AppLogger(minLevel: LogLevel.error),
    analytics: _MockAnalytics(),
    clock: () => now,
  );

  group('UpdateCubit', () {
    blocTest<UpdateCubit, UpdateState>(
      'is unavailable without the Shorebird engine',
      setUp: () => when(() => updater.isAvailable).thenReturn(false),
      build: build,
      act: (cubit) => cubit.initialize(),
      expect: () => [const UpdateState(phase: UpdatePhase.unavailable)],
      verify: (_) => verifyNever(() => updater.checkForUpdate()),
    );

    blocTest<UpdateCubit, UpdateState>(
      'initialize reads the patch and finds an update',
      setUp: () {
        when(updater.readCurrentPatch)
            .thenAnswer((_) async => const Patch(number: 1));
        when(updater.readNextPatch)
            .thenAnswer((_) async => const Patch(number: 1));
        when(updater.checkForUpdate)
            .thenAnswer((_) async => UpdateStatus.outdated);
      },
      build: build,
      act: (cubit) => cubit.initialize(),
      expect: () => [
        const UpdateState(currentPatch: 1, nextPatch: 1),
        UpdateState(
          phase: UpdatePhase.available,
          currentPatch: 1,
          nextPatch: 1,
          lastChecked: now,
        ),
      ],
    );

    blocTest<UpdateCubit, UpdateState>(
      'download installs the patch and asks for a restart',
      setUp: () {
        when(updater.update).thenAnswer((_) async {});
        when(updater.readNextPatch)
            .thenAnswer((_) async => const Patch(number: 2));
      },
      build: build,
      seed: () => const UpdateState(phase: UpdatePhase.available),
      act: (cubit) => cubit.download(),
      expect: () => [
        const UpdateState(phase: UpdatePhase.downloading),
        const UpdateState(phase: UpdatePhase.downloading, nextPatch: 2),
        const UpdateState(phase: UpdatePhase.readyToRestart, nextPatch: 2),
      ],
    );

    blocTest<UpdateCubit, UpdateState>(
      'download failure is recoverable',
      setUp: () => when(updater.update).thenThrow(
        const UpdateException(
          message: 'boom',
          reason: UpdateFailureReason.downloadFailed,
        ),
      ),
      build: build,
      seed: () => const UpdateState(phase: UpdatePhase.available),
      act: (cubit) => cubit.download(),
      expect: () => [
        const UpdateState(phase: UpdatePhase.downloading),
        const UpdateState(
          phase: UpdatePhase.failed,
          failureReason: UpdateFailureReason.downloadFailed,
        ),
      ],
    );

    blocTest<UpdateCubit, UpdateState>(
      'does not check again once a restart is pending',
      build: build,
      seed: () => const UpdateState(phase: UpdatePhase.readyToRestart),
      act: (cubit) => cubit.check(),
      expect: () => <UpdateState>[],
    );

    blocTest<UpdateCubit, UpdateState>(
      'a failed check is reported',
      setUp: () => when(updater.checkForUpdate).thenThrow(Exception('offline')),
      build: build,
      act: (cubit) => cubit.check(),
      expect: () => [
        const UpdateState(phase: UpdatePhase.checking),
        const UpdateState(
          phase: UpdatePhase.failed,
          failureReason: UpdateFailureReason.unknown,
        ),
      ],
    );
  });
}
