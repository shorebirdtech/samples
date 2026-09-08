import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shorebird_runner/features/tournament_lobby/data/i_lobby_repository.dart';
import 'package:shorebird_runner/features/tournament_lobby/models/models.dart';
import 'package:shorebird_runner/game/game.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket implementation of [ILobbyRepository].
class WebSocketLobbyRepository implements ILobbyRepository {
  WebSocketChannel? _channel;
  StreamSubscription? _sub;

  final _connectionController = StreamController<bool>.broadcast();
  final _roomCodeController = StreamController<String?>.broadcast();
  final _playersController = StreamController<List<LobbyPlayer>>.broadcast();
  final _countdownController = StreamController<int>.broadcast();
  final _raceStartController = StreamController<bool>.broadcast();
  final _standingsController =
      StreamController<List<RacerStanding>>.broadcast();
  final _matchFinishedController =
      StreamController<List<RacerStanding>?>.broadcast();
  final _rematchTriggeredController = StreamController<void>.broadcast();
  final _errorController = StreamController<String?>.broadcast();

  bool _isConnected = false;
  String? _currentRoomCode;
  String? _myPlayerId;
  String? _hostId;
  String _myPlayerName = 'Pilot';
  PlayerSkin _mySkin = PlayerSkin.blueBird;
  List<LobbyPlayer> _players = [];
  List<RacerStanding> _standings = [];
  List<RacerStanding>? _finalRankings;
  bool _isRacing = false;
  String? _customServerUrl;

  @override
  Stream<bool> get connectionStream => _connectionController.stream;
  @override
  Stream<String?> get roomCodeStream => _roomCodeController.stream;
  @override
  Stream<List<LobbyPlayer>> get playersStream => _playersController.stream;
  @override
  Stream<int> get countdownStream => _countdownController.stream;
  @override
  Stream<bool> get raceStartStream => _raceStartController.stream;
  @override
  Stream<List<RacerStanding>> get standingsStream =>
      _standingsController.stream;
  @override
  Stream<List<RacerStanding>?> get matchFinishedStream =>
      _matchFinishedController.stream;
  @override
  Stream<void> get rematchTriggeredStream => _rematchTriggeredController.stream;
  @override
  Stream<String?> get errorStream => _errorController.stream;

  @override
  bool get isConnected => _isConnected;
  @override
  String? get currentRoomCode => _currentRoomCode;
  @override
  String? get myPlayerId => _myPlayerId;
  @override
  String? get hostId => _hostId;
  @override
  bool get isHost =>
      _myPlayerId != null && _hostId != null && _myPlayerId == _hostId;
  @override
  bool get isParticipant => _players.any((p) => p.id == _myPlayerId);
  @override
  bool get isSpectator => isHost && !isParticipant;
  @override
  List<LobbyPlayer> get players => _players;
  @override
  List<RacerStanding> get standings => _standings;
  @override
  List<RacerStanding>? get finalRankings => _finalRankings;

  @override
  void setCustomServerUrl(String? url) {
    _customServerUrl = url;
  }

  @override
  String get defaultServerUrl {
    if (_customServerUrl != null && _customServerUrl!.trim().isNotEmpty) {
      return _customServerUrl!.trim();
    }
    const envUrl = String.fromEnvironment('LOBBY_SERVER_URL');
    if (envUrl.isNotEmpty) return envUrl;

    if (kIsWeb) {
      final queryServer = Uri.base.queryParameters['server'];
      if (queryServer != null && queryServer.trim().isNotEmpty) {
        return queryServer.trim();
      }
      final host = Uri.base.host.isEmpty ? 'localhost' : Uri.base.host;
      final hasNonStandardPort =
          Uri.base.hasPort && Uri.base.port != 80 && Uri.base.port != 443;
      final portSuffix = hasNonStandardPort ? ':${Uri.base.port}' : '';
      final scheme = Uri.base.scheme == 'https' ? 'wss' : 'ws';
      return '$scheme://$host$portSuffix/ws';
    }
    return 'ws://localhost:8088/ws';
  }

  @override
  Future<bool> ensureConnected() async {
    if (_isConnected && _channel != null) return true;
    final serverUrl = defaultServerUrl;
    try {
      final uri = Uri.parse(serverUrl);
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;
      _isConnected = true;
      _connectionController.add(true);

      _sub = _channel!.stream.listen(
        (data) => _onMessageReceived(data as String),
        onDone: () {
          _isConnected = false;
          _channel = null;
          _connectionController.add(false);
        },
        onError: (err) {
          _isConnected = false;
          _channel = null;
          _connectionController.add(false);
          _errorController.add('Connection error: $err');
        },
      );
      return true;
    } catch (e) {
      _isConnected = false;
      _connectionController.add(false);
      _errorController
          .add('Failed to connect to lobby server at $serverUrl: $e');
      return false;
    }
  }

