import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/constants/constants.dart';

class LobbyHeader extends StatelessWidget {
  final VoidCallback onBack;
  final bool isConnected;
  final VoidCallback onConfigureServer;

  const LobbyHeader({
    super.key,
    required this.onBack,
    required this.isConnected,
    required this.onConfigureServer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
            tooltip: 'Back to Menu',
            onPressed: onBack,
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
                      color: isConnected
                          ? AppColors.neonGreen
                          : AppColors.shorebirdAmber,
                      boxShadow: [
                        BoxShadow(
                          color: isConnected
                              ? AppColors.neonGreen
                              : AppColors.shorebirdAmber,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: onConfigureServer,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Row(
                        children: [
                          Text(
                            isConnected ? 'SERVER CONNECTED' : 'DISCONNECTED',
                            style: TextStyle(
                              color: isConnected
                                  ? AppColors.neonGreen
                                  : AppColors.shorebirdAmber,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.settings,
                            size: 13,
                            color: AppColors.slateBlue,
                          ),
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
    );
  }
}
