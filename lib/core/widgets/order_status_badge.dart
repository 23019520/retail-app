/// OrderStatusBadge — coloured status pill for orders.
library order_status_badge;

import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

// Minimal re-export of OrderStatus — in the real app this comes from order_model.dart
// This file is a drop-in replacement that only changes styling.

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({
    super.key,
    required this.statusLabel,
    required this.statusColor,
    this.large = false,
  });

  final String statusLabel;
  final Color statusColor;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final fontSize = large ? 13.0 : 11.0;
    final vPad = large ? 7.0 : 4.0;
    final hPad = large ? 12.0 : 8.0;

    return Semantics(
      label: 'Order status: $statusLabel',
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
            ),
            SizedBox(width: large ? 6 : 4),
            Text(
              statusLabel,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper to get color for a given status string.
Color orderStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending':    return AppColors.secondary;
    case 'confirmed':  return AppColors.primary;
    case 'preparing':  return AppColors.gradeGood;
    case 'ready':      return AppColors.gradeNew;
    case 'completed':  return AppColors.gradeExcellent;
    case 'cancelled':  return AppColors.error;
    default:           return AppColors.textMuted;
  }
}
