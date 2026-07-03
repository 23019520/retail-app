import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../widgets/address_form.dart';
import '../widgets/cart_summary.dart';
import '../widgets/payment_method_selector.dart';
import 'yoco_payment_screen.dart';

final _paymentServiceProvider =
    Provider<PaymentService>((ref) => PaymentService());

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _processingPayment = false;

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutProvider);
    final cart = ref.watch(cartProvider).value;

    ref.listen(checkoutProvider, (prev, next) {
      if (next.hasError && next.errorMessage != prev?.errorMessage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ));
        });
      }
    });

    if (_processingPayment) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundBase,
        body: AppLoading(message: 'Processing payment...'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: AppColors.textSecondary,
          onPressed: context.pop,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Delivery method ─────────────────────────────────────────
            const _Label('Delivery Method'),
            const SizedBox(height: AppSpacing.md),
            _DeliveryMethodToggle(
              selected: checkoutState.deliveryMethod,
              onChanged: ref.read(checkoutProvider.notifier).setDeliveryMethod,
            ),

            if (checkoutState.deliveryMethod == DeliveryMethod.delivery) ...[
              const SizedBox(height: AppSpacing.lg),
              const AddressForm(),
            ],

            const SizedBox(height: AppSpacing.lg),

            // ── Payment method ───────────────────────────────────────────
            const PaymentMethodSelector(),

            const SizedBox(height: AppSpacing.lg),

            // ── Notes ────────────────────────────────────────────────────
            const _Label('Order Notes (optional)'),
            const SizedBox(height: AppSpacing.md),
            TextField(
              onChanged: ref.read(checkoutProvider.notifier).setNotes,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Any special instructions...',
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Trust reminder ───────────────────────────────────────────
            _TrustReminder(),

            const SizedBox(height: AppSpacing.lg),

            // ── Summary ──────────────────────────────────────────────────
            if (cart != null)
              CartSummary(
                subtotal: cart.subtotal,
                deliveryFee: checkoutState.deliveryFee,
                isPickup: checkoutState.deliveryMethod == DeliveryMethod.pickup,
              ),

            const SizedBox(height: AppSpacing.lg),

            // ── Place order ──────────────────────────────────────────────
            AppButton(
              label: checkoutState.paymentMethod == PaymentMethod.yoco
                  ? 'Pay with Yoco'
                  : 'Place Order',
              icon: checkoutState.paymentMethod == PaymentMethod.yoco
                  ? Icons.lock_outline_rounded
                  : Icons.check_rounded,
              isLoading: checkoutState.isLoading,
              isDisabled: cart == null || cart.isEmpty,
              onPressed: () => _handlePlaceOrder(context, ref),
            ),

            SizedBox(height: MediaQuery.viewPaddingOf(context).bottom + AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePlaceOrder(BuildContext context, WidgetRef ref) async {
    final isValid = ref.read(checkoutProvider.notifier).validate();
    if (!isValid) return;

    final checkoutState = ref.read(checkoutProvider);
    final cart = ref.read(cartProvider).value;
    if (cart == null || cart.isEmpty) return;

    if (checkoutState.paymentMethod == PaymentMethod.yoco) {
      final userModel = await ref.read(currentUserProvider.future);
      final totalAmount = cart.subtotal + checkoutState.deliveryFee;
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final projectId = dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

      if (projectId.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Missing FIREBASE_PROJECT_ID. Payment cannot proceed.'),
            backgroundColor: AppColors.error,
          ));
        }
        return;
      }

      setState(() => _processingPayment = true);

      final result = await ref.read(_paymentServiceProvider).createYocoCheckout(
            orderId: tempId,
            amount: totalAmount,
            customerEmail: userModel?.email ?? '',
          );

      setState(() => _processingPayment = false);

      if (!result.success || result.checkoutUrl == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result.errorMessage ?? 'Could not start payment.'),
            backgroundColor: AppColors.error,
          ));
        }
        return;
      }

      if (!context.mounted) return;
      final paid = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => YocoPaymentScreen(
            checkoutUrl: result.checkoutUrl!,
            successUrl: 'https://$projectId.web.app/payment-success.html',
            cancelUrl: 'https://$projectId.web.app/payment-cancel.html',
          ),
        ),
      );

      if (paid != true) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Payment was not completed.'),
          ));
        }
        return;
      }
    }

    if (!context.mounted) return;
    String? orderId;
    try {
      orderId = await ref.read(checkoutProvider.notifier).createOrder();
      if (orderId == null) throw Exception('Order creation returned null');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not create order: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ));
      }
      return;
    }

    if (context.mounted) {
      context.go('${RouteConstants.orderSuccess}?orderId=$orderId');
    }
  }
}

// ── Delivery toggle ───────────────────────────────────────────────────────────

class _DeliveryMethodToggle extends StatelessWidget {
  const _DeliveryMethodToggle({
    required this.selected,
    required this.onChanged,
  });

  final DeliveryMethod selected;
  final ValueChanged<DeliveryMethod> onChanged;

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
              duration: AppMotion.micro,
              margin: EdgeInsets.only(right: isFirst ? AppSpacing.sm : 0),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    method == DeliveryMethod.delivery
                        ? Icons.local_shipping_outlined
                        : Icons.store_outlined,
                    size: 22,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    method.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
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

// ── Trust reminder ────────────────────────────────────────────────────────────

class _TrustReminder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'All devices are quality-checked. 7-day returns. Secure checkout.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Label ─────────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}
