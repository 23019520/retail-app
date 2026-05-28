import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_summary.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);
    final checkoutState = ref.watch(checkoutProvider);

    return Scaffold(
      body: SafeArea(
        child: cartAsync.when(
          loading: () => const AppLoading(),
          error: (_, __) => const Center(child: Text('Could not load cart.')),
          data: (cart) {
            if (cart.isEmpty) {
              return AppEmptyState(
                icon: Icons.shopping_cart_outlined,
                title: 'Your cart is empty',
                subtitle: 'Add some products and they will appear here.',
                action: () => context.go(RouteConstants.productList),
                actionLabel: 'Browse products',
              );
            }

            return Column(
              children: [
                // ── Header ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        'Cart',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final confirmed = await showConfirmationDialog(
                            context,
                            title: 'Clear cart?',
                            message:
                                'All items will be removed from your cart.',
                            confirmLabel: 'Clear',
                            isDestructive: true,
                          );
                          if (confirmed) {
                            await ref
                                .read(cartNotifierProvider.notifier)
                                .clearCart();
                          }
                        },
                        child: Text(
                          'Clear all',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Items list ───────────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        CartItemTile(item: cart.items[index]),
                  ),
                ),

                // ── Summary + checkout ────────────────────────────────
                Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    MediaQuery.viewPaddingOf(context).bottom + 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CartSummary(
                        subtotal: cart.subtotal,
                        deliveryFee: checkoutState.deliveryFee,
                        isPickup: checkoutState.deliveryMethod.name == 'pickup',
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Proceed to Checkout',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => context.push(RouteConstants.checkout),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
