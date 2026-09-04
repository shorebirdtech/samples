import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shorebird_runner/game/components/player.dart';
import 'package:shorebird_runner/game/utils/audio_service.dart';
import 'package:shorebird_runner/game/utils/game_config.dart';
import 'package:shorebird_runner/services/lobby_service.dart';
import 'package:shorebird_runner/widgets/game_rules_dialog.dart';

class LobbyScreen extends StatefulWidget {
  final VoidCallback onBackToMenu;
  final VoidCallback onRaceStarted;

  const LobbyScreen({
    super.key,
    required this.onBackToMenu,
    required this.onRaceStarted,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final _lobby = LobbyService.instance;
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  PlayerSkin _selectedSkin = PlayerSkin.blueBird;
  bool _isConnecting = false;
  bool _hostAlsoRaces = false;

  final List<String> _suggestedNames = [
    'SkyWalker',
    'HyperWing',
    'ShorePilot',
    'CyberFalcon',
    'NeoRunner',
    'TurboBird',
    'AeroAce',
    'QuantumJet'
  ];

  String get _inviteUrl {
    final code = _lobby.currentRoomCode ?? '';
    if (kIsWeb) {
      final origin = Uri.base.origin;
      final server = _lobby.defaultServerUrl;
      if (server.isNotEmpty && server != 'ws://localhost:8088') {
        return '$origin/?room=$code&server=${Uri.encodeComponent(server)}';
      }
      return '$origin/?room=$code';
    }
    return 'https://patch-rush.netlify.app/?room=$code';
  }

  @override
  void initState() {
    super.initState();
    final randomName =
        _suggestedNames[Random().nextInt(_suggestedNames.length)];
    _nameController.text = randomName;
    if (kIsWeb) {
      final inviteCode = Uri.base.queryParameters['room'];
      if (inviteCode != null && inviteCode.trim().isNotEmpty) {
        _codeController.text = inviteCode.trim().toUpperCase();
      }
    }
    _lobby.addListener(_onLobbyChanged);
    _connectToServer();
  }

  void _connectToServer() async {
    setState(() => _isConnecting = true);
    await _lobby.ensureConnected();
    if (mounted) setState(() => _isConnecting = false);
  }

  @override
  void dispose() {
    _lobby.removeListener(_onLobbyChanged);
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onLobbyChanged() {
    if (!mounted) return;
    if (_lobby.isRacing) {
      widget.onRaceStarted();
    } else {
      setState(() {});
    }
  }

  void _onCreateRoom() {
    AudioService.playSelect();
    _lobby.createRoom(
      isParticipant: _hostAlsoRaces,
      playerName: _hostAlsoRaces ? _nameController.text.trim() : null,
      skin: _hostAlsoRaces ? _selectedSkin : null,
    );
  }

  void _onJoinRoom() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 4-letter room code')),
      );
      return;
    }
    AudioService.playSelect();
    _lobby.joinRoom(code, _nameController.text, _selectedSkin);
  }

  void _onStartRace() {
    AudioService.playSelect();
    _lobby.startCountdown();
  }

  void _onLeaveRoom() {
    AudioService.playSelect();
    _lobby.leaveRoom();
  }

