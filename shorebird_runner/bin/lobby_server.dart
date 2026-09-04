// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Patch Rush Lobby & Tournament Database Server
/// Runs on port 8088 by default.
void main(List<String> args) async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '8088') ?? 8088;
  final db = DatabaseService();
  await db.init();

  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('====================================================');
  print('🚀 SHOREBIRD PATCH RUSH LOBBY SERVER RUNNING');
  print('📡 Listening on http://0.0.0.0:$port (WebSocket: ws://0.0.0.0:$port)');
  print('💾 Database file: ${db.dbFile.path}');
  print('====================================================');

  final lobbyManager = LobbyManager(db);

  await for (final HttpRequest request in server) {
    // Enable CORS
    request.response.headers.set('Access-Control-Allow-Origin', '*');
    request.response.headers
        .set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers
        .set('Access-Control-Allow-Headers', 'Content-Type');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      continue;
    }

    if (WebSocketTransformer.isUpgradeRequest(request)) {
      final socket = await WebSocketTransformer.upgrade(request);
      lobbyManager.handleClient(socket);
    } else {
      // REST API
      final path = request.uri.path;
      if (path == '/api/health') {
        request.response
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(
              {'status': 'ok', 'time': DateTime.now().toIso8601String()}));
        await request.response.close();
      } else if (path == '/api/leaderboard') {
        final hallOfFame = db.getHallOfFame();
        request.response
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'leaderboard': hallOfFame}));
        await request.response.close();
      } else if (path == '/api/matches') {
        final matches = db.getRecentMatches();
        request.response
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'matches': matches}));
        await request.response.close();
      } else {
        request.response
          ..headers.contentType = ContentType.json
          ..statusCode = HttpStatus.notFound
          ..write(jsonEncode({'error': 'Not found'}));
        await request.response.close();
      }
    }
  }
}

class PlayerInfo {
  final String id;
  String name;
  String skin;
  final WebSocket socket;
  bool isReady = false;
  int score = 0;
  int patches = 0;
  int level = 1;
  bool isAlive = true;

  PlayerInfo({
    required this.id,
    required this.name,
    required this.skin,
    required this.socket,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'skin': skin,
        'isReady': isReady,
        'score': score,
        'patches': patches,
        'level': level,
        'isAlive': isAlive,
      };
}

enum RoomState { waiting, countdown, racing, finished }

class Room {
  final String code;
  final String hostId;
  final WebSocket hostSocket;
  RoomState state = RoomState.waiting;
  final Map<String, PlayerInfo> players = {};
  DateTime createdAt = DateTime.now();
  Timer? countdownTimer;

  Room({required this.code, required this.hostId, required this.hostSocket});

  Map<String, dynamic> toJson() => {
        'code': code,
        'hostId': hostId,
        'state': state.name,
        'players': players.values.map((p) => p.toJson()).toList(),
      };

  void broadcast(Map<String, dynamic> message) {
    final payload = jsonEncode(message);
    final recipients = <WebSocket>{
      hostSocket,
      for (final player in players.values) player.socket,
    };
    for (final s in recipients) {
      try {
        s.add(payload);
      } catch (e) {
        // Socket closed or error
      }
    }
  }
}

class LobbyManager {
  final DatabaseService db;
  final Map<String, Room> rooms = {};
  final Map<WebSocket, String> socketToPlayerId = {};
  final Map<WebSocket, String> socketToRoomCode = {};
  final Random _rng = Random();

  LobbyManager(this.db);

  void handleClient(WebSocket socket) {
    socket.listen(
      (data) {
        try {
          final message = jsonDecode(data as String) as Map<String, dynamic>;
          _processMessage(socket, message);
        } catch (e) {
          socket.add(
              jsonEncode({'type': 'error', 'message': 'Invalid JSON: $e'}));
        }
      },
      onDone: () => _handleDisconnect(socket),
      onError: (e) => _handleDisconnect(socket),
    );
  }

  void _handleDisconnect(WebSocket socket) {
    final code = socketToRoomCode[socket];
    final pid = socketToPlayerId[socket];
    socketToRoomCode.remove(socket);
    socketToPlayerId.remove(socket);

    if (code != null && rooms.containsKey(code)) {
      final room = rooms[code]!;
      if (pid != null) {
        room.players.remove(pid);
      }

      if (room.hostSocket == socket) {
        room.countdownTimer?.cancel();
        rooms.remove(code);
        print('🧹 Room $code destroyed (host disconnected)');
      } else if (room.players.isEmpty && room.state == RoomState.racing) {
        room.countdownTimer?.cancel();
        rooms.remove(code);
        print('🧹 Room $code destroyed (all players left)');
      } else {
        _checkRaceCompletion(room);
        room.broadcast({
          'type': 'room_updated',
          'room': room.toJson(),
        });
      }
    }
  }

