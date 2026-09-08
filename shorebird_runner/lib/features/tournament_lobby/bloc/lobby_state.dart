import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/features/tournament_lobby/models/models.dart';
import 'package:shorebird_runner/game/game.dart';

class LobbyState extends Equatable {
  final bool isConnected;
  final String? roomCode;
  final String? myPlayerId;
  final List<LobbyPlayer> players;
  final int countdown;
  final bool isRacing;
  final bool isHost;
  final bool isParticipant;
  final bool isSpectator;
  final PlayerSkin selectedSkin;
  final String? errorMessage;

  const LobbyState({
    this.isConnected = false,
    this.roomCode,
    this.myPlayerId,
    this.players = const [],
    this.countdown = 0,
    this.isRacing = false,
    this.isHost = false,
    this.isParticipant = false,
    this.isSpectator = false,
    this.selectedSkin = PlayerSkin.blueBird,
    this.errorMessage,
  });

  LobbyState copyWith({
    bool? isConnected,
    String? roomCode,
    String? myPlayerId,
    List<LobbyPlayer>? players,
    int? countdown,
    bool? isRacing,
    bool? isHost,
    bool? isParticipant,
    bool? isSpectator,
    PlayerSkin? selectedSkin,
    String? errorMessage,
  }) {
    return LobbyState(
      isConnected: isConnected ?? this.isConnected,
      roomCode: roomCode ?? this.roomCode,
      myPlayerId: myPlayerId ?? this.myPlayerId,
      players: players ?? this.players,
      countdown: countdown ?? this.countdown,
      isRacing: isRacing ?? this.isRacing,
      isHost: isHost ?? this.isHost,
      isParticipant: isParticipant ?? this.isParticipant,
      isSpectator: isSpectator ?? this.isSpectator,
      selectedSkin: selectedSkin ?? this.selectedSkin,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isConnected,
        roomCode,
        myPlayerId,
        players,
        countdown,
        isRacing,
        isHost,
        isParticipant,
        isSpectator,
        selectedSkin,
        errorMessage,
      ];
}
