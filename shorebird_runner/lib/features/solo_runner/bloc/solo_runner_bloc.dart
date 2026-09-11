import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/core/storage/storage.dart';
import 'package:shorebird_runner/features/solo_runner/bloc/solo_game_status.dart';
import 'package:shorebird_runner/features/solo_runner/bloc/solo_runner_event.dart';
import 'package:shorebird_runner/features/solo_runner/bloc/solo_runner_state.dart';

export 'solo_game_status.dart';
export 'solo_runner_event.dart';
export 'solo_runner_state.dart';

class SoloRunnerBloc extends Bloc<SoloRunnerEvent, SoloRunnerState> {
  final IHighScoreRepository _highScoreRepository;

  SoloRunnerBloc({
    required IHighScoreRepository highScoreRepository,
  })  : _highScoreRepository = highScoreRepository,
        super(SoloRunnerState()) {
    on<StartSoloGame>(_onStartSoloGame);
    on<RestartSoloGame>(_onRestartSoloGame);
    on<PauseSoloGame>(_onPauseSoloGame);
    on<ResumeSoloGame>(_onResumeSoloGame);
    on<SoloGameOver>(_onSoloGameOver);
  }

  void _onPauseSoloGame(
    PauseSoloGame event,
    Emitter<SoloRunnerState> emit,
  ) {
    if (state.status == SoloGameStatus.playing) {
      emit(state.copyWith(status: SoloGameStatus.paused));
    }
  }

  void _onResumeSoloGame(
    ResumeSoloGame event,
    Emitter<SoloRunnerState> emit,
  ) {
    if (state.status == SoloGameStatus.paused) {
      emit(state.copyWith(status: SoloGameStatus.playing));
    }
  }

  Future<void> _onStartSoloGame(
    StartSoloGame event,
    Emitter<SoloRunnerState> emit,
  ) async {
    final high = await _highScoreRepository.loadHighScore();
    emit(
      state.copyWith(
        status: SoloGameStatus.playing,
        score: 0,
        patches: 0,
        highScore: high,
        isNewRecord: false,
      ),
    );
  }

  Future<void> _onRestartSoloGame(
    RestartSoloGame event,
    Emitter<SoloRunnerState> emit,
  ) async {
    final high = await _highScoreRepository.loadHighScore();
    emit(
      state.copyWith(
        status: SoloGameStatus.initial,
        score: 0,
        patches: 0,
        highScore: high,
        isNewRecord: false,
      ),
    );
    emit(
      state.copyWith(
        status: SoloGameStatus.playing,
      ),
    );
  }

  Future<void> _onSoloGameOver(
    SoloGameOver event,
    Emitter<SoloRunnerState> emit,
  ) async {
    final isRecord = event.score > state.highScore && event.score > 0;
    if (isRecord) {
      await _highScoreRepository.saveHighScore(event.score);
    }
    emit(
      state.copyWith(
        status: SoloGameStatus.gameOver,
        score: event.score,
        patches: event.patches,
        level: event.level,
        highScore: isRecord ? event.score : state.highScore,
        isNewRecord: isRecord,
      ),
    );
  }
}
