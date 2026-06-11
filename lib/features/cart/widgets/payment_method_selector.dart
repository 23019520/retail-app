import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/order_model.dart';
import '../providers/checkout_provider.dart';

class PaymentMethodSelector extends ConsumerWidget {
  const PaymentMethodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(checkoutProvider).paymentMethod;
    final notifier = ref.read(checkoutProvider.notifier);
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method',
            style:
                text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...PaymentMethod.values.map((method) => _PaymentOption(
              method: method,
              isSelected: selected == method,
              onTap: () => notifier.setPaymentMethod(method),
            )),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  IconData get _icon {
    switch (method) {
      case PaymentMethod.yoco: return Icons.contactless_rounded;
      case PaymentMethod.cash: return Icons.payments_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primaryContainer.withValues(alpha: 0.5)
              : colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary
                    : colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _icon,
                color: isSelected
                    ? colors.onPrimary
                    : colors.onSurfaceVariant,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              method.label,
              style:
                  Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: colors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
