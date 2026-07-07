import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/order_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/order_status_badge.dart';
import '../../../theme/app_theme.dart';
import '../providers/orders_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Uses StreamProvider so the screen updates live as admin changes status
    final orderAsync = ref.watch(orderByIdProvider(orderId));

    return orderAsync.when(
      loading: () => const Scaffold(
        body: AppLoading(),
      ),
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
        return _OrderDetailContent(order: order);
      },
    );
  }
}

class _OrderDetailContent extends StatelessWidget {
  const _OrderDetailContent({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Formatters.orderId(order.id),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Live status banner ─────────────────────────────────────
            _StatusBanner(order: order),

            const SizedBox(height: AppSpacing.base),

            // ── Tracking timeline ──────────────────────────────────────
            if (order.status != OrderStatus.cancelled)
              _TrackingTimeline(order: order),

            if (order.status == OrderStatus.cancelled)
              _CancelledBanner(),

            const SizedBox(height: AppSpacing.base),

            // ── Items ──────────────────────────────────────────────────
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('Items'),
                  const SizedBox(height: AppSpacing.md),
                  ...order.items.map((item) => _OrderItemRow(item: item)),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Delivery info ──────────────────────────────────────────
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('Delivery'),
                  const SizedBox(height: AppSpacing.md),
                  _InfoRow(
                    icon: order.deliveryMethod == DeliveryMethod.delivery
                        ? Icons.local_shipping_outlined
                        : Icons.store_outlined,
                    label: order.deliveryMethod.label,
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
                    _InfoRow(
                      icon: Icons.notes_rounded,
                      label: order.notes!,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Payment & totals ───────────────────────────────────────
            _SectionCard(
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
                  _TotalRow(label: 'Subtotal', value: Formatters.currency(order.subtotal)),
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

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

// ── Status banner ─────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final statusColor = orderStatusColor(order.status.name);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: statusColor.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              OrderStatusBadge(
                statusLabel: order.status.label,
                statusColor: statusColor,
                large: true,
              ),
              const Spacer(),
              if (order.updatedAt != null)
                Text(
                  'Updated ${Formatters.date(order.updatedAt!)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            order.status.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tracking timeline ─────────────────────────────────────────────────────────

class _TrackingTimeline extends StatelessWidget {
  const _TrackingTimeline({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    const steps = OrderStatus.pipeline;
    final currentIndex = steps.indexOf(order.status);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Order Progress'),
          const SizedBox(height: AppSpacing.base),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCompleted = index <= currentIndex;
            final isCurrent = index == currentIndex;
            final isLast = index == steps.length - 1;
            final timestamp = order.timestampFor(step);

            return _TimelineStep(
              step: step,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLast: isLast,
              timestamp: timestamp,
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.step,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
    required this.timestamp,
  });

  final OrderStatus step;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;
  final DateTime? timestamp;

  IconData get _icon {
    switch (step) {
      case OrderStatus.pending:   return Icons.receipt_outlined;
      case OrderStatus.confirmed: return Icons.check_circle_outline_rounded;
      case OrderStatus.preparing: return Icons.inventory_2_outlined;
      case OrderStatus.ready:     return Icons.done_all_rounded;
      case OrderStatus.completed: return Icons.celebration_outlined;
      default:                    return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = isCompleted ? AppColors.primary : AppColors.divider;
    final labelColor = isCurrent
        ? AppColors.textPrimary
        : isCompleted
            ? AppColors.textSecondary
            : AppColors.textMuted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Dot + line column ──────────────────────────────────────
          SizedBox(
            width: 28,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: AppMotion.standard,
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : AppColors.backgroundCard,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: dotColor,
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    _icon,
                    size: 14,
                    color: isCompleted ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : AppColors.divider,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // ── Label + timestamp ──────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 4,
                bottom: isLast ? 0 : AppSpacing.base,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: labelColor,
                    ),
                  ),
                  if (timestamp != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      Formatters.dateTime(timestamp!),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ] else if (isCurrent) ...[
                    const SizedBox(height: 2),
                    Text(
                      'In progress',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cancelled banner ──────────────────────────────────────────────────────────

class _CancelledBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
            color: AppColors.error.withValues(alpha: 0.2), width: 0.5),
      ),
      child: const Row(
        children: [
          Icon(Icons.cancel_outlined, size: 18, color: AppColors.error),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'This order was cancelled. If you have questions, please contact support.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
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

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});
  final OrderItem item;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.chip),
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