import 'package:flutter/material.dart';
import 'package:shorebird_runner/core/constants/constants.dart';
import 'package:shorebird_runner/features/start_menu/widgets/plan_chip.dart';

class StagesRoadmap extends StatelessWidget {
  const StagesRoadmap({super.key});

  @override
  Widget build(BuildContext context) {
    const plans = [
      (Icons.egg_outlined, 'HOBBY', '5,000', AppColors.proCyan),
      (Icons.bolt_rounded, 'PRO', '50K', AppColors.businessGreen),
      (Icons.work_outline_rounded, 'BUSINESS', '1M', AppColors.shorebirdGold),
      (
        Icons.military_tech_outlined,
        'ENTERPRISE',
        'CUSTOM',
        AppColors.enterprisePurple
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.shorebirdGold,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'TIER MILESTONES — CODE PUSH QUOTAS',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.shorebirdGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: plans.map((p) {
              final isLast = p == plans.last;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PlanChip(icon: p.$1, name: p.$2, quota: p.$3, color: p.$4),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 11,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
