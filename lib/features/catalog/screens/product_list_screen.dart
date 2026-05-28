import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loading.dart';
import '../providers/products_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar_widget.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredProductsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Products',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const SearchBarWidget(autofocus: false),
                ],
              ),
            ),

            // ── Category filter ───────────────────────────────────────
            const CategoryChipRow(),
            const SizedBox(height: 8),

            // ── Results count ─────────────────────────────────────────
            filteredAsync.whenData((products) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  searchQuery.isNotEmpty
                      ? '${products.length} result${products.length == 1 ? '' : 's'} for "$searchQuery"'
                      : '${products.length} product${products.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                      ),
                ),
              );
            }).value ?? const SizedBox.shrink(),

            // ── Grid ──────────────────────────────────────────────────
            Expanded(
              child: filteredAsync.when(
                loading: () => const AppLoading(message: 'Loading products...'),
                error: (error, _) => AppErrorWidget(
                  message: 'Could not load products.',
                  onRetry: () => ref.invalidate(productsProvider),
                ),
                data: (products) {
                  if (products.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.search_off_rounded,
                      title: searchQuery.isNotEmpty
                          ? 'No results found'
                          : 'No products here yet',
                      subtitle: searchQuery.isNotEmpty
                          ? 'Try a different search term or browse all categories.'
                          : 'Check back soon.',
                      action: searchQuery.isNotEmpty
                          ? () => ref
                              .read(searchQueryProvider.notifier)
                              .state = ''
                          : null,
                      actionLabel:
                          searchQuery.isNotEmpty ? 'Clear search' : null,
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) =>
                        ProductCard(product: products[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
