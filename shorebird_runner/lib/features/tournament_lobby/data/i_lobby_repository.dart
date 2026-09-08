import 'package:shorebird_runner/features/tournament_lobby/models/models.dart';
import 'package:shorebird_runner/game/game.dart';

/// Contract for Tournament Lobby network communication.
/// Adheres to Dependency Inversion Principle (DIP).
abstract class ILobbyRepository {
  Stream<bool> get connectionStream;
  Stream<String?> get roomCodeStream;
  Stream<List<LobbyPlayer>> get playersStream;
  Stream<int> get countdownStream;
  Stream<bool> get raceStartStream;
  Stream<List<RacerStanding>> get standingsStream;
  Stream<List<RacerStanding>?> get matchFinishedStream;
  Stream<void> get rematchTriggeredStream;
  Stream<String?> get errorStream;

  bool get isConnected;
  String? get currentRoomCode;
  String? get myPlayerId;
  String? get hostId;
  bool get isHost;
  bool get isParticipant;
  bool get isSpectator;
  List<LobbyPlayer> get players;
  List<RacerStanding> get standings;
  List<RacerStanding>? get finalRankings;

  void setCustomServerUrl(String? url);
  String get defaultServerUrl;

  Future<bool> ensureConnected();
  void createRoom(
      {bool isParticipant = false, String? playerName, PlayerSkin? skin});
  void joinRoom(String roomCode, String playerName, PlayerSkin skin);
  void joinAsParticipant(String playerName, PlayerSkin skin);
  void startCountdown();
  void sendScoreUpdate(int score, int patches, int level, bool isAlive);
  void requestRematch();
  void leaveRoom();
  void dispose();
}
