import 'package:flutter/material.dart';

import '../../../core/models/order_model.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status, this.large = false});

  final OrderStatus status;
  final bool large;

  Color _bgColor(ColorScheme colors) {
    switch (status) {
      case OrderStatus.pending:   return const Color(0xFFFFF8E1);
      case OrderStatus.confirmed: return const Color(0xFFE3F2FD);
      case OrderStatus.preparing: return const Color(0xFFF3E5F5);
      case OrderStatus.ready:     return const Color(0xFFE0F7FA);
      case OrderStatus.completed: return const Color(0xFFE8F5E9);
      case OrderStatus.cancelled: return const Color(0xFFFFEBEE);
    }
  }

  Color _textColor(ColorScheme colors) {
    switch (status) {
      case OrderStatus.pending:   return const Color(0xFFF57F17);
      case OrderStatus.confirmed: return const Color(0xFF0288D1);
      case OrderStatus.preparing: return const Color(0xFF7B1FA2);
      case OrderStatus.ready:     return const Color(0xFF00838F);
      case OrderStatus.completed: return const Color(0xFF2E7D32);
      case OrderStatus.cancelled: return const Color(0xFFB00020);
    }
  }

  IconData get _icon {
    switch (status) {
      case OrderStatus.pending:   return Icons.schedule_rounded;
      case OrderStatus.confirmed: return Icons.check_circle_outline_rounded;
      case OrderStatus.preparing: return Icons.restaurant_outlined;
      case OrderStatus.ready:     return Icons.inventory_2_outlined;
      case OrderStatus.completed: return Icons.done_all_rounded;
      case OrderStatus.cancelled: return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bg = _bgColor(colors);
    final fg = _textColor(colors);
    final fontSize = large ? 13.0 : 11.0;
    final iconSize = large ? 16.0 : 13.0;
    final padding = large
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 5);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(large ? 12 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: fg, size: iconSize),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
