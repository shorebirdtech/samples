import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plume/core/logging/analytics.dart';
import 'package:plume/core/logging/logger.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

enum UpdatePhase {
  /// The Shorebird engine isn't in this build (debug, or `flutter run`).
  unavailable,
  idle,
  checking,
  upToDate,
  available,
  downloading,

  /// A patch is installed and takes effect the next time the app starts.
  readyToRestart,
  failed,
}

class UpdateState extends Equatable {
  const UpdateState({
    this.phase = UpdatePhase.idle,
    this.currentPatch,
    this.nextPatch,
    this.lastChecked,
    this.failureReason,
  });

  final UpdatePhase phase;
  final int? currentPatch;
  final int? nextPatch;
  final DateTime? lastChecked;
  final UpdateFailureReason? failureReason;

  bool get isBusy =>
      phase == UpdatePhase.checking || phase == UpdatePhase.downloading;

  UpdateState copyWith({
    UpdatePhase? phase,
    int? Function()? currentPatch,
    int? Function()? nextPatch,
    DateTime? lastChecked,
    UpdateFailureReason? Function()? failureReason,
  }) => UpdateState(
    phase: phase ?? this.phase,
    currentPatch: currentPatch != null ? currentPatch() : this.currentPatch,
    nextPatch: nextPatch != null ? nextPatch() : this.nextPatch,
    lastChecked: lastChecked ?? this.lastChecked,
    failureReason: failureReason != null ? failureReason() : this.failureReason,
  );

  @override
  List<Object?> get props => [
    phase,
    currentPatch,
    nextPatch,
    lastChecked,
    failureReason,
  ];
}

/// Drives the in-app update panel with `package:shorebird_code_push`.
///
/// Network calls never block startup: [initialize] reads the installed patch
/// and kicks off a background check.
class UpdateCubit extends Cubit<UpdateState> {
  UpdateCubit({
    required this._updater,
    required this._logger,
    required this._analytics,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(const UpdateState());

  final ShorebirdUpdater _updater;
  final AppLogger _logger;
  final Analytics _analytics;
  final DateTime Function() _clock;

  Future<void> initialize() async {
    if (!_updater.isAvailable) {
      emit(state.copyWith(phase: UpdatePhase.unavailable));
      return;
    }
    await _readPatches();
    // Deliberately not awaited by callers: see ShorebirdUpdater docs.
    await check(silent: true);
  }

  Future<void> check({bool silent = false}) async {
    if (state.phase == UpdatePhase.unavailable || state.isBusy) return;
    if (state.phase == UpdatePhase.readyToRestart) return;
    if (!silent) emit(state.copyWith(phase: UpdatePhase.checking));
    try {
      final status = await _updater.checkForUpdate();
      _logger.info('Update status: ${status.name}');
      emit(
        state.copyWith(
          phase: switch (status) {
            UpdateStatus.outdated => UpdatePhase.available,
            UpdateStatus.restartRequired => UpdatePhase.readyToRestart,
            UpdateStatus.upToDate => UpdatePhase.upToDate,
            UpdateStatus.unavailable => UpdatePhase.unavailable,
          },
          lastChecked: _clock(),
          failureReason: () => null,
        ),
      );
      if (status == UpdateStatus.restartRequired) await _readPatches();
    } on Exception catch (e) {
      _logger.warning('Update check failed', e);
      emit(
        state.copyWith(
          phase: UpdatePhase.failed,
          failureReason: () => UpdateFailureReason.unknown,
        ),
      );
    }
  }

  Future<void> download() async {
    if (state.phase != UpdatePhase.available &&
        state.phase != UpdatePhase.failed) {
      return;
    }
    emit(
      state.copyWith(phase: UpdatePhase.downloading, failureReason: () => null),
    );
    _analytics.event('patch_download_started');
    try {
      await _updater.update();
      await _readPatches();
      _analytics.event('patch_downloaded', {'patch': state.nextPatch});
      emit(state.copyWith(phase: UpdatePhase.readyToRestart));
    } on UpdateException catch (e) {
      _logger.warning('Patch download failed: ${e.message}', e);
      emit(
        state.copyWith(
          phase: e.reason == UpdateFailureReason.noUpdate
              ? UpdatePhase.upToDate
              : UpdatePhase.failed,
          failureReason: () => e.reason,
        ),
      );
    }
  }

  Future<void> _readPatches() async {
    try {
      final current = await _updater.readCurrentPatch();
      final next = await _updater.readNextPatch();
      emit(
        state.copyWith(
          currentPatch: () => current?.number,
          nextPatch: () => next?.number,
        ),
      );
    } on ReadPatchException catch (e) {
      _logger.warning('Could not read patch info', e);
    }
  }
}
