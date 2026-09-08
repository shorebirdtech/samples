import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/core.dart';
import 'package:shorebird_runner/features/start_menu/widgets/rule_section_card.dart';

void showGameRulesDialog(BuildContext context, {VoidCallback? onStart}) {
  GameRulesDialog.show(context, onStart: onStart);
}

class GameRulesDialog extends StatelessWidget {
  final VoidCallback? onStart;

  const GameRulesDialog({super.key, this.onStart});

  static void show(BuildContext context, {VoidCallback? onStart}) {
    AudioService.playSelect();
    showDialog(
      context: context,
      builder: (ctx) => GameRulesDialog(onStart: onStart),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 680),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.panelNavy,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.cyan.withValues(alpha: 0.6),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyan.withValues(alpha: 0.25),
                blurRadius: 30,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 40,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.dialogNavy,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.cyan.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.shorebirdGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.shorebirdGold.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Text('⚡', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.rulesTitle,
                            style: TextStyle(
                              color: AppColors.shorebirdGold,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            AppStrings.rulesSub,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white60,
                        size: 20,
                      ),
                      onPressed: () {
                        AudioService.playSelect();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),

              // Scrollable Body
              const Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Section 1: Objective
                      RuleSectionCard(
                        icon: '🐤',
                        title: 'OBJECTIVE: COLLECT CODE PATCHES',
                        color: AppColors.shorebirdGold,
                        description:
                            'Sprint down the production runway dodging bugs, merge barricades, and null pointers. Collect Shorebird Patches to earn points and level up your plan tier!',
                        bulletPoints: [
                          '+100 PTS per Shorebird Patch collected.',
                          '-15 PTS penalty if a patch passes you uncollected.',
                          '+150 PTS bonus for jumping or sliding clear of obstacles.',
                        ],
                      ),

                      SizedBox(height: 16),

                      // Section 2: Controls
                      RuleSectionCard(
                        icon: '🕹️',
                        title: 'CONTROLS: STEER, JUMP & SLIDE',
                        color: AppColors.cyan,
                        description:
                            'Control your developer smoothly across 3 lanes using whatever input you prefer:',
                        bulletPoints: [
                          'A / D or Left / Right: Change lanes.',
                          'Click / Tap on Lane: Directly move to that lane.',
                          'W / Up / Space or Swipe Up: Jump over low obstacles.',
                          'S / Down or Swipe Down: Slide under laser review gates.',
                        ],
                      ),

                      SizedBox(height: 16),

                      // Section 3: Hot Reload Powerup
                      RuleSectionCard(
                        icon: '🔥',
                        title: AppStrings.rulesHotReloadTitle,
                        color: AppColors.hotReloadOrange,
                        description: AppStrings.rulesHotReloadDesc,
                        bulletPoints: [
                          'Invincible forcefield surrounds your player for 6 seconds.',
                          '+500 Instant Bonus PTS.',
                          'Smashes directly through obstacles for +300 bonus PTS each!',
                        ],
                      ),

                      SizedBox(height: 16),

                      // Section 4: Shorebird Tiers
                      RuleSectionCard(
                        icon: '🚀',
                        title: AppStrings.rulesTiersTitle,
                        color: AppColors.neonGreen,
                        description: AppStrings.rulesTiersDesc,
                        bulletPoints: [
                          '🐣 HOBBY TIER (5,000 Patches): 1.2x Speed',
                          '⚡ PRO TIER (50K Patches): 1.65x Speed',
                          '💼 BUSINESS TIER (1M Patches): 2.25x Speed',
                          '👑 ENTERPRISE TIER: 2.8x Maximum Velocity',
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Footer Button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ElevatedButton(
                  onPressed: () {
                    AudioService.playSelect();
                    Navigator.of(context).pop();
                    onStart?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.shorebirdGold,
                    foregroundColor: AppColors.buttonDarkText,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                  ),
                  child: const Text(
                    'START SPRINTING',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
