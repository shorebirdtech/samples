import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/core/core.dart';
import 'package:shorebird_runner/features/tournament_lobby/bloc/lobby_bloc.dart';
import 'package:shorebird_runner/features/tournament_lobby/data/data.dart';
import 'package:shorebird_runner/features/tournament_lobby/widgets/widgets.dart';

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
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  final List<String> _suggestedNames = [
    'SkyWalker',
    'HyperWing',
    'ShorePilot',
    'CyberFalcon',
    'NeoRunner',
    'TurboBird',
    'AeroAce',
    'QuantumJet',
  ];

  String _getInviteUrl(String roomCode, String serverUrl) {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      if (serverUrl.isNotEmpty && serverUrl != 'ws://localhost:8088') {
        return '$origin/?room=$roomCode&server=${Uri.encodeComponent(serverUrl)}';
      }
      return '$origin/?room=$roomCode';
    }
    return 'https://patch-rush.netlify.app/?room=$roomCode';
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
    context.read<LobbyBloc>().add(const ConnectLobby());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onCreateRoom({required bool hostRaces}) {
    AudioService.playSelect();
    final skin = context.read<LobbyBloc>().state.selectedSkin;
    context.read<LobbyBloc>().add(
          CreateRoomRequested(
            isParticipant: hostRaces,
            playerName: hostRaces ? _nameController.text.trim() : 'Host',
            skin: skin,
          ),
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
    final skin = context.read<LobbyBloc>().state.selectedSkin;
    context.read<LobbyBloc>().add(
          JoinRoomRequested(
            roomCode: code,
            playerName: _nameController.text,
            skin: skin,
          ),
        );
  }

  void _onStartRace() {
    AudioService.playSelect();
    context.read<LobbyBloc>().add(const StartCountdownRequested());
  }

  void _onLeaveRoom() {
    AudioService.playSelect();
    context.read<LobbyBloc>().add(const LeaveRoomRequested());
  }

  void _showServerConfigDialog() {
    ServerConfigDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LobbyBloc, LobbyState>(
      listener: (context, state) {
        if (state.isRacing) {
          widget.onRaceStarted();
        }
      },
      builder: (context, state) {
        final repo = context.read<ILobbyRepository>();
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
                        AppColors.deepNavy.withValues(alpha: 0.8),
                        AppColors.roadDark,
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    LobbyHeader(
                      onBack: () {
                        AudioService.playSelect();
                        _onLeaveRoom();
                        widget.onBackToMenu();
                      },
                      isConnected: state.isConnected,
                      onConfigureServer: _showServerConfigDialog,
                    ),

                    // Error banner if any
                    if (state.errorMessage != null)
                      ErrorBanner(
                        message: state.errorMessage!,
                        onChangeServer: _showServerConfigDialog,
                      ),

                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 850),
                          child: state.roomCode == null
                              ? SetupView(
                                  nameController: _nameController,
                                  codeController: _codeController,
                                  onCreateAsSpectator: () =>
                                      _onCreateRoom(hostRaces: false),
                                  onCreateAsRacer: () =>
                                      _onCreateRoom(hostRaces: true),
                                  onJoinRoom: _onJoinRoom,
                                )
                              : _buildRoomWaitingView(context, state, repo),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Countdown Overlay
              if (state.countdown > 0) CountdownOverlay(count: state.countdown),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoomWaitingView(
    BuildContext context,
    LobbyState state,
    ILobbyRepository repo,
  ) {
    final isHost = state.isHost;
    final players = state.players;
    final inviteUrl =
        _getInviteUrl(state.roomCode ?? '', repo.defaultServerUrl);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoomCodeCard(
            roomCode: state.roomCode ?? '',
            isHost: isHost,
            inviteUrl: inviteUrl,
          ),

          const SizedBox(height: 20),

          // Spectator Banner (if host is not a participant)
          if (state.isSpectator)
            SpectatorBanner(
              nameControllerText: _nameController.text.trim(),
            ),

          PlayerListCard(
            players: players,
            myPlayerId: state.myPlayerId,
          ),

          const SizedBox(height: 24),

          // Action Buttons
          if (isHost)
            LaunchRaceButton(
              playerCount: players.length,
              onStartRace: _onStartRace,
            )
          else
            const WaitingForHostBanner(),

          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: _onLeaveRoom,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white60,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child:
                const Text('LEAVE ROOM', style: TextStyle(letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }
}
