/// ConditionBadge — compact chip showing grade with colour coding.
/// Never used as a button or action trigger.
library condition_badge;

import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

class ConditionBadge extends StatelessWidget {
  const ConditionBadge({
    super.key,
    required this.grade,
    this.large = false,
  });

  final ConditionGrade grade;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final color = grade.color;
    final label = grade.label;
    final fontSize = large ? 13.0 : 11.0;
    final vPad = large ? 6.0 : 4.0;
    final hPad = large ? 12.0 : 8.0;

    return Semantics(
      label: 'Condition: $label',
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: large ? 6 : 4),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Battery health badge — amber coloured with bolt icon.
class BatteryBadge extends StatelessWidget {
  const BatteryBadge({super.key, required this.health});

  /// 0.0–1.0
  final double health;

  @override
  Widget build(BuildContext context) {
    final pct = (health * 100).round();
    final color = _colorForHealth(health);

    return Semantics(
      label: 'Battery health: $pct%',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, size: 12, color: color),
            const SizedBox(width: 3),
            Text(
              '$pct%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForHealth(double h) {
    if (h >= 0.85) return AppColors.gradeNew;
    if (h >= 0.70) return AppColors.gradeGood;
    if (h >= 0.50) return AppColors.secondary;
    return AppColors.gradeFair;
  }
}

/// Verified seal badge — shown on product cards and checkout.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return const Icon(
        Icons.verified_rounded,
        size: 16,
        color: AppColors.primary,
        semanticLabel: 'Quality checked',
      );
    }

    return Semantics(
      label: 'Quality checked',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 0.5),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded, size: 12, color: AppColors.primary),
            SizedBox(width: 4),
            Text(
              'Quality Checked',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
