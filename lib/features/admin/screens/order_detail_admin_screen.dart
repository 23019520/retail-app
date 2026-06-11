import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/order_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loading.dart';
import '../../orders/providers/orders_provider.dart';
import '../../orders/widgets/order_status_badge.dart';
import '../providers/admin_orders_provider.dart';
import '../widgets/status_dropdown.dart';

class OrderDetailAdminScreen extends ConsumerWidget {
  const OrderDetailAdminScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderByIdProvider(orderId));

    return orderAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (_, __) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: 'Could not load order.',
          onRetry: () => ref.invalidate(orderByIdProvider(orderId)),
        ),
      ),
      data: (order) {
        if (order == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const AppErrorWidget(message: 'Order not found.'),
          );
        }
        return _AdminOrderDetail(order: order);
      },
    );
  }
}

class _AdminOrderDetail extends ConsumerWidget {
  const _AdminOrderDetail({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Formatters.orderId(order.id),
          style: const TextStyle(
              fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          // Quick status update from app bar
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: StatusDropdown(
              currentStatus: order.status,
              onChanged: (newStatus) async {
                final success = await ref
                    .read(orderStatusNotifierProvider)
                    .updateStatus(order.id, newStatus);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Status updated to ${newStatus.label}'
                          : 'Failed to update status'),
                      backgroundColor:
                          success ? colors.primary : colors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status + timing ──────────────────────────────────────
            _Card(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Current Status'),
                        const SizedBox(height: 6),
                        OrderStatusBadge(
                            status: order.status, large: true),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const _Label('Placed'),
                      const SizedBox(height: 6),
                      Text(
                        order.createdAt != null
                            ? Formatters.dateTime(order.createdAt!)
                            : '—',
                        style: text.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Customer info ────────────────────────────────────────
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CardTitle('Customer'),
                  const SizedBox(height: 12),
                  _InfoRow(
                      icon: Icons.person_outline_rounded,
                      label: 'User ID: ${order.userId}'),
                  if (order.deliveryAddress != null) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: order.deliveryAddress!,
                    ),
                  ],
                  if (order.notes != null &&
                      order.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.notes_rounded,
                      label: order.notes!,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Order items ──────────────────────────────────────────
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardTitle(
                      '${order.itemCount} Item${order.itemCount == 1 ? '' : 's'}'),
                  const SizedBox(height: 12),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: colors.primaryContainer
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '×${item.quantity}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.productName,
                                style: text.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              Formatters.currency(item.subtotal),
                              style: text.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Totals ───────────────────────────────────────────────
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CardTitle('Payment'),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.credit_card_outlined,
                    label: order.paymentMethod.label,
                  ),
                  const SizedBox(height: 12),
                  Divider(
                      color: colors.outline.withValues(alpha: 0.15)),
                  const SizedBox(height: 10),
                  _TotalRow(
                      label: 'Subtotal',
                      value: Formatters.currency(order.subtotal),
                      colors: colors),
                  const SizedBox(height: 6),
                  _TotalRow(
                    label: 'Delivery',
                    value: order.deliveryFee == 0
                        ? 'Free'
                        : Formatters.currency(order.deliveryFee),
                    colors: colors,
                  ),
                  const SizedBox(height: 10),
                  Divider(
                      color: colors.outline.withValues(alpha: 0.15)),
                  const SizedBox(height: 10),
                  _TotalRow(
                    label: 'Total',
                    value: Formatters.currency(order.total),
                    colors: colors,
                    bold: true,
                    valueColor: colors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Status history actions ────────────────────────────────
            if (order.status != OrderStatus.completed &&
                order.status != OrderStatus.cancelled)
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _CardTitle('Update Status'),
                    const SizedBox(height: 12),
                    _StatusActionButton(
                      order: order,
                      label: _nextStatusLabel(order.status),
                      nextStatus: _nextStatus(order.status),
                      colors: colors,
                    ),
                    const SizedBox(height: 10),
                    if (order.status != OrderStatus.cancelled)
                      _StatusActionButton(
                        order: order,
                        label: 'Cancel Order',
                        nextStatus: OrderStatus.cancelled,
                        colors: colors,
                        isDestructive: true,
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _nextStatusLabel(OrderStatus current) {
    switch (current) {
      case OrderStatus.pending:   return 'Confirm Order';
      case OrderStatus.confirmed: return 'Mark as Preparing';
      case OrderStatus.preparing: return 'Mark as Ready';
      case OrderStatus.ready:     return 'Mark as Completed';
      default:                    return 'Update';
    }
  }

  OrderStatus _nextStatus(OrderStatus current) {
    switch (current) {
      case OrderStatus.pending:   return OrderStatus.confirmed;
      case OrderStatus.confirmed: return OrderStatus.preparing;
      case OrderStatus.preparing: return OrderStatus.ready;
      case OrderStatus.ready:     return OrderStatus.completed;
      default:                    return OrderStatus.confirmed;
    }
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _StatusActionButton extends ConsumerWidget {
  const _StatusActionButton({
    required this.order,
    required this.label,
    required this.nextStatus,
    required this.colors,
    this.isDestructive = false,
  });

  final OrderModel order;
  final String label;
  final OrderStatus nextStatus;
  final ColorScheme colors;
  final bool isDestructive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: isDestructive
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.error,
                side: BorderSide(color: colors.error),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cancel order?'),
                    content: const Text(
                        'This action cannot be undone.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Keep order')),
                      FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: colors.error),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Cancel order'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await ref
                      .read(orderStatusNotifierProvider)
                      .updateStatus(order.id, nextStatus);
                }
              },
              child: Text(label),
            )
          : FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final success = await ref
                    .read(orderStatusNotifierProvider)
                    .updateStatus(order.id, nextStatus);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Order ${nextStatus.label}'
                          : 'Update failed'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor:
                          success ? colors.primary : colors.error,
                    ),
                  );
                }
              },
              child: Text(label),
            ),
    );
  }
}

// ── Small reusable sub-widgets ────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.5),
          ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18,
            color: colors.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.8),
                  )),
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    required this.colors,
    this.bold = false,
    this.valueColor,
  });
  final String label;
  final String value;
  final ColorScheme colors;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: bold
                      ? null
                      : colors.onSurface.withValues(alpha: 0.6),
                  fontWeight:
                      bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: bold ? 16 : null,
                )),
        Text(value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight:
                      bold ? FontWeight.bold : FontWeight.w600,
                  color: valueColor,
                  fontSize: bold ? 18 : null,
                )),
      ],
    );
  }
}
