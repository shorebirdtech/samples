import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shorebird_runner/game/components/player.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LobbyPlayer {
  final String id;
  final String name;
  final PlayerSkin skin;
  final bool isReady;
  final int score;
  final int patches;
  final int level;
  final bool isAlive;

  const LobbyPlayer({
    required this.id,
    required this.name,
    required this.skin,
    this.isReady = false,
    this.score = 0,
    this.patches = 0,
    this.level = 1,
    this.isAlive = true,
  });

  factory LobbyPlayer.fromJson(Map<String, dynamic> json) {
    final skinStr = json['skin'] as String? ?? 'blueBird';
    final skin = PlayerSkin.values.firstWhere(
      (s) => s.name == skinStr,
      orElse: () => PlayerSkin.blueBird,
    );
    return LobbyPlayer(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Pilot',
      skin: skin,
      isReady: json['isReady'] as bool? ?? false,
      score: (json['score'] as num? ?? 0).toInt(),
      patches: (json['patches'] as num? ?? 0).toInt(),
      level: (json['level'] as num? ?? 1).toInt(),
      isAlive: json['isAlive'] as bool? ?? true,
    );
  }
}

class RacerStanding {
  final int rank;
  final String id;
  final String name;
  final PlayerSkin skin;
  final int score;
  final int patches;
  final int level;
  final bool isAlive;

  const RacerStanding({
    required this.rank,
    required this.id,
    required this.name,
    required this.skin,
    required this.score,
    required this.patches,
    required this.level,
    this.isAlive = true,
  });

  factory RacerStanding.fromJson(Map<String, dynamic> json, int defaultRank) {
    final skinStr = json['skin'] as String? ?? 'blueBird';
    final skin = PlayerSkin.values.firstWhere(
      (s) => s.name == skinStr,
      orElse: () => PlayerSkin.blueBird,
    );
    return RacerStanding(
      rank: (json['rank'] as num? ?? defaultRank).toInt(),
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Pilot',
      skin: skin,
      score: (json['score'] as num? ?? 0).toInt(),
      patches: (json['patches'] as num? ?? 0).toInt(),
      level: (json['level'] as num? ?? 1).toInt(),
      isAlive: json['isAlive'] as bool? ?? true,
    );
  }
}

class LobbyService extends ChangeNotifier {
  static final LobbyService instance = LobbyService._();
  LobbyService._();

  WebSocketChannel? _channel;
  StreamSubscription? _sub;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  String? _currentRoomCode;
  String? get currentRoomCode => _currentRoomCode;

  String? _myPlayerId;
  String? get myPlayerId => _myPlayerId;

  String _myPlayerName = 'Pilot';
  String get myPlayerName => _myPlayerName;

  PlayerSkin _mySkin = PlayerSkin.blueBird;
  PlayerSkin get mySkin => _mySkin;

  String? _hostId;
  bool get isHost =>
      _myPlayerId != null && _hostId != null && _myPlayerId == _hostId;

  List<LobbyPlayer> _players = [];
  List<LobbyPlayer> get players => _players;

  int _countdown = 0;
  int get countdown => _countdown;

  bool _isRacing = false;
  bool get isRacing => _isRacing;

  List<RacerStanding> _standings = [];
  List<RacerStanding> get standings => _standings;

  List<RacerStanding>? _finalRankings;
  List<RacerStanding>? get finalRankings => _finalRankings;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String get defaultServerUrl {
    if (kIsWeb) {
      final host = Uri.base.host.isEmpty ? 'localhost' : Uri.base.host;
      return 'ws://$host:8088';
    }
    return 'ws://localhost:8088';
  }

