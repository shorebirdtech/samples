import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/features/tournament_lobby/bloc/lobby_event.dart';
import 'package:shorebird_runner/features/tournament_lobby/bloc/lobby_state.dart';
import 'package:shorebird_runner/features/tournament_lobby/data/data.dart';

export 'lobby_event.dart';
export 'lobby_state.dart';

class LobbyBloc extends Bloc<LobbyEvent, LobbyState> {
  final ILobbyRepository _lobbyRepository;
  final List<StreamSubscription> _subs = [];

  LobbyBloc({required ILobbyRepository lobbyRepository})
      : _lobbyRepository = lobbyRepository,
        super(const LobbyState()) {
    on<ConnectLobby>(_onConnectLobby);
    on<CreateRoomRequested>(_onCreateRoomRequested);
    on<JoinRoomRequested>(_onJoinRoomRequested);
    on<JoinAsParticipantRequested>(_onJoinAsParticipantRequested);
    on<StartCountdownRequested>(_onStartCountdownRequested);
    on<LeaveRoomRequested>(_onLeaveRoomRequested);
    on<RequestRematchRequested>(_onRequestRematchRequested);
    on<LobbyConnectionChanged>(_onLobbyConnectionChanged);
    on<LobbyRoomCodeChanged>(_onLobbyRoomCodeChanged);
    on<LobbyPlayersChanged>(_onLobbyPlayersChanged);
    on<LobbyCountdownTicked>(_onLobbyCountdownTicked);
    on<LobbyRaceStartedEvent>(_onLobbyRaceStartedEvent);
    on<LobbyErrorReceived>(_onLobbyErrorReceived);
    on<LobbySkinSelected>(_onLobbySkinSelected);

    _listenToRepository();
  }

  void _onLobbySkinSelected(LobbySkinSelected event, Emitter<LobbyState> emit) {
    emit(state.copyWith(selectedSkin: event.skin));
  }

  void _listenToRepository() {
    _subs.add(
      _lobbyRepository.connectionStream.listen((connected) {
        add(LobbyConnectionChanged(connected));
      }),
    );
    _subs.add(
      _lobbyRepository.roomCodeStream.listen((code) {
        add(LobbyRoomCodeChanged(code));
      }),
    );
    _subs.add(
      _lobbyRepository.playersStream.listen((players) {
        add(LobbyPlayersChanged(players));
      }),
    );
    _subs.add(
      _lobbyRepository.countdownStream.listen((count) {
        add(LobbyCountdownTicked(count));
      }),
    );
    _subs.add(
      _lobbyRepository.raceStartStream.listen((_) {
        add(const LobbyRaceStartedEvent());
      }),
    );
    _subs.add(
      _lobbyRepository.errorStream.listen((err) {
        if (err != null) add(LobbyErrorReceived(err));
      }),
    );
  }

  Future<void> _onConnectLobby(
    ConnectLobby event,
    Emitter<LobbyState> emit,
  ) async {
    final ok = await _lobbyRepository.ensureConnected();
    emit(state.copyWith(isConnected: ok));
  }

  void _onCreateRoomRequested(
    CreateRoomRequested event,
    Emitter<LobbyState> emit,
  ) {
    _lobbyRepository.createRoom(
      isParticipant: event.isParticipant,
      playerName: event.playerName,
      skin: event.skin,
    );
  }

  void _onJoinRoomRequested(JoinRoomRequested event, Emitter<LobbyState> emit) {
    _lobbyRepository.joinRoom(event.roomCode, event.playerName, event.skin);
  }

  void _onJoinAsParticipantRequested(
    JoinAsParticipantRequested event,
    Emitter<LobbyState> emit,
  ) {
    _lobbyRepository.joinAsParticipant(event.playerName, event.skin);
  }

  void _onStartCountdownRequested(
    StartCountdownRequested event,
    Emitter<LobbyState> emit,
  ) {
    _lobbyRepository.startCountdown();
  }

  void _onLeaveRoomRequested(
    LeaveRoomRequested event,
    Emitter<LobbyState> emit,
  ) {
    _lobbyRepository.leaveRoom();
    emit(const LobbyState());
  }

  void _onRequestRematchRequested(
    RequestRematchRequested event,
    Emitter<LobbyState> emit,
  ) {
    _lobbyRepository.requestRematch();
  }

  void _onLobbyConnectionChanged(
    LobbyConnectionChanged event,
    Emitter<LobbyState> emit,
  ) {
    emit(
      state.copyWith(
        isConnected: event.isConnected,
        myPlayerId: _lobbyRepository.myPlayerId,
      ),
    );
  }

  void _onLobbyRoomCodeChanged(
    LobbyRoomCodeChanged event,
    Emitter<LobbyState> emit,
  ) {
    emit(
      state.copyWith(
        roomCode: event.roomCode,
        myPlayerId: _lobbyRepository.myPlayerId,
        isHost: _lobbyRepository.isHost,
        isParticipant: _lobbyRepository.isParticipant,
        isSpectator: _lobbyRepository.isSpectator,
      ),
    );
  }

  void _onLobbyPlayersChanged(
    LobbyPlayersChanged event,
    Emitter<LobbyState> emit,
  ) {
    emit(
      state.copyWith(
        players: event.players,
        myPlayerId: _lobbyRepository.myPlayerId,
        isHost: _lobbyRepository.isHost,
        isParticipant: _lobbyRepository.isParticipant,
        isSpectator: _lobbyRepository.isSpectator,
      ),
    );
  }

  void _onLobbyCountdownTicked(
    LobbyCountdownTicked event,
    Emitter<LobbyState> emit,
  ) {
    emit(state.copyWith(countdown: event.count));
  }

  void _onLobbyRaceStartedEvent(
    LobbyRaceStartedEvent event,
    Emitter<LobbyState> emit,
  ) {
    emit(
      state.copyWith(
        isRacing: true,
        countdown: 0,
        isHost: _lobbyRepository.isHost,
        isParticipant: _lobbyRepository.isParticipant,
        isSpectator: _lobbyRepository.isSpectator,
      ),
    );
  }

  void _onLobbyErrorReceived(
    LobbyErrorReceived event,
    Emitter<LobbyState> emit,
  ) {
    emit(state.copyWith(errorMessage: event.errorMessage));
  }

  @override
  Future<void> close() {
    for (final s in _subs) {
      s.cancel();
    }
    return super.close();
  }
}