  void _processMessage(WebSocket socket, Map<String, dynamic> message) {
    final type = message['type'] as String?;

    switch (type) {
      case 'create_room':
        _createRoom(socket, message);
        break;
      case 'join_room':
        _joinRoom(socket, message);
        break;
      case 'start_countdown':
        _startCountdown(socket, message);
        break;
      case 'score_update':
        _updateScore(socket, message);
        break;
      case 'leave_room':
        _handleDisconnect(socket);
        break;
      default:
        socket.add(
            jsonEncode({'type': 'error', 'message': 'Unknown action: $type'}));
    }
  }

  void _createRoom(WebSocket socket, Map<String, dynamic> message) {
    final isParticipant = message['isParticipant'] as bool? ?? false;
    final playerName = (message['playerName'] as String? ?? 'Host').trim();
    final skin = (message['skin'] as String? ?? 'blueBird').trim();
    final hostId =
        'h_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(999)}';

    // Generate readable 4-letter room code
    const words = [
      'BIRD',
      'RUSH',
      'WING',
      'DART',
      'CODE',
      'FAST',
      'NEON',
      'FLUT',
      'MEGA',
      'TURB',
      'HERO',
      'APEX'
    ];
    String code = words[_rng.nextInt(words.length)];
    if (rooms.containsKey(code)) {
      code = '$code${_rng.nextInt(9)}';
    }

    final room = Room(code: code, hostId: hostId, hostSocket: socket);

    if (isParticipant) {
      final player = PlayerInfo(
        id: hostId,
        name: playerName.isEmpty ? 'Host Pilot' : playerName,
        skin: skin,
        socket: socket,
      );
      room.players[hostId] = player;
    }

    rooms[code] = room;
    socketToPlayerId[socket] = hostId;
    socketToRoomCode[socket] = code;

    print(
        '🏠 Room created: $code by host ($hostId), isParticipant: $isParticipant, racers: ${room.players.length}');

    socket.add(jsonEncode({
      'type': 'room_created',
      'roomCode': code,
      'playerId': hostId,
      'isParticipant': isParticipant,
      'room': room.toJson(),
    }));
  }

  void _joinRoom(WebSocket socket, Map<String, dynamic> message) {
    final code = (message['roomCode'] as String? ?? '').trim().toUpperCase();
    final playerName = (message['playerName'] as String? ?? 'Player').trim();
    final skin = (message['skin'] as String? ?? 'goldPhoenix').trim();

    final room = rooms[code];
    if (room == null) {
      socket.add(jsonEncode({
        'type': 'join_failed',
        'message': 'Room "$code" not found. Please check code or create new.',
      }));
      return;
    }

    if (room.state == RoomState.racing) {
      socket.add(jsonEncode({
        'type': 'join_failed',
        'message': 'Race already in progress in room "$code".',
      }));
      return;
    }

    final existingPid = socketToPlayerId[socket];
    final playerId = (existingPid != null && existingPid.startsWith('h_'))
        ? existingPid
        : 'p_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(999)}';

    final player = PlayerInfo(
      id: playerId,
      name: playerName.isEmpty ? 'Challenger' : playerName,
      skin: skin,
      socket: socket,
    );

    room.players[playerId] = player;
    socketToPlayerId[socket] = playerId;
    socketToRoomCode[socket] = code;

    print(
        '👋 Player ${player.name} ($playerId) joined room $code (Total racers: ${room.players.length})');

    socket.add(jsonEncode({
      'type': 'join_success',
      'roomCode': code,
      'playerId': playerId,
      'room': room.toJson(),
    }));

    room.broadcast({
      'type': 'room_updated',
      'room': room.toJson(),
    });
  }

