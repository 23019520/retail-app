import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../providers/admin_products_provider.dart';
import '../widgets/admin_product_tile.dart';

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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Products',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),

            // ── List ────────────────────────────────────────────────
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
                      title: _query.isNotEmpty
                          ? 'No results'
                          : 'No products yet',
                      subtitle: _query.isNotEmpty
                          ? 'Try a different search.'
                          : 'Tap + to add your first product.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return AdminProductTile(
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
                      );
                    },
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
      ),
    );
  }
}
