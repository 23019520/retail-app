import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../widgets/address_form.dart';
import '../widgets/cart_summary.dart';
import '../widgets/payment_method_selector.dart';

final _paymentServiceProvider =
    Provider<PaymentService>((ref) => PaymentService());

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkoutState = ref.watch(checkoutProvider);
    final cart = ref.watch(cartProvider).value;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    ref.listen(checkoutProvider, (previous, next) {
      if (next.hasError && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage!),
          backgroundColor: colors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Delivery method ────────────────────────────────────
            Text('Delivery Method',
                style: text.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _DeliveryMethodToggle(
              selected: checkoutState.deliveryMethod,
              onChanged:
                  ref.read(checkoutProvider.notifier).setDeliveryMethod,
              colors: colors,
            ),

            // ── Address (delivery only) ────────────────────────────
            if (checkoutState.deliveryMethod ==
                DeliveryMethod.delivery) ...[
              const SizedBox(height: 28),
              const AddressForm(),
            ],

            const SizedBox(height: 28),

            // ── Payment method ─────────────────────────────────────
            const PaymentMethodSelector(),

            const SizedBox(height: 28),

            // ── Notes ──────────────────────────────────────────────
            Text('Order Notes (optional)',
                style: text.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              onChanged:
                  ref.read(checkoutProvider.notifier).setNotes,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Any special instructions...',
              ),
            ),

            const SizedBox(height: 28),

            // ── Order summary ──────────────────────────────────────
            if (cart != null)
              CartSummary(
                subtotal: cart.subtotal,
                deliveryFee: checkoutState.deliveryFee,
                isPickup: checkoutState.deliveryMethod ==
                    DeliveryMethod.pickup,
              ),

            const SizedBox(height: 24),

            // ── Place order ────────────────────────────────────────
            AppButton(
              label: _buttonLabel(checkoutState.paymentMethod),
              isLoading: checkoutState.isLoading,
              isDisabled: cart == null || cart.isEmpty,
              icon: _buttonIcon(checkoutState.paymentMethod),
              onPressed: () =>
                  _handlePlaceOrder(context, ref, checkoutState),
            ),

            SizedBox(
                height:
                    MediaQuery.viewPaddingOf(context).bottom + 24),
          ],
        ),
      ),
    );
  }

  String _buttonLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.payfast:
        return 'Pay with PayFast';
      case PaymentMethod.yoco:
        return 'Pay with Yoco';
      case PaymentMethod.cash:
        return 'Place Order';
    }
  }

  IconData _buttonIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.payfast:
      case PaymentMethod.yoco:
        return Icons.lock_outline_rounded;
      case PaymentMethod.cash:
        return Icons.check_rounded;
    }
  }

  Future<void> _handlePlaceOrder(
    BuildContext context,
    WidgetRef ref,
    CheckoutState checkoutState,
  ) async {
    // Step 1: Create the order in Firestore
    final orderId =
        await ref.read(checkoutProvider.notifier).submitOrder();
    if (orderId == null || !context.mounted) return;

    // Step 2: Handle payment gateway
    final paymentMethod = checkoutState.paymentMethod;
    final cart = ref.read(cartProvider).value;
    final user = ref.read(currentFirebaseUserProvider);
    final userModel = await ref.read(currentUserProvider.future);

    if (paymentMethod != PaymentMethod.cash && cart != null) {
      final paymentService = ref.read(_paymentServiceProvider);

      PaymentResult result;
      if (paymentMethod == PaymentMethod.payfast) {
        result = await paymentService.initiatePayFast(
          orderId: orderId,
          amount: cart.subtotal + checkoutState.deliveryFee,
          customerName: userModel?.name ?? 'Customer',
          customerEmail:
              userModel?.email ?? user?.email ?? '',
          itemName:
              '${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'} from My Store',
        );
      } else {
        result = await paymentService.initiateYoco(
          orderId: orderId,
          amount: cart.subtotal + checkoutState.deliveryFee,
        );
      }

      if (!result.success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(result.errorMessage ?? 'Payment failed.'),
          backgroundColor:
              Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ));
        // Order is created but unpaid — admin can see it as 'pending'
        // and handle manually. Navigate to success regardless.
      }
    }

    // Step 3: Navigate to success screen
    if (context.mounted) {
      context.go('${RouteConstants.orderSuccess}?orderId=$orderId');
    }
  }
}

// ── Delivery method toggle ────────────────────────────────────────────────────

class _DeliveryMethodToggle extends StatelessWidget {
  const _DeliveryMethodToggle({
    required this.selected,
    required this.onChanged,
    required this.colors,
  });

  final DeliveryMethod selected;
  final ValueChanged<DeliveryMethod> onChanged;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: DeliveryMethod.values.map((method) {
        final isSelected = selected == method;
        final isFirst = method == DeliveryMethod.delivery;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(method),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: isFirst ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? colors.primary
                      : colors.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    method == DeliveryMethod.delivery
                        ? Icons.local_shipping_outlined
                        : Icons.store_outlined,
                    color: isSelected
                        ? colors.onPrimary
                        : colors.onSurface,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    method.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colors.onPrimary
                          : colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