  void _startCountdown(WebSocket socket, Map<String, dynamic> message) {
    final code = socketToRoomCode[socket];
    final pid = socketToPlayerId[socket];
    if (code == null || !rooms.containsKey(code)) return;

    final room = rooms[code]!;
    if (room.hostId != pid) {
      socket.add(jsonEncode(
          {'type': 'error', 'message': 'Only the host can start the match'}));
      return;
    }

    if (room.players.isEmpty) {
      socket.add(jsonEncode({
        'type': 'error',
        'message':
            'Cannot start race: Waiting for participants to join with room code "$code"!'
      }));
      return;
    }

    room.state = RoomState.countdown;
    print('⏱ Starting countdown in room $code');

    int count = 3;
    room.broadcast({
      'type': 'countdown_tick',
      'count': count,
    });

    room.countdownTimer?.cancel();
    room.countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      count--;
      if (count > 0) {
        room.broadcast({
          'type': 'countdown_tick',
          'count': count,
        });
      } else {
        timer.cancel();
        room.state = RoomState.racing;
        for (final p in room.players.values) {
          p.isAlive = true;
          p.score = 0;
          p.patches = 0;
          p.level = 1;
        }
        room.broadcast({
          'type': 'race_start',
          'room': room.toJson(),
        });
        print('🏁 Race started in room $code!');
      }
    });
  }

  void _updateScore(WebSocket socket, Map<String, dynamic> message) {
    final code = socketToRoomCode[socket];
    final pid = socketToPlayerId[socket];
    if (code == null || !rooms.containsKey(code)) return;

    final room = rooms[code]!;
    final player = room.players[pid];
    if (player == null) return;

    player.score = (message['score'] as num? ?? player.score).toInt();
    player.patches = (message['patches'] as num? ?? player.patches).toInt();
    player.level = (message['level'] as num? ?? player.level).toInt();
    player.isAlive = message['isAlive'] as bool? ?? player.isAlive;

    // Broadcast live leaderboard to all racers
    final sorted = room.players.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    room.broadcast({
      'type': 'leaderboard_update',
      'standings': sorted.map((p) => p.toJson()).toList(),
    });

    _checkRaceCompletion(room);
  }

  void _checkRaceCompletion(Room room) {
    if (room.state != RoomState.racing) return;

    // Race ends when all players have crashed or left
    final anyAlive = room.players.values.any((p) => p.isAlive);
    if (!anyAlive && room.players.isNotEmpty) {
      room.state = RoomState.finished;
      print('🏆 Race in room ${room.code} ended! Calculating podium...');

      final sorted = room.players.values.toList()
        ..sort((a, b) => b.score.compareTo(a.score));

      final rankings = <Map<String, dynamic>>[];
      for (int i = 0; i < sorted.length; i++) {
        final p = sorted[i];
        rankings.add({
          'rank': i + 1,
          'id': p.id,
          'name': p.name,
          'skin': p.skin,
          'score': p.score,
          'patches': p.patches,
          'level': p.level,
        });
        // Save player record to database
        db.recordScore(p.name, p.score, p.patches);
      }

      // Record match in DB
      db.recordMatch(room.code, rankings);

      room.broadcast({
        'type': 'match_finished',
        'rankings': rankings,
      });
    }
  }
}

/// Persistent File-based JSON Database
class DatabaseService {
  late final File dbFile;
  Map<String, dynamic> _data = {
    'hall_of_fame': <Map<String, dynamic>>[],
    'matches': <Map<String, dynamic>>[],
  };

  Future<void> init() async {
    final dir = Directory('bin/data');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    dbFile = File('bin/data/db.json');
    if (await dbFile.exists()) {
      try {
        final content = await dbFile.readAsString();
        _data = jsonDecode(content) as Map<String, dynamic>;
        print('📂 Loaded database from ${dbFile.path}');
      } catch (e) {
        print('⚠️ Could not parse existing db.json, initializing fresh: $e');
        await _save();
      }
    } else {
      await _save();
      print('📂 Created fresh database at ${dbFile.path}');
    }
  }

  Future<void> _save() async {
    try {
      await dbFile
          .writeAsString(const JsonEncoder.withIndent('  ').convert(_data));
    } catch (e) {
      print('Error saving database: $e');
    }
  }

  void recordScore(String name, int score, int patches) {
    final list = List<Map<String, dynamic>>.from(_data['hall_of_fame'] ?? []);
    list.add({
      'name': name,
      'score': score,
      'patches': patches,
      'timestamp': DateTime.now().toIso8601String(),
    });
    list.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    // Keep top 50 scores
    if (list.length > 50) {
      list.removeRange(50, list.length);
    }
    _data['hall_of_fame'] = list;
    _save();
  }

  void recordMatch(String roomCode, List<Map<String, dynamic>> rankings) {
    final matches = List<Map<String, dynamic>>.from(_data['matches'] ?? []);
    matches.insert(0, {
      'roomCode': roomCode,
      'timestamp': DateTime.now().toIso8601String(),
      'winner': rankings.isNotEmpty ? rankings.first['name'] : 'Unknown',
      'rankings': rankings,
    });
    // Keep recent 100 matches
    if (matches.length > 100) {
      matches.removeRange(100, matches.length);
    }
    _data['matches'] = matches;
    _save();
  }

  List<Map<String, dynamic>> getHallOfFame() {
    return List<Map<String, dynamic>>.from(_data['hall_of_fame'] ?? []);
  }

  List<Map<String, dynamic>> getRecentMatches() {
    return List<Map<String, dynamic>>.from(_data['matches'] ?? []);
  }
}
