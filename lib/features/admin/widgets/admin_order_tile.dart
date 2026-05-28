import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/models/order_model.dart';
import '../../../core/utils/formatters.dart';
import '../../orders/widgets/order_status_badge.dart';

class AdminOrderTile extends StatelessWidget {
  const AdminOrderTile({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => context.push(
        RouteConstants.adminOrderDetail
            .replaceFirst(':orderId', order.id),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: order info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        Formatters.orderId(order.id),
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}  ·  ${order.deliveryMethod.label}',
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    order.createdAt != null
                        ? Formatters.dateTime(order.createdAt!)
                        : '—',
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Right: total + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.currency(order.total),
                  style: text.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: colors.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
