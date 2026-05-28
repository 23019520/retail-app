import 'package:flutter/material.dart';

import '../../../core/models/order_model.dart';

class StatusDropdown extends StatelessWidget {
  const StatusDropdown({
    super.key,
    required this.currentStatus,
    required this.onChanged,
  });

  final OrderStatus currentStatus;
  final ValueChanged<OrderStatus> onChanged;

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:   return const Color(0xFFF57F17);
      case OrderStatus.confirmed: return const Color(0xFF0288D1);
      case OrderStatus.preparing: return const Color(0xFF7B1FA2);
      case OrderStatus.ready:     return const Color(0xFF00838F);
      case OrderStatus.completed: return const Color(0xFF2E7D32);
      case OrderStatus.cancelled: return const Color(0xFFB00020);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = _statusColor(currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<OrderStatus>(
          value: currentStatus,
          isDense: true,
          icon: Icon(Icons.expand_more_rounded, color: accent, size: 18),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: accent,
          ),
          dropdownColor: colors.surface,
          borderRadius: BorderRadius.circular(12),
          items: OrderStatus.values
              .where((s) => s != OrderStatus.cancelled ||
                  currentStatus == OrderStatus.cancelled)
              .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(
                      status.label,
                      style: TextStyle(
                        color: _statusColor(status),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (s) {
            if (s != null) onChanged(s);
          },
        ),
      ),
    );
  }
}
