import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/product_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/add_to_cart_pill.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_product_image.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/condition_badge.dart';
import '../../../core/widgets/condition_meter.dart';
import '../../../theme/app_theme.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/products_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productByIdProvider(widget.productId));

    return productAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.backgroundBase,
        body: AppLoading(),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: AppColors.backgroundBase,
        appBar: AppBar(),
        body: const Center(
          child: Text(
            'Could not load product.',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      ),
      data: (product) {
        if (product == null) {
          return Scaffold(
            backgroundColor: AppColors.backgroundBase,
            appBar: AppBar(),
            body: const Center(
              child: Text(
                'Product not found.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          );
        }
        return _ProductDetailContent(
          product: product,
          quantity: _quantity,
          onQuantityChanged: (q) => setState(() => _quantity = q),
        );
      },
    );
  }
}

class _ProductDetailContent extends ConsumerWidget {
  const _ProductDetailContent({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
  });

  final ProductModel product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    // ── Real condition data from the product model — both nullable, since
    // not every product type (e.g. tools) tracks condition or battery.
    final grade = product.condition != null
        ? _toConditionGrade(product.condition!)
        : null;
    final batteryHealth = product.batteryHealth;

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Image with back/wishlist overlay ──────────────────────
              SliverAppBar(
                expandedHeight: screenHeight * 0.40,
                pinned: true,
                backgroundColor: AppColors.backgroundBase,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: _CircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: context.pop,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: _CircleButton(
                      icon: Icons.favorite_border_rounded,
                      onTap: () {},
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: AppProductImageCarousel(
                    imageUrls: product.imageUrls,
                    height: screenHeight * 0.40,
                  ),
                ),
              ),

              // ── Product info ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundBase,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadius.sheet),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base,
                    AppSpacing.lg,
                    AppSpacing.base,
                    120, // space for sticky bottom bar
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Badges row ──────────────────────────────────────
                      if (grade != null || batteryHealth != null || product.isInspected) ...[
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            if (grade != null) ConditionBadge(grade: grade),
                            if (batteryHealth != null)
                              BatteryBadge(health: batteryHealth),
                            if (product.isInspected) const VerifiedBadge(),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // ── Name + price ────────────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.25,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.base),
                          Text(
                            Formatters.currency(product.price),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // ── Condition Meter (signature element) ─────────────
                      // Skipped entirely for product types that don't track
                      // condition/battery (e.g. tools).
                      if (grade != null || batteryHealth != null) ...[
                        _ConditionSection(
                          grade: grade,
                          batteryHealth: batteryHealth,
                          isInspected: product.isInspected,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const _Divider(),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // ── Description ─────────────────────────────────────
                      const Text(
                        'About this item',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        product.description.isNotEmpty
                            ? product.description
                            : 'No description available.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.65,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),
                      const _Divider(),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Trust block ──────────────────────────────────────
                      _TrustBlock(product: product),

                      const SizedBox(height: AppSpacing.lg),
                      const _Divider(),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Quantity selector ────────────────────────────────
                      Row(
                        children: [
                          const Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          _QuantitySelector(
                            quantity: quantity,
                            maxQuantity: product.stock,
                            onChanged: onQuantityChanged,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Sticky bottom bar ─────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomBar(
              product: product,
              quantity: quantity,
            ),
          ),
        ],
      ),
    );
  }

  ConditionGrade _toConditionGrade(ProductCondition c) {
    switch (c) {
      case ProductCondition.likeNew:   return ConditionGrade.likeNew;
      case ProductCondition.excellent: return ConditionGrade.excellent;
      case ProductCondition.good:      return ConditionGrade.good;
      case ProductCondition.fair:      return ConditionGrade.fair;
    }
  }
}

// ── Condition Section ─────────────────────────────────────────────────────────

class _ConditionSection extends StatelessWidget {
  const _ConditionSection({
    required this.grade,
    required this.batteryHealth,
    required this.isInspected,
  });

  // At least one of these is guaranteed non-null by the caller's guard
  // (grade != null || batteryHealth != null), but both stay nullable here
  // since accessories may have a grade with no battery, and vice versa.
  final ConditionGrade? grade;
  final double? batteryHealth;
  final bool isInspected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          // Signature condition meter — falls back to 'excellent' styling
          // only as a defensive default; in practice grade is always set
          // whenever this section renders for a condition-tracked item.
          ConditionMeter(
            grade: grade ?? ConditionGrade.excellent,
            batteryHealth: batteryHealth,
            size: 108,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Condition Report',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (grade != null)
                  _ConditionRow(
                    label: 'Grade',
                    value: grade!.label,
                    valueColor: grade!.color,
                  ),
                if (batteryHealth != null)
                  _ConditionRow(
                    label: 'Battery',
                    value: '${(batteryHealth! * 100).round()}% health',
                    valueColor: AppColors.secondary,
                  ),
                _ConditionRow(
                  label: 'Inspected',
                  value: isInspected ? 'Verified ✓' : 'Not yet verified',
                  valueColor: isInspected ? AppColors.primary : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConditionRow extends StatelessWidget {
  const _ConditionRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Trust Block ───────────────────────────────────────────────────────────────

class _TrustBlock extends StatelessWidget {
  const _TrustBlock({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String label})>[
      if (product.hasReturnPolicy)
        (
          icon: Icons.replay_rounded,
          label: '${product.returnPolicyDays}-day returns',
        ),
      if (product.hasWarranty)
        (
          icon: Icons.shield_outlined,
          label: '${product.warrantyMonths}-month warranty',
        ),
      if (product.deliveredFrom.isNotEmpty)
        (
          icon: Icons.local_shipping_outlined,
          label: 'Ships from ${product.deliveredFrom}',
        ),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          children: [
            Icon(item.icon, size: 16, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

// ── Bottom Bar ────────────────────────────────────────────────────────────────

class _BottomBar extends ConsumerWidget {
  const _BottomBar({required this.product, required this.quantity});

  final ProductModel product;
  final int quantity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.md,
        AppSpacing.base,
        MediaQuery.viewPaddingOf(context).bottom + AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Total
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              Text(
                Formatters.currency(product.price * quantity),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.base),

          // Add to cart button — shows premium pill on success
          Expanded(
            child: AppButton(
              label: product.inStock ? 'Add to Cart' : 'Out of Stock',
              isDisabled: !product.inStock,
              icon: Icons.shopping_cart_outlined,
              onPressed: product.inStock
                  ? () async {
                      await ref
                          .read(cartNotifierProvider.notifier)
                          .addProduct(product);
                      if (context.mounted) {
                        // Premium floating pill instead of SnackBar
                        AddToCartPill.show(
                          context,
                          productName: product.name,
                        );
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quantity Selector ─────────────────────────────────────────────────────────

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.maxQuantity,
    required this.onChanged,
  });

  final int quantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.button),
        color: AppColors.backgroundCard,
      ),
      child: Row(
        children: [
          _QtyBtn(
            icon: Icons.remove_rounded,
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _QtyBtn(
            icon: Icons.add_rounded,
            onTap: quantity < maxQuantity ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Icon(
          icon,
          size: 16,
          color: active ? AppColors.primary : AppColors.divider,
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Container(
    height: 0.5,
    color: AppColors.divider,
  );
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.backgroundSheet.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}