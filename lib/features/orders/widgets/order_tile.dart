import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/models/order_model.dart';
import '../../../core/utils/formatters.dart';
import 'order_status_badge.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => context.push(
        RouteConstants.orderDetail.replaceFirst(':orderId', order.id),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: order ID + status ──────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatters.orderId(order.id),
                  style: text.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                OrderStatusBadge(status: order.status),
              ],
            ),

            const SizedBox(height: 10),
            Divider(color: colors.outline.withValues(alpha: 0.1), height: 1),
            const SizedBox(height: 10),

            // ── Item summary ────────────────────────────────────────
            Text(
              _itemSummary(order),
              style: text.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // ── Bottom row: date + total + arrow ────────────────────
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: colors.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 4),
                Text(
                  order.createdAt != null
                      ? Formatters.date(order.createdAt!)
                      : '—',
                  style: text.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const Spacer(),
                Text(
                  Formatters.currency(order.total),
                  style: text.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurface.withValues(alpha: 0.35),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _itemSummary(OrderModel order) {
    if (order.items.isEmpty) return 'No items';
    final names = order.items.map((i) => i.productName).take(3).join(', ');
    final extra = order.items.length > 3
        ? ' +${order.items.length - 3} more'
        : '';
    return '$names$extra';
  }
}
