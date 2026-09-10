import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/core/constants/constants.dart';
import 'package:shorebird_runner/features/lead_capture/bloc/bloc.dart';
import 'package:shorebird_runner/features/lead_capture/models/lead_model.dart';
import 'package:shorebird_runner/features/start_menu/widgets/shorebird_logo.dart';

/// Highly polished developer briefing modal to capture player details before launching the solo runner.
class LeadCaptureDialog extends StatefulWidget {
  final void Function(LeadModel lead) onStartGame;

  const LeadCaptureDialog({
    super.key,
    required this.onStartGame,
  });

  static Future<void> show(
    BuildContext context, {
    required void Function(LeadModel lead) onStartGame,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Lead Capture',
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, anim1, anim2) =>
          LeadCaptureDialog(onStartGame: onStartGame),
      transitionBuilder: (context, anim1, anim2, child) {
        final curved =
            CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: curved,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<LeadCaptureDialog> createState() => _LeadCaptureDialogState();
}

class _LeadCaptureDialogState extends State<LeadCaptureDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _orgController;

  @override
  void initState() {
    super.initState();
    final state = context.read<LeadCaptureBloc>().state;
    _nameController = TextEditingController(text: state.name);
    _emailController = TextEditingController(text: state.email);
    _phoneController = TextEditingController(text: state.phone);
    _orgController = TextEditingController(text: state.organization);
  }

  bool _consentGiven = false;
  String? _consentError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _orgController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _consentError = !_consentGiven
          ? 'Please check the box to allow data sharing with Shorebird.'
          : null;
    });

    if (!_consentGiven) return;

    if (_formKey.currentState?.validate() ?? false) {
      final bloc = context.read<LeadCaptureBloc>();
      bloc.add(LeadNameChanged(_nameController.text.trim()));
      bloc.add(LeadEmailChanged(_emailController.text.trim()));
      bloc.add(LeadPhoneChanged(_phoneController.text.trim()));
      bloc.add(LeadOrgChanged(_orgController.text.trim()));
      bloc.add(const LeadSubmitted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LeadCaptureBloc, LeadCaptureState>(
      listener: (context, state) {
        if (state.status == LeadSubmissionStatus.success &&
            state.submittedLead != null) {
          Navigator.of(context).pop();
          widget.onStartGame(state.submittedLead!);
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == LeadSubmissionStatus.submitting;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D131F),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.shorebirdGold.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shorebirdGold.withValues(alpha: 0.08),
                    blurRadius: 36,
                    spreadRadius: 2,
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
                    // Top Accent Banner
                    Container(
                      height: 4,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.goldAmber,
                            AppColors.shorebirdGold,
                            AppColors.goldPale,
                            AppColors.shorebirdGold,
                          ],
                        ),
                      ),
                    ),

                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Top Bar: Logo & Close
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Transform.scale(
                                        scale: 0.65,
                                        alignment: Alignment.centerLeft,
                                        child: const ShorebirdLogo(),
                                      ),
                                      const SizedBox(width: 8),
                                      const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'PATCH RUSH',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.shorebirdGold,
                                              letterSpacing: 3,
                                            ),
                                          ),
                                          Text(
                                            'DEVELOPER DISPATCH',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.slateMuted,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ],
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
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Headline
                              const Text(
                                'Join the Patch Run',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFF1F5F9),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Provide your developer details to record your telemetry, climb the leaderboard, and unlock real-time OTA hot patches.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.slateSubtle,
                                  height: 1.4,
                                ),
                              ),

                              if (state.event.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.shorebirdGold
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.shorebirdGold
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        size: 14,
                                        color: AppColors.shorebirdGold,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'EVENT: ${state.event.toUpperCase()}',
                                        style: const TextStyle(
                                          color: AppColors.shorebirdGold,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 24),

                              // Field 1: Full Name
                              _buildField(
                                controller: _nameController,
                                label: 'FULL NAME',
                                hint: 'e.g. Alex Rivera',
                                icon: Icons.person_outline_rounded,
                                validator: (val) {
                                  if (val == null || val.trim().length < 2) {
                                    return 'Please enter your full name';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Field 2: Email
                              _buildField(
                                controller: _emailController,
                                label: 'WORK / DEV EMAIL',
                                hint: 'e.g. alex@company.com',
                                icon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val == null ||
                                      !val.contains('@') ||
                                      !val.contains('.')) {
                                    return 'Please enter a valid work email';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Field 3: Phone (Optional)
                              _buildField(
                                controller: _phoneController,
                                label: 'CONTACT NUMBER (OPTIONAL)',
                                hint: 'e.g. +1 (555) 019-2834',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return null;
                                  }
                                  if (val
                                          .trim()
                                          .replaceAll(RegExp(r'[^0-9]'), '')
                                          .length <
                                      6) {
                                    return 'Please enter a valid phone number or leave blank';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Field 4: Organization
                              _buildField(
                                controller: _orgController,
                                label: 'ORGANIZATION / COMPANY',
                                hint: 'e.g. Acme Corp or Independent',
                                icon: Icons.apartment_rounded,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter your company or organization';
                                  }
                                  return null;
                                },
                              ),

                              if (state.errorMessage != null) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFEF4444)
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    state.errorMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFFFCA5A5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 20),

                              // Consent Checkbox Row
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    _consentGiven = !_consentGiven;
                                    if (_consentGiven) _consentError = null;
                                  });
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: Checkbox(
                                        value: _consentGiven,
                                        activeColor: AppColors.shorebirdGold,
                                        checkColor: const Color(0xFF0F172A),
                                        side: BorderSide(
                                          color: _consentError != null
                                              ? const Color(0xFFEF4444)
                                              : const Color(0xFF475569),
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            _consentGiven = val ?? false;
                                            if (_consentGiven) {
                                              _consentError = null;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'I agree to share my information with Shorebird.',
                                            style: TextStyle(
                                              color: Color(0xFFE2E8F0),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              height: 1.3,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          const Text(
                                            'We capture this data solely for developer leads and determining game/booth winners.',
                                            style: TextStyle(
                                              color: AppColors.slateMuted,
                                              fontSize: 11,
                                              height: 1.35,
                                            ),
                                          ),
                                          if (_consentError != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              _consentError!,
                                              style: const TextStyle(
                                                color: Color(0xFFF87171),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Primary Submit CTA Button
                              ElevatedButton(
                                onPressed: isSubmitting ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.shorebirdGold,
                                  foregroundColor: const Color(0xFF0F172A),
                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Color(0xFF0F172A),
                                          ),
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'START PATCHING',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.slateMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Color(0xFFF1F5F9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF131C2E),
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 13,
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.slateMuted,
              size: 18,
            ),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1.5,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
