import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/core/constants/constants.dart';
import 'package:shorebird_runner/features/tournament_lobby/bloc/lobby_bloc.dart';
import 'package:shorebird_runner/features/tournament_lobby/data/data.dart';

class ServerConfigDialog extends StatefulWidget {
  const ServerConfigDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const ServerConfigDialog(),
    );
  }

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> {
  late final TextEditingController _serverController;

  @override
  void initState() {
    super.initState();
    final repo = context.read<ILobbyRepository>();
    _serverController = TextEditingController(text: repo.defaultServerUrl);
  }

  @override
  void dispose() {
    _serverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ILobbyRepository>();
    return AlertDialog(
      backgroundColor: AppColors.darkNavy,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cyan, width: 1.5),
      ),
      title: const Row(
        children: [
          Icon(Icons.dns, color: AppColors.cyan),
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
            style: TextStyle(color: AppColors.slateBlue, fontSize: 13),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _serverController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'ws://localhost:8088',
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: AppColors.darkSlate,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cyan,
            foregroundColor: Colors.black,
          ),
          onPressed: () {
            final newUrl = _serverController.text.trim();
            if (newUrl.isNotEmpty) {
              repo.setCustomServerUrl(newUrl);
              context.read<LobbyBloc>().add(const ConnectLobby());
            }
            Navigator.of(context).pop();
          },
          child: const Text(
            'Save & Reconnect',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