  Future<bool> ensureConnected([String? url]) async {
    if (_isConnected && _channel != null) return true;
    final serverUrl = url ?? defaultServerUrl;
    try {
      final uri = Uri.parse(serverUrl);
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;
      _isConnected = true;
      _errorMessage = null;

      _sub = _channel!.stream.listen(
        (data) => _onMessageReceived(data as String),
        onDone: () {
          _isConnected = false;
          _channel = null;
          notifyListeners();
        },
        onError: (err) {
          _isConnected = false;
          _errorMessage = 'Connection error: $err';
          _channel = null;
          notifyListeners();
        },
      );
      notifyListeners();
      return true;
    } catch (e) {
      _isConnected = false;
      _errorMessage = 'Failed to connect to lobby server at $serverUrl: $e';
      notifyListeners();
      return false;
    }
  }

  void createRoom(String playerName, PlayerSkin skin) async {
    _myPlayerName = playerName.trim().isEmpty ? 'Pilot 1' : playerName.trim();
    _mySkin = skin;
    _finalRankings = null;
    _isRacing = false;
    _countdown = 0;

    final ok = await ensureConnected();
    if (!ok) return;

    _send({
      'type': 'create_room',
      'playerName': _myPlayerName,
      'skin': _mySkin.name,
    });
  }

  void joinRoom(String roomCode, String playerName, PlayerSkin skin) async {
    _myPlayerName =
        playerName.trim().isEmpty ? 'Challenger' : playerName.trim();
    _mySkin = skin;
    _finalRankings = null;
    _isRacing = false;
    _countdown = 0;

    final ok = await ensureConnected();
    if (!ok) return;

    _send({
      'type': 'join_room',
      'roomCode': roomCode.trim().toUpperCase(),
      'playerName': _myPlayerName,
      'skin': _mySkin.name,
    });
  }

  void startCountdown() {
    if (!isHost) return;
    _send({'type': 'start_countdown'});
  }

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

  void leaveRoom() {
    if (_currentRoomCode != null) {
      _send({'type': 'leave_room'});
    }
    _currentRoomCode = null;
    _hostId = null;
    _players = [];
    _standings = [];
    _isRacing = false;
    _countdown = 0;
    _finalRankings = null;
    notifyListeners();
  }

  void resetMatch() {
    _isRacing = false;
    _countdown = 0;
    _finalRankings = null;
    notifyListeners();
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
          _currentRoomCode = json['roomCode'] as String?;
          _myPlayerId = json['playerId'] as String?;
          _parseRoom(json['room'] as Map<String, dynamic>?);
          _errorMessage = null;
          notifyListeners();
          break;

        case 'join_success':
          _currentRoomCode = json['roomCode'] as String?;
          _myPlayerId = json['playerId'] as String?;
          _parseRoom(json['room'] as Map<String, dynamic>?);
          _errorMessage = null;
          notifyListeners();
          break;

        case 'join_failed':
          _errorMessage = json['message'] as String? ?? 'Could not join room';
          notifyListeners();
          break;

        case 'room_updated':
          _parseRoom(json['room'] as Map<String, dynamic>?);
          notifyListeners();
          break;

        case 'countdown_tick':
          _countdown = (json['count'] as num? ?? 3).toInt();
          notifyListeners();
          break;

        case 'race_start':
          _countdown = 0;
          _isRacing = true;
          _parseRoom(json['room'] as Map<String, dynamic>?);
          notifyListeners();
          break;

        case 'leaderboard_update':
          final rawStandings = (json['standings'] as List<dynamic>? ?? []);
          _standings = rawStandings.asMap().entries.map((e) {
            return RacerStanding.fromJson(
                e.value as Map<String, dynamic>, e.key + 1);
          }).toList();
          notifyListeners();
          break;

        case 'match_finished':
          final rawRankings = (json['rankings'] as List<dynamic>? ?? []);
          _finalRankings = rawRankings.asMap().entries.map((e) {
            return RacerStanding.fromJson(
                e.value as Map<String, dynamic>, e.key + 1);
          }).toList();
          _isRacing = false;
          notifyListeners();
          break;

        case 'error':
          _errorMessage = json['message'] as String?;
          notifyListeners();
          break;
      }
    } catch (e) {
      debugPrint('Error parsing server message: $e ($raw)');
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
    super.dispose();
  }
}
