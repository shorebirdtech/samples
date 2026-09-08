import 'package:flutter/material.dart';
import 'package:shorebird_runner/features/start_menu/widgets/plan_chip.dart';

class StagesRoadmap extends StatelessWidget {
  const StagesRoadmap({super.key});

  @override
  Widget build(BuildContext context) {
    const plans = [
      ('🐣', 'HOBBY', '5,000', Color(0xFF00BCD4)),
      ('⚡', 'PRO', '50K', Color(0xFF4CAF50)),
      ('💼', 'BUSINESS', '1M', Color(0xFFFFC107)),
      ('👑', 'ENTERPRISE', 'CUSTOM', Color(0xFF9C27B0)),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF12141A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2730)),
      ),
      child: Column(
        children: [
          const Text(
            'PATCH QUOTAS — SHOREBIRD PLANS',
            style: TextStyle(
              color: Color(0xFF546E7A),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: plans.map((p) {
              final isLast = p == plans.last;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PlanChip(emoji: p.$1, name: p.$2, quota: p.$3, color: p.$4),
                  if (!isLast)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 8,
                        color: Color(0xFF37474F),
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