  @override
  void createRoom({
    bool isParticipant = false,
    String? playerName,
    PlayerSkin? skin,
  }) async {
    _myPlayerName =
        playerName?.trim().isNotEmpty == true ? playerName!.trim() : 'Host';
    if (skin != null) _mySkin = skin;
    _finalRankings = null;
    _isRacing = false;

    final ok = await ensureConnected();
    if (!ok) return;

    _send({
      'type': 'create_room',
      'isParticipant': isParticipant,
      'playerName': _myPlayerName,
      'skin': _mySkin.name,
    });
  }

  @override
  void joinRoom(String roomCode, String playerName, PlayerSkin skin) async {
    _myPlayerName =
        playerName.trim().isEmpty ? 'Challenger' : playerName.trim();
    _mySkin = skin;
    _finalRankings = null;
    _isRacing = false;

    final ok = await ensureConnected();
    if (!ok) return;

    _send({
      'type': 'join_room',
      'roomCode': roomCode.trim().toUpperCase(),
      'playerName': _myPlayerName,
      'skin': _mySkin.name,
    });
  }

  @override
  void joinAsParticipant(String playerName, PlayerSkin skin) {
    if (_currentRoomCode == null) return;
    _myPlayerName =
        playerName.trim().isNotEmpty ? playerName.trim() : 'Host Pilot';
    _mySkin = skin;
    _send({
      'type': 'join_room',
      'roomCode': _currentRoomCode!,
      'playerName': _myPlayerName,
      'skin': _mySkin.name,
    });
  }

  @override
  void startCountdown() {
    if (!isHost) return;
    _send({'type': 'start_countdown'});
  }

  @override
  void sendScoreUpdate(int score, int patches, int level, bool isAlive) {
    if (!_isRacing || _currentRoomCode == null) return;
    _send({
      'type': 'score_update',
      'score': score,
      'patches': patches,
      'level': level,
      'isAlive': isAlive,
    });
  }

  @override
  void requestRematch() {
    if (!isHost) return;
    _send({'type': 'rematch'});
  }

  @override
  void leaveRoom() {
    if (_currentRoomCode != null) {
      _send({'type': 'leave_room'});
    }
    _currentRoomCode = null;
    _hostId = null;
    _players = [];
    _standings = [];
    _isRacing = false;
    _finalRankings = null;
    _roomCodeController.add(null);
    _playersController.add([]);
    _standingsController.add([]);
    _matchFinishedController.add(null);
  }

  void _send(Map<String, dynamic> msg) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode(msg));
    }
  }

  void _onMessageReceived(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final type = json['type'] as String?;

      switch (type) {
        case 'room_created':
        case 'join_success':
          _currentRoomCode = json['roomCode'] as String?;
          _myPlayerId = json['playerId'] as String?;
          _parseRoom(json['room'] as Map<String, dynamic>?);
          _roomCodeController.add(_currentRoomCode);
          _playersController.add(_players);
          break;

        case 'join_failed':
          _errorController
              .add(json['message'] as String? ?? 'Could not join room');
          break;

        case 'room_updated':
          _parseRoom(json['room'] as Map<String, dynamic>?);
          _playersController.add(_players);
          break;

        case 'countdown_tick':
          final count = (json['count'] as num? ?? 3).toInt();
          _countdownController.add(count);
          break;

        case 'race_start':
          _isRacing = true;
          _parseRoom(json['room'] as Map<String, dynamic>?);
          _raceStartController.add(true);
          break;

        case 'leaderboard_update':
          final rawStandings = (json['standings'] as List<dynamic>? ?? []);
          _standings = rawStandings.asMap().entries.map((e) {
            return RacerStanding.fromJson(
              e.value as Map<String, dynamic>,
              e.key + 1,
            );
          }).toList();
          _standingsController.add(_standings);
          break;

        case 'match_finished':
          final rawRankings = (json['rankings'] as List<dynamic>? ?? []);
          _finalRankings = rawRankings.asMap().entries.map((e) {
            return RacerStanding.fromJson(
              e.value as Map<String, dynamic>,
              e.key + 1,
            );
          }).toList();
          _isRacing = false;
          _matchFinishedController.add(_finalRankings);
          break;

        case 'room_rematch':
          _isRacing = false;
          _finalRankings = null;
          _parseRoom(json['room'] as Map<String, dynamic>?);
          _playersController.add(_players);
          _rematchTriggeredController.add(null);
          break;

        case 'error':
          _errorController.add(json['message'] as String?);
          break;
      }
    } catch (e) {
      debugPrint('Error parsing server message: $e');
    }
  }

  void _parseRoom(Map<String, dynamic>? roomJson) {
    if (roomJson == null) return;
    _hostId = roomJson['hostId'] as String?;
    final playersList = (roomJson['players'] as List<dynamic>? ?? []);
    _players = playersList
        .map((p) => LobbyPlayer.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _channel?.sink.close();
    _connectionController.close();
    _roomCodeController.close();
    _playersController.close();
    _countdownController.close();
    _raceStartController.close();
    _standingsController.close();
    _matchFinishedController.close();
    _rematchTriggeredController.close();
    _errorController.close();
  }
}
