import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/features/tournament_lobby/models/models.dart';
import 'package:shorebird_runner/game/game.dart';

abstract class LobbyEvent extends Equatable {
  const LobbyEvent();

  @override
  List<Object?> get props => [];
}

class ConnectLobby extends LobbyEvent {
  const ConnectLobby();
}

class CreateRoomRequested extends LobbyEvent {
  final bool isParticipant;
  final String playerName;
  final PlayerSkin skin;

  const CreateRoomRequested({
    required this.isParticipant,
    required this.playerName,
    required this.skin,
  });

  @override
  List<Object?> get props => [isParticipant, playerName, skin];
}

class JoinRoomRequested extends LobbyEvent {
  final String roomCode;
  final String playerName;
  final PlayerSkin skin;

  const JoinRoomRequested({
    required this.roomCode,
    required this.playerName,
    required this.skin,
  });

  @override
  List<Object?> get props => [roomCode, playerName, skin];
}

class JoinAsParticipantRequested extends LobbyEvent {
  final String playerName;
  final PlayerSkin skin;

  const JoinAsParticipantRequested({
    required this.playerName,
    required this.skin,
  });

  @override
  List<Object?> get props => [playerName, skin];
}

class LobbySkinSelected extends LobbyEvent {
  final PlayerSkin skin;

  const LobbySkinSelected(this.skin);

  @override
  List<Object?> get props => [skin];
}

class StartCountdownRequested extends LobbyEvent {
  const StartCountdownRequested();
}

class LeaveRoomRequested extends LobbyEvent {
  const LeaveRoomRequested();
}

class RequestRematchRequested extends LobbyEvent {
  const RequestRematchRequested();
}

class LobbyRoomCodeChanged extends LobbyEvent {
  final String? roomCode;
  const LobbyRoomCodeChanged(this.roomCode);

  @override
  List<Object?> get props => [roomCode];
}

class LobbyPlayersChanged extends LobbyEvent {
  final List<LobbyPlayer> players;
  const LobbyPlayersChanged(this.players);

  @override
  List<Object?> get props => [players];
}

class LobbyCountdownTicked extends LobbyEvent {
  final int count;
  const LobbyCountdownTicked(this.count);

  @override
  List<Object?> get props => [count];
}

class LobbyRaceStartedEvent extends LobbyEvent {
  const LobbyRaceStartedEvent();
}

class LobbyConnectionChanged extends LobbyEvent {
  final bool isConnected;
  const LobbyConnectionChanged(this.isConnected);

  @override
  List<Object?> get props => [isConnected];
}

class LobbyErrorReceived extends LobbyEvent {
  final String errorMessage;
  const LobbyErrorReceived(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
