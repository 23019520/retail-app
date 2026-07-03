import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/order_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/app_states.dart';
import '../../../theme/app_theme.dart';
import '../../orders/providers/orders_provider.dart';
import '../../orders/widgets/order_status_badge.dart';
import '../providers/admin_orders_provider.dart';
import '../widgets/status_dropdown.dart';

class OrderDetailAdminScreen extends ConsumerWidget {
  const OrderDetailAdminScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Uses orderByIdProvider from orders_provider — same as the original screen.
    final orderAsync = ref.watch(orderByIdProvider(orderId));

    return orderAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.backgroundBase,
        body: AppLoading(),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: AppColors.backgroundBase,
        appBar: AppBar(),
        body: AppErrorWidget(
          message: 'Could not load order.',
          onRetry: () => ref.invalidate(orderByIdProvider(orderId)),
        ),
      ),
      data: (order) {
        if (order == null) {
          return Scaffold(
            backgroundColor: AppColors.backgroundBase,
            appBar: AppBar(),
            body: const AppErrorWidget(message: 'Order not found.'),
          );
        }
        return _AdminOrderDetailContent(order: order);
      },
    );
  }
}

class _AdminOrderDetailContent extends ConsumerWidget {
  const _AdminOrderDetailContent({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        title: Text(
          Formatters.orderId(order.id),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: StatusDropdown(
              currentStatus: order.status,
              onChanged: (newStatus) async {
                final success = await ref
                    .read(orderStatusNotifierProvider)
                    .updateStatus(order.id, newStatus);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(success
                        ? 'Status updated to ${newStatus.label}'
                        : 'Failed to update status'),
                    backgroundColor:
                        success ? AppColors.primary : AppColors.error,
                  ));
                }
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status + date ──────────────────────────────────────────
            _Card(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle('Status'),
                        const SizedBox(height: AppSpacing.xs),
                        OrderStatusBadge(status: order.status, large: true),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const _SectionTitle('Placed'),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        order.createdAt != null
                            ? Formatters.dateTime(order.createdAt!)
                            : '—',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Customer / delivery info ───────────────────────────────
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('Customer'),
                  const SizedBox(height: AppSpacing.md),
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: 'User ID: ${order.userId}',
                  ),
                  if (order.deliveryAddress != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: order.deliveryAddress!,
                    ),
                  ],
                  if (order.notes != null && order.notes!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(icon: Icons.notes_rounded, label: order.notes!),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Items ──────────────────────────────────────────────────
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                      '${order.itemCount} Item${order.itemCount == 1 ? '' : 's'}'),
                  const SizedBox(height: AppSpacing.md),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.chip),
                              ),
                              child: Center(
                                child: Text(
                                  '×${item.quantity}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                item.productName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              Formatters.currency(item.subtotal),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Payment + totals ───────────────────────────────────────
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('Payment'),
                  const SizedBox(height: AppSpacing.md),
                  _InfoRow(
                    icon: Icons.credit_card_outlined,
                    label: order.paymentMethod.label,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(height: 0.5, color: AppColors.divider),
                  const SizedBox(height: AppSpacing.md),
                  _TotalRow(
                    label: 'Subtotal',
                    value: Formatters.currency(order.subtotal),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _TotalRow(
                    label: 'Delivery',
                    value: order.deliveryFee == 0
                        ? 'Free'
                        : Formatters.currency(order.deliveryFee),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(height: 0.5, color: AppColors.divider),
                  const SizedBox(height: AppSpacing.md),
                  _TotalRow(
                    label: 'Total',
                    value: Formatters.currency(order.total),
                    bold: true,
                    valueColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Status action buttons ──────────────────────────────────
            if (order.status != OrderStatus.completed &&
                order.status != OrderStatus.cancelled)
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Update Status'),
                    const SizedBox(height: AppSpacing.md),
                    _StatusActionButton(
                      order: order,
                      label: _nextStatusLabel(order.status),
                      nextStatus: _nextStatus(order.status),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _StatusActionButton(
                      order: order,
                      label: 'Cancel Order',
                      nextStatus: OrderStatus.cancelled,
                      isDestructive: true,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  String _nextStatusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:   return 'Confirm Order';
      case OrderStatus.confirmed: return 'Mark as Preparing';
      case OrderStatus.preparing: return 'Mark as Ready';
      case OrderStatus.ready:     return 'Mark as Completed';
      default:                    return 'Update';
    }
  }

  OrderStatus _nextStatus(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:   return OrderStatus.confirmed;
      case OrderStatus.confirmed: return OrderStatus.preparing;
      case OrderStatus.preparing: return OrderStatus.ready;
      case OrderStatus.ready:     return OrderStatus.completed;
      default:                    return OrderStatus.confirmed;
    }
  }
}

// ── Status action button ──────────────────────────────────────────────────────

class _StatusActionButton extends ConsumerWidget {
  const _StatusActionButton({
    required this.order,
    required this.label,
    required this.nextStatus,
    this.isDestructive = false,
  });

  final OrderModel order;
  final String label;
  final OrderStatus nextStatus;
  final bool isDestructive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> doUpdate() async {
      final success = await ref
          .read(orderStatusNotifierProvider)
          .updateStatus(order.id, nextStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? 'Order ${nextStatus.label}' : 'Update failed'),
          backgroundColor: success ? AppColors.primary : AppColors.error,
        ));
      }
    }

    if (isDestructive) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button)),
          ),
          onPressed: () async {
            final confirmed = await showConfirmationDialog(
              context,
              title: 'Cancel order?',
              message: 'This cannot be undone.',
              confirmLabel: 'Cancel order',
              isDestructive: true,
            );
            if (confirmed) doUpdate();
          },
          child: Text(label),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: const Color(0xFF0E2419),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button)),
        ),
        onPressed: doUpdate,
        child: Text(label),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: child,
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 0.4,
        ),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      );
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: bold ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 18 : 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ?? AppColors.textSecondary,
            ),
          ),
        ],
      );
}