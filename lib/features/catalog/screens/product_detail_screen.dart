import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/models/product_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loading.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/product_image_carousel.dart';

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
      loading: () => const Scaffold(body: AppLoading()),
      error: (_, __) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: 'Could not load product.',
          onRetry: () =>
              ref.invalidate(productByIdProvider(widget.productId)),
        ),
      ),
      data: (product) {
        if (product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const AppErrorWidget(message: 'Product not found.'),
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
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          // ── Scrollable content ──────────────────────────────────────
          CustomScrollView(
            slivers: [
              // Image carousel with back button overlay
              SliverAppBar(
                expandedHeight: screenHeight * 0.42,
                pinned: true,
                backgroundColor: colors.surface,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _CircleIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => context.pop(),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: _CircleIconButton(
                      icon: Icons.favorite_border_rounded,
                      onTap: () {},
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: ProductImageCarousel(
                    imageUrls: product.imageUrls,
                    height: screenHeight * 0.42,
                  ),
                ),
              ),

              // Product info
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Name + price row ──────────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: text.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              Formatters.currency(product.price),
                              style: text.titleLarge?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ── Stock status ──────────────────────────────
                        _StockStatus(product: product, colors: colors),

                        const SizedBox(height: 24),
                        Divider(color: colors.outline.withValues(alpha: 0.15)),
                        const SizedBox(height: 20),

                        // ── Description ───────────────────────────────
                        Text(
                          'Description',
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          product.description.isNotEmpty
                              ? product.description
                              : 'No description available.',
                          style: text.bodyMedium?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.7),
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Quantity selector ─────────────────────────
                        Row(
                          children: [
                            Text(
                              'Quantity',
                              style: text.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            _QuantitySelector(
                              quantity: quantity,
                              maxQuantity: product.stock,
                              onChanged: onQuantityChanged,
                              colors: colors,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Sticky bottom bar ───────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomBar(
              product: product,
              quantity: quantity,
              colors: colors,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _StockStatus extends StatelessWidget {
  const _StockStatus({required this.product, required this.colors});
  final ProductModel product;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    if (!product.inStock) {
      return _badge('Out of stock', colors.error);
    }
    if (product.lowStock) {
      return _badge('Only ${product.stock} left!', Colors.orange);
    }
    return _badge('In stock', Colors.green.shade600);
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.maxQuantity,
    required this.onChanged,
    required this.colors,
  });

  final int quantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _QtyButton(
            icon: Icons.remove_rounded,
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
            colors: colors,
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _QtyButton(
            icon: Icons.add_rounded,
            onTap: quantity < maxQuantity ? () => onChanged(quantity + 1) : null,
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.colors,
  });
  final IconData icon;
  final VoidCallback? onTap;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: onTap != null
              ? colors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null
              ? colors.primary
              : colors.onSurface.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar({
    required this.product,
    required this.quantity,
    required this.colors,
  });
  final ProductModel product;
  final int quantity;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.viewPaddingOf(context).bottom + 16,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Total price
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                Formatters.currency(product.price * quantity),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // Add to cart button
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: colors.primary,
                            action: SnackBarAction(
                              label: 'View Cart',
                              textColor: colors.onPrimary,
                              onPressed: () =>
                                  context.go(RouteConstants.cart),
                            ),
                          ),
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

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}
