import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/app_stagger.dart';
import '../../../theme/app_theme.dart';
import '../providers/products_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar_widget.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync  = ref.watch(filteredProductsProvider);
    final searchQuery    = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  SearchBarWidget(autofocus: false),
                ],
              ),
            ),

            // ── Category filter ─────────────────────────────────────────
            const CategoryChipRow(),
            const SizedBox(height: AppSpacing.sm),

            // ── Results count ───────────────────────────────────────────
            filteredAsync.whenData((products) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.xs,
                ),
                child: Text(
                  searchQuery.isNotEmpty
                      ? '${products.length} result${products.length == 1 ? '' : 's'} for "$searchQuery"'
                      : '${products.length} product${products.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              );
            }).value ?? const SizedBox.shrink(),

            // ── Grid ────────────────────────────────────────────────────
            Expanded(
              child: filteredAsync.when(
                loading: () => const ProductGridSkeleton(count: 6),
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
                          : 'No products yet',
                      subtitle: searchQuery.isNotEmpty
                          ? 'Try a different search term.'
                          : 'Check back soon.',
                      action: searchQuery.isNotEmpty
                          ? () => ref
                              .read(searchQueryProvider.notifier)
                              .state = ''
                          : null,
                      actionLabel: searchQuery.isNotEmpty ? 'Clear search' : null,
                    );
                  }

                  return AppStagger(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.base,
                        AppSpacing.sm,
                        AppSpacing.base,
                        AppSpacing.xl,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) => AppStaggerItem(
                        index: index,
                        child: ProductCard(product: products[index]),
                      ),
                    ),
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
