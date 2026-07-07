import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/app_stagger.dart';
import '../../../theme/app_theme.dart';
import '../providers/admin_products_provider.dart';
import '../widgets/admin_product_tile.dart';

// ══════════════════════════════════════════════════════════════════════════════
// PRODUCT MANAGEMENT SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class ProductManagementScreen extends ConsumerStatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  ConsumerState<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState
    extends ConsumerState<ProductManagementScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(adminProductsProvider);

    return Scaffold(
      
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Search field
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      borderRadius: BorderRadius.circular(AppRadius.button),
                      border: Border.all(color: AppColors.divider, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: AppSpacing.md),
                        const Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) => setState(() => _query = v),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search products...',
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textMuted,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              suffixIcon: _query.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                        color: AppColors.textMuted,
                                      ),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() => _query = '');
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── List ────────────────────────────────────────────────────
            Expanded(
              child: productsAsync.when(
                loading: () => const AppLoading(),
                error: (_, __) => AppErrorWidget(
                  message: 'Could not load products.',
                  onRetry: () => ref.invalidate(adminProductsProvider),
                ),
                data: (products) {
                  final filtered = _query.isEmpty
                      ? products
                      : products
                          .where((p) => p.name
                              .toLowerCase()
                              .contains(_query.toLowerCase()))
                          .toList();

                  if (filtered.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: _query.isNotEmpty ? 'No results' : 'No products yet',
                      subtitle: _query.isNotEmpty
                          ? 'Try a different search.'
                          : 'Tap + to add your first product.',
                    );
                  }

                  return AppStagger(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.base,
                        AppSpacing.xs,
                        AppSpacing.base,
                        100,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        return AppStaggerItem(
                          index: index,
                          child: AdminProductTile(
                            product: product,
                            onEdit: () {
                              ref
                                  .read(productToEditProvider.notifier)
                                  .state = product;
                              context.push(RouteConstants.adminProductForm);
                            },
                            onDelete: () async {
                              final confirmed = await showConfirmationDialog(
                                context,
                                title: 'Delete product?',
                                message:
                                    '"${product.name}" will be permanently deleted.',
                                confirmLabel: 'Delete',
                                isDestructive: true,
                              );
                              if (confirmed && context.mounted) {
                                await ref
                                    .read(productFormProvider.notifier)
                                    .delete(product);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(productToEditProvider.notifier).state = null;
          ref.read(productFormProvider.notifier).reset();
          context.push(RouteConstants.adminProductForm);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Product'),
        backgroundColor: AppColors.primary,
        foregroundColor: const Color(0xFF0E2419),
        elevation: 0,
      ),
    );
  }
}
