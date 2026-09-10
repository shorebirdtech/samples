import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/core/constants/constants.dart';
import 'package:shorebird_runner/features/lead_capture/bloc/bloc.dart';
import 'package:shorebird_runner/features/lead_capture/data/event_config_service.dart';

/// Secret dialog triggered by tapping the Shorebird Logo 3 times on the start screen.
/// Allows booth staff to set or clear the conference event name attached to each lead.
class EventConfigDialog extends StatefulWidget {
  const EventConfigDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Event Config',
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, _, __) => const EventConfigDialog(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curved =
            CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: curved,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<EventConfigDialog> createState() => _EventConfigDialogState();
}

class _EventConfigDialogState extends State<EventConfigDialog> {
  final _controller = TextEditingController();
  final _service = const EventConfigService();
  String _currentEvent = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentEvent();
  }

  Future<void> _loadCurrentEvent() async {
    final active = await _service.getActiveEvent();
    if (mounted) {
      setState(() {
        _currentEvent = active;
        _controller.text = active;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveEvent() async {
    final name = _controller.text.trim();
    await _service.setActiveEvent(name);
    if (!mounted) return;
    context.read<LeadCaptureBloc>().add(LeadEventUpdated(name));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E293B),
        content: Text(
          name.isNotEmpty
              ? '✓ Active event set to "$name"'
              : '✓ Active event cleared.',
          style: const TextStyle(
            color: AppColors.shorebirdGold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _clearEvent() async {
    _controller.clear();
    await _saveEvent();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D131F),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.shorebirdGold.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shorebirdGold.withValues(alpha: 0.1),
                blurRadius: 36,
                offset: const Offset(0, 8),
              ),
              const BoxShadow(
                color: Colors.black87,
                blurRadius: 40,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top accent line
                Container(
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.goldAmber,
                        AppColors.shorebirdGold,
                        AppColors.goldAmber,
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.settings_suggest_rounded,
                                color: AppColors.shorebirdGold,
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'BOOTH EVENT CONFIG',
                                style: TextStyle(
                                  color: AppColors.shorebirdGold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.slateMuted,
                              size: 20,
                            ),
                            splashRadius: 20,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Set Event Tag',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF1F5F9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'The event name configured here will automatically attach to every lead captured during this booth session.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.slateSubtle,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.shorebirdGold,
                            ),
                          ),
                        )
                      else ...[
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131C2E),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: AppColors.shorebirdGold,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _currentEvent.isNotEmpty
                                      ? 'Active: $_currentEvent'
                                      : 'No event set (leads will have blank event)',
                                  style: TextStyle(
                                    color: _currentEvent.isNotEmpty
                                        ? const Color(0xFFF1F5F9)
                                        : AppColors.slateMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Text Field
                        const Text(
                          'EVENT NAME',
                          style: TextStyle(
                            color: AppColors.slateMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _controller,
                          autofocus: true,
                          style: const TextStyle(
                            color: Color(0xFFF1F5F9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF131C2E),
                            hintText: 'e.g. FlutterCon Berlin, Google I/O 2026',
                            hintStyle: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.event_note_rounded,
                              color: AppColors.slateMuted,
                              size: 18,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF1E293B),
                                width: 1.2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.shorebirdGold,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          children: [
                            if (_currentEvent.isNotEmpty) ...[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _clearEvent,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFEF4444),
                                    side: BorderSide(
                                      color: const Color(0xFFEF4444)
                                          .withValues(alpha: 0.4),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'CLEAR',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: _saveEvent,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.shorebirdGold,
                                  foregroundColor: const Color(0xFF0F172A),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'SAVE EVENT',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
