import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/features/multiplayer_race/bloc/race_event.dart';
import 'package:shorebird_runner/features/multiplayer_race/bloc/race_state.dart';
import 'package:shorebird_runner/features/tournament_lobby/data/data.dart';

export 'race_event.dart';
export 'race_state.dart';

class RaceBloc extends Bloc<RaceEvent, RaceState> {
  final ILobbyRepository _lobbyRepository;
  final List<StreamSubscription> _subs = [];

  RaceBloc({required ILobbyRepository lobbyRepository})
      : _lobbyRepository = lobbyRepository,
        super(RaceState(standings: lobbyRepository.standings)) {
    on<UpdateRacerScore>(_onUpdateRacerScore);
    on<StandingsUpdated>(_onStandingsUpdated);
    on<MatchFinishedReceived>(_onMatchFinishedReceived);
    on<PlayerCrashedEvent>(_onPlayerCrashedEvent);

    _listenToRepository();
  }

  void _listenToRepository() {
    _subs.add(_lobbyRepository.standingsStream.listen((standings) {
      add(StandingsUpdated(standings));
    }));
    _subs.add(_lobbyRepository.matchFinishedStream.listen((rankings) {
      if (rankings != null) {
        add(MatchFinishedReceived(rankings));
      }
    }));
  }

  void _onUpdateRacerScore(UpdateRacerScore event, Emitter<RaceState> emit) {
    _lobbyRepository.sendScoreUpdate(
      event.score,
      event.patches,
      event.level,
      event.isAlive,
    );
  }

  void _onStandingsUpdated(StandingsUpdated event, Emitter<RaceState> emit) {
    emit(state.copyWith(standings: event.standings));
  }

  void _onMatchFinishedReceived(
      MatchFinishedReceived event, Emitter<RaceState> emit) {
    emit(state.copyWith(finalRankings: event.rankings));
  }

  void _onPlayerCrashedEvent(
      PlayerCrashedEvent event, Emitter<RaceState> emit) {
    emit(state.copyWith(
      isAlive: false,
      hasCrashed: true,
      finalScore: event.finalScore,
      finalPatches: event.finalPatches,
    ));
  }

  @override
  Future<void> close() {
    for (final s in _subs) {
      s.cancel();
    }
    return super.close();
  }
}
