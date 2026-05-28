import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.isPickup,
  });

  final double subtotal;
  final double deliveryFee;
  final bool isPickup;

  double get total => subtotal + (isPickup ? 0 : deliveryFee);
  bool get qualifiesForFreeDelivery => subtotal >= 500;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _SummaryRow(
            label: 'Subtotal',
            value: Formatters.currency(subtotal),
          ),
          const SizedBox(height: 8),

          _SummaryRow(
            label: isPickup
                ? 'Delivery'
                : (qualifiesForFreeDelivery ? 'Delivery' : 'Delivery'),
            value: isPickup
                ? 'Pickup'
                : (qualifiesForFreeDelivery
                    ? 'Free'
                    : Formatters.currency(deliveryFee)),
            valueColor: isPickup
                ? colors.onSurface.withValues(alpha: 0.5)
                : (qualifiesForFreeDelivery ? Colors.green : null),
          ),

          // Free delivery progress hint
          if (!isPickup && !qualifiesForFreeDelivery) ...[
            const SizedBox(height: 10),
            _FreeDeliveryHint(
              subtotal: subtotal,
              threshold: 500,
              colors: colors,
            ),
          ],

          const SizedBox(height: 16),
          Divider(color: colors.outline.withValues(alpha: 0.15)),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style:
                      text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                Formatters.currency(total),
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                )),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
        ),
      ],
    );
  }
}

class _FreeDeliveryHint extends StatelessWidget {
  const _FreeDeliveryHint({
    required this.subtotal,
    required this.threshold,
    required this.colors,
  });
  final double subtotal;
  final double threshold;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final remaining = threshold - subtotal;
    final progress = (subtotal / threshold).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(colors.primary),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Add ${Formatters.currency(remaining)} more for free delivery',
          style: TextStyle(
            fontSize: 11,
            color: colors.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