  void _showServerConfigDialog() {
    final serverController =
        TextEditingController(text: _lobby.defaultServerUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF00D4FF), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.dns, color: Color(0xFF00D4FF)),
            SizedBox(width: 8),
            Text(
              'LOBBY SERVER CONFIG',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Specify the WebSocket address of your lobby server (e.g. ws://localhost:8088, ws://192.168.1.50:8088, or wss://your-domain.com):',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: serverController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'ws://localhost:8088',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL',
                style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4FF),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              final newUrl = serverController.text.trim();
              Navigator.of(ctx).pop();
              if (newUrl.isNotEmpty) {
                _lobby.reconnect(newUrl);
              }
            },
            child: const Text('CONNECT',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(GameConfig.colorBg),
      body: Stack(
        children: [
          // Background ambient grid
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    const Color(0xFF0D253A).withValues(alpha: 0.8),
                    const Color(0xFF050A14),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white70),
                        tooltip: 'Back to Menu',
                        onPressed: () {
                          AudioService.playSelect();
                          _lobby.leaveRoom();
                          widget.onBackToMenu();
                        },
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BOOTH MULTIPLAYER LOBBY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _lobby.isConnected
                                      ? const Color(0xFF00FF88)
                                      : Colors.amber,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _lobby.isConnected
                                          ? const Color(0xFF00FF88)
                                          : Colors.amber,
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: _showServerConfigDialog,
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 2),
                                  child: Row(
                                    children: [
                                      Text(
                                        _lobby.isConnected
                                            ? 'SERVER CONNECTED'
                                            : (_isConnecting
                                                ? 'CONNECTING...'
                                                : 'DISCONNECTED'),
                                        style: TextStyle(
                                          color: _lobby.isConnected
                                              ? const Color(0xFF00FF88)
                                              : Colors.amber,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.settings,
                                          size: 13, color: Color(0xFF94A3B8)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Error banner if any
                if (_lobby.errorMessage != null)
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2A4B).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFF2A4B)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Color(0xFFFF2A4B), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _lobby.errorMessage!,
                            style: const TextStyle(
                                color: Color(0xFFFF8899), fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00D4FF),
                            side: const BorderSide(color: Color(0xFF00D4FF)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: _showServerConfigDialog,
                          child: const Text('Change Server',
                              style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 850),
                      child: _lobby.currentRoomCode == null
                          ? _buildSetupView()
                          : _buildRoomWaitingView(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Countdown Overlay
          if (_lobby.countdown > 0) _buildCountdownOverlay(),
        ],
      ),
    );
  }

  Widget _buildSetupView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Setup Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A192F).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'DEVELOPER PROFILE',
                      style: TextStyle(
                        color: Color(0xFF00D4FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => showGameRulesDialog(context),
                      icon: const Icon(Icons.menu_book,
                          size: 15, color: Color(0xFF00FF88)),
                      label: const Text(
                        'Rules',
                        style: TextStyle(
                          color: Color(0xFF00FF88),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'DEVELOPER HANDLE',
                    labelStyle:
                        const TextStyle(color: Colors.white60, fontSize: 12),
                    prefixIcon: const Icon(Icons.sports_esports,
                        color: Color(0xFF00D4FF)),
                    filled: true,
                    fillColor: const Color(0xFF050F1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFF00D4FF), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'CHOOSE DEVELOPER PERSONA',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _skinChoiceChip(PlayerSkin.blueBird, '👨‍💻 Shorebird Dev',
                        const Color(0xFF00D4FF)),
                    _skinChoiceChip(PlayerSkin.goldPhoenix,
                        '🧑‍💻 Frontend Ninja', const Color(0xFFFFB347)),
                    _skinChoiceChip(PlayerSkin.emeraldFalcon,
                        '⚡ Fullstack Hero', const Color(0xFF00FF88)),
                    _skinChoiceChip(PlayerSkin.violetRaven, '👾 Bug Hunter',
                        const Color(0xFFA855F7)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action Split: Create vs Join
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 650;
              final cards = [
                Expanded(
                  flex: isNarrow ? 0 : 1,
                  child: _buildCreateCard(),
                ),
                if (!isNarrow)
                  const SizedBox(width: 20)
                else
                  const SizedBox(height: 16),
                Expanded(
                  flex: isNarrow ? 0 : 1,
                  child: _buildJoinCard(),
                ),
              ];

              return isNarrow
                  ? Column(children: cards)
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: cards);
            },
          ),
        ],
      ),
    );
  }

  Widget _skinChoiceChip(PlayerSkin skin, String label, Color color) {
    final isSelected = _selectedSkin == skin;
    return InkWell(
      onTap: () {
        AudioService.playSelect();
        setState(() => _selectedSkin = skin);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.25)
              : const Color(0xFF050F1E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: color.withValues(alpha: 0.4), blurRadius: 10),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0A192F).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFF00FF88).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF88).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_circle_outline,
                    color: Color(0xFF00FF88), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOST TOURNAMENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Create room without participant; attendees join from devices',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Toggle whether host also participates as a racer
          InkWell(
            onTap: () {
              setState(() {
                _hostAlsoRaces = !_hostAlsoRaces;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _hostAlsoRaces
                      ? const Color(0xFF00FF88).withValues(alpha: 0.5)
                      : Colors.white12,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _hostAlsoRaces
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: _hostAlsoRaces
                        ? const Color(0xFF00FF88)
                        : Colors.white54,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Host also races on this device',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _hostAlsoRaces ? 'PARTICIPATING' : 'SPECTATOR ONLY',
                    style: TextStyle(
                      color: _hostAlsoRaces
                          ? const Color(0xFF00FF88)
                          : const Color(0xFF00D4FF),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _onCreateRoom,
            icon: Icon(
              _hostAlsoRaces ? Icons.sports_esports : Icons.tv,
              color: Colors.black,
              size: 20,
            ),
            label: Text(
              _hostAlsoRaces ? 'CREATE ROOM & RACE' : 'CREATE ROOM (SPECTATOR)',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF88),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 8,
              shadowColor: const Color(0xFF00FF88).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0A192F).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFFFFB347).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB347).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.vpn_key_outlined,
                    color: Color(0xFFFFB347), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JOIN ROOM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Enter 4-character code from host',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFB347),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.0,
                  ),
                  decoration: InputDecoration(
                    hintText: 'CODE',
                    hintStyle: const TextStyle(
                        color: Colors.white24, letterSpacing: 2.0),
                    filled: true,
                    fillColor: const Color(0xFF050F1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _onJoinRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB347),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'JOIN',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomWaitingView() {
    final isHost = _lobby.isHost;
    final players = _lobby.players;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Room Code Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00D4FF).withValues(alpha: 0.15),
                  const Color(0xFF050A14),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00D4FF), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'SHARE ROOM CODE WITH BOOTH ATTENDEES',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _lobby.currentRoomCode ?? '',
                      style: const TextStyle(
                        color: Color(0xFF00D4FF),
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8.0,
                        shadows: [
                          Shadow(
                            color: Color(0xFF00D4FF),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Color(0xFF00D4FF)),
                      tooltip: 'Copy Code',
                      onPressed: () {
                        if (_lobby.currentRoomCode != null) {
                          Clipboard.setData(
                              ClipboardData(text: _lobby.currentRoomCode!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Room code copied to clipboard!')),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isHost
                      ? '👑 YOU ARE THE TOURNAMENT HOST'
                      : 'WAITING FOR HOST TO START RACE...',
                  style: TextStyle(
                    color: isHost ? const Color(0xFFFFD700) : Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 16),

                // QR Code for quick phone camera scan across different devices
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1424),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF00D4FF).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 10,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(6),
                          child: QrImageView(
                            data: _inviteUrl,
                            version: QrVersions.auto,
                            size: 110,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.qr_code_scanner,
                                  color: Color(0xFF00D4FF), size: 16),
                              SizedBox(width: 6),
                              Text(
                                'SCAN TO JOIN ON PHONE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Point any mobile phone camera\nto auto-join this room instantly.',
                            style: TextStyle(
                                color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF00D4FF),
                                  side: BorderSide(
                                      color: const Color(0xFF00D4FF)
                                          .withValues(alpha: 0.5)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: const Icon(Icons.link, size: 14),
                                label: const Text('Copy Invite Link',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: _inviteUrl));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Invite link copied! Share with attendees.')),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF00FF88),
                                  side: BorderSide(
                                      color: const Color(0xFF00FF88)
                                          .withValues(alpha: 0.5)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: const Icon(Icons.menu_book, size: 14),
                                label: const Text('Rules',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                                onPressed: () => showGameRulesDialog(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Spectator Banner (if host is not a participant)
          if (_lobby.isSpectator)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF00D4FF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF00D4FF).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tv, color: Color(0xFF00D4FF), size: 22),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BIG SCREEN / SPECTATOR BOARD',
                          style: TextStyle(
                            color: Color(0xFF00D4FF),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'This screen hosts the live spectator view. Attendees join from their phones.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _lobby.joinAsParticipant(
                        _nameController.text.trim().isEmpty
                            ? 'Host Pilot'
                            : _nameController.text.trim(),
                        _selectedSkin,
                      );
                    },
                    icon: const Icon(Icons.sports_esports,
                        size: 16, color: Color(0xFF00FF88)),
                    label: const Text(
                      'Join as Racer',
                      style: TextStyle(
                        color: Color(0xFF00FF88),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Racers in Lobby list
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A192F).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CONNECTED DEVELOPERS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: players.isEmpty
                            ? Colors.orange.withValues(alpha: 0.15)
                            : const Color(0xFF00FF88).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        players.isEmpty
                            ? '0 JOINED'
                            : '${players.length} READY',
                        style: TextStyle(
                          color: players.isEmpty
                              ? Colors.orange
                              : const Color(0xFF00FF88),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (players.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF050F1E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Column(
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF00D4FF)),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'AWAITING DEVELOPERS TO JOIN...',
                          style: TextStyle(
                            color: Color(0xFF00D4FF),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Scan the QR code above or enter room code on mobile devices.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  )
                else
                  ...players.map((p) {
                    final isMe = p.id == _lobby.myPlayerId;
                    final isRoomHost = p.id == _lobby.players.firstOrNull?.id;

                    Color skinColor = const Color(0xFF00D4FF);
                    String skinEmoji = '👨‍💻';
                    if (p.skin == PlayerSkin.goldPhoenix) {
                      skinColor = const Color(0xFFFFB347);
                      skinEmoji = '🧑‍💻';
                    } else if (p.skin == PlayerSkin.emeraldFalcon) {
                      skinColor = const Color(0xFF00FF88);
                      skinEmoji = '⚡';
                    } else if (p.skin == PlayerSkin.violetRaven) {
                      skinColor = const Color(0xFFA855F7);
                      skinEmoji = '👾';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isMe
                            ? const Color(0xFF00D4FF).withValues(alpha: 0.12)
                            : const Color(0xFF050F1E),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              isMe ? const Color(0xFF00D4FF) : Colors.white10,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(skinEmoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      p.name,
                                      style: TextStyle(
                                        color: isMe
                                            ? const Color(0xFF00D4FF)
                                            : Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (isMe)
                                      Container(
                                        margin: const EdgeInsets.only(left: 6),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00D4FF)
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'YOU',
                                          style: TextStyle(
                                            color: Color(0xFF00D4FF),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    if (isRoomHost)
                                      Container(
                                        margin: const EdgeInsets.only(left: 6),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFD700)
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          '👑 HOST',
                                          style: TextStyle(
                                            color: Color(0xFFFFD700),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Text(
                                  p.skin.displayName,
                                  style: TextStyle(
                                      color: skinColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle,
                              color: Color(0xFF00FF88), size: 18),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          if (isHost)
            ElevatedButton.icon(
              onPressed: players.isEmpty ? null : _onStartRace,
              icon: Icon(
                players.isEmpty ? Icons.hourglass_empty : Icons.play_arrow,
                color: Colors.black,
                size: 24,
              ),
              label: Text(
                players.isEmpty
                    ? 'WAITING FOR DEVELOPERS (0 JOINED)'
                    : 'LAUNCH RACE (${players.length} READY) 🚀',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 1.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: players.isEmpty
                    ? Colors.grey.shade600
                    : const Color(0xFF00FF88),
                disabledBackgroundColor: Colors.grey.shade700,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: players.isEmpty ? 0 : 12,
                shadowColor: const Color(0xFF00FF88).withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF00D4FF)),
                    ),
                  ),
                  SizedBox(width: 14),
                  Text(
                    'WAITING FOR HOST TO LAUNCH...',
                    style: TextStyle(
                      color: Color(0xFF00D4FF),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: _onLeaveRoom,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white60,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child:
                const Text('LEAVE ROOM', style: TextStyle(letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownOverlay() {
    final count = _lobby.countdown;
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GET READY!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$count',
              style: const TextStyle(
                color: Color(0xFF00FF88),
                fontSize: 120,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(color: Color(0xFF00FF88), blurRadius: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
