import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_loading.dart';
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
  void initState() {
    super.initState();
    // Listen to checkoutProvider once during the widget lifecycle to show error SnackBars.
    ref.listen(checkoutProvider, (previous, next) {
      if (next.hasError && next.errorMessage != previous?.errorMessage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final colors = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutProvider);
    final cart = ref.watch(cartProvider).value;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Checkout provider listener moved to initState to avoid re-registration

    if (_processingPayment) {
      return const Scaffold(
        body: AppLoading(message: 'Processing payment...'),
      );
    }

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
            // ── Delivery method ──────────────────────────────────
            Text('Delivery Method',
                style: text.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _DeliveryMethodToggle(
              selected: checkoutState.deliveryMethod,
              onChanged: ref
                  .read(checkoutProvider.notifier)
                  .setDeliveryMethod,
              colors: colors,
            ),

            // ── Address ──────────────────────────────────────────
            if (checkoutState.deliveryMethod ==
                DeliveryMethod.delivery) ...[
              const SizedBox(height: 28),
              const AddressForm(),
            ],

            const SizedBox(height: 28),

            // ── Payment method ───────────────────────────────────
            const PaymentMethodSelector(),

            const SizedBox(height: 28),

            // ── Notes ────────────────────────────────────────────
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

            // ── Order summary ─────────────────────────────────────
            if (cart != null)
              CartSummary(
                subtotal: cart.subtotal,
                deliveryFee: checkoutState.deliveryFee,
                isPickup: checkoutState.deliveryMethod ==
                    DeliveryMethod.pickup,
              ),

            const SizedBox(height: 24),

            // ── Place order / Pay button ──────────────────────────
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

            SizedBox(
                height:
                    MediaQuery.viewPaddingOf(context).bottom + 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePlaceOrder(
      BuildContext context, WidgetRef ref) async {
    // Step 1 — Validate address form
    final isValid =
        ref.read(checkoutProvider.notifier).validate();
    if (!isValid) return;

    final checkoutState = ref.read(checkoutProvider);
    final cart = ref.read(cartProvider).value;
    if (cart == null || cart.isEmpty) return;

    // ── Yoco payment flow ─────────────────────────────────────────
    if (checkoutState.paymentMethod == PaymentMethod.yoco) {
      final userModel = await ref.read(currentUserProvider.future);
      final totalAmount = cart.subtotal + checkoutState.deliveryFee;
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final projectId = dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

      // Validate required env var
      if (projectId.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text(
                'Missing FIREBASE_PROJECT_ID environment variable. Payment cannot proceed.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ));
        }
        return;
      }

      // Step 2 — Create Yoco checkout session
      setState(() => _processingPayment = true);

      final result = await ref
          .read(_paymentServiceProvider)
          .createYocoCheckout(
            orderId: tempId,
            amount: totalAmount,
            customerEmail: userModel?.email ?? '',
          );

      setState(() => _processingPayment = false);

      if (!result.success || result.checkoutUrl == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                result.errorMessage ?? 'Could not start payment.'),
            backgroundColor:
                Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ));
        }
        return;
      }

      // Step 3 — Open Yoco checkout in WebView
      if (!context.mounted) return;
      final paid = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => YocoPaymentScreen(
            checkoutUrl: result.checkoutUrl!,
            successUrl:
                'https://$projectId.web.app/payment-success.html',
            cancelUrl:
                'https://$projectId.web.app/payment-cancel.html',
          ),
        ),
      );

      // Step 4 — User cancelled or closed WebView
      if (paid != true) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment was not completed.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }

    // ── Step 5 — Payment confirmed (Yoco) or Cash selected ────────
    // Only now do we create the order in Firestore
    if (!context.mounted) return;
    String? orderId;
    try {
      orderId = await ref.read(checkoutProvider.notifier).createOrder();
      if (orderId == null) {
        throw Exception('Order creation returned null');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not create order: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
      // Consider idempotency/reconciliation here: record payment/temp id to retry or reconcile on backend.
      return;
    }

    if (context.mounted && orderId != null) {
      context
          .go('${RouteConstants.orderSuccess}?orderId=$orderId');
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
                color: isSelected
                    ? colors.primary
                    : colors.surface,
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