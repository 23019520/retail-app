import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/order_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loading.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_status_badge.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

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
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Formatters.orderId(order.id),
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status card ─────────────────────────────────────────
            _SectionCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status',
                            style: text.bodySmall?.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.5),
                            )),
                        const SizedBox(height: 6),
                        OrderStatusBadge(status: order.status, large: true),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Date',
                          style: text.bodySmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.5),
                          )),
                      const SizedBox(height: 6),
                      Text(
                        order.createdAt != null
                            ? Formatters.date(order.createdAt!)
                            : '—',
                        style: text.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Order items ─────────────────────────────────────────
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Items',
                      style: text.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  ...order.items.map((item) => _OrderItemRow(item: item)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Delivery info ───────────────────────────────────────
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delivery',
                      style: text.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: order.deliveryMethod == DeliveryMethod.delivery
                        ? Icons.local_shipping_outlined
                        : Icons.store_outlined,
                    label: order.deliveryMethod.label,
                  ),
                  if (order.deliveryAddress != null) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: order.deliveryAddress!,
                    ),
                  ],
                  if (order.notes != null && order.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.notes_rounded,
                      label: order.notes!,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Payment + totals ────────────────────────────────────
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment',
                      style: text.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.credit_card_outlined,
                    label: order.paymentMethod.label,
                  ),
                  const SizedBox(height: 16),
                  Divider(color: colors.outline.withValues(alpha: 0.15)),
                  const SizedBox(height: 12),
                  _TotalRow(
                    label: 'Subtotal',
                    value: Formatters.currency(order.subtotal),
                    colors: colors,
                  ),
                  const SizedBox(height: 6),
                  _TotalRow(
                    label: 'Delivery',
                    value: order.deliveryFee == 0
                        ? 'Free'
                        : Formatters.currency(order.deliveryFee),
                    colors: colors,
                  ),
                  const SizedBox(height: 12),
                  Divider(color: colors.outline.withValues(alpha: 0.15)),
                  const SizedBox(height: 12),
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

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
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

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Qty badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.5),
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
          // Name
          Expanded(
            child: Text(
              item.productName,
              style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          // Subtotal
          Text(
            Formatters.currency(item.subtotal),
            style: text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
        ],
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
        Icon(icon, size: 18, color: colors.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.8),
                ),
          ),
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
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: bold ? null : colors.onSurface.withValues(alpha: 0.6),
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: bold ? 16 : null,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                color: valueColor,
                fontSize: bold ? 18 : null,
              ),
        ),
      ],
    );
  }
}
