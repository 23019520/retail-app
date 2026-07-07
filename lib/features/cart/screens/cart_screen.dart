import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/app_stagger.dart';
import '../../../theme/app_theme.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_summary.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync     = ref.watch(cartProvider);
    final checkoutState = ref.watch(checkoutProvider);

    return Scaffold(
      
      body: SafeArea(
        child: cartAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
              strokeWidth: 2,
            ),
          ),
          error: (_, __) => const Center(
            child: Text(
              'Could not load cart.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          data: (cart) {
            if (cart.isEmpty) {
              return AppEmptyState(
                icon: Icons.shopping_cart_outlined,
                title: 'Your cart is empty',
                subtitle: 'Browse our quality second-hand laptops and add something you like.',
                action: () => context.go(RouteConstants.productList),
                actionLabel: 'Browse products',
              );
            }

            return AppStagger(
              child: Column(
                children: [
                  // ── Header ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base,
                      AppSpacing.base,
                      AppSpacing.base,
                      AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Cart',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.circle),
                          ),
                          child: Text(
                            '${cart.itemCount}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            final confirmed = await showConfirmationDialog(
                              context,
                              title: 'Clear cart?',
                              message: 'All items will be removed.',
                              confirmLabel: 'Clear',
                              isDestructive: true,
                            );
                            if (confirmed) {
                              await ref
                                  .read(cartNotifierProvider.notifier)
                                  .clearCart();
                            }
                          },
                          child: const Text(
                            'Clear all',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Items ─────────────────────────────────────────────
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base,
                      ),
                      itemCount: cart.items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) => AppStaggerItem(
                        index: index,
                        child: CartItemTile(item: cart.items[index]),
                      ),
                    ),
                  ),

                  // ── Summary + checkout ────────────────────────────────
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.base,
                      AppSpacing.base,
                      AppSpacing.base,
                      MediaQuery.viewPaddingOf(context).bottom + AppSpacing.base,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundCard,
                      border: Border(
                        top: BorderSide(color: AppColors.divider, width: 0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        CartSummary(
                          subtotal: cart.subtotal,
                          deliveryFee: checkoutState.deliveryFee,
                          isPickup: checkoutState.deliveryMethod.name == 'pickup',
                        ),
                        const SizedBox(height: AppSpacing.base),
                        AppButton(
                          label: 'Proceed to Checkout',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () =>
                              context.push(RouteConstants.checkout),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
