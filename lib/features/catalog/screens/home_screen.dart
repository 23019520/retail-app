import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/app_stagger.dart';
import '../../../theme/app_theme.dart';
import '../providers/products_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      body: AppStagger(
        child: CustomScrollView(
          slivers: [
            // ── App bar ──────────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: AppColors.backgroundBase,
              expandedHeight: 0,
              title: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: const Icon(
                      Icons.laptop_mac_rounded,
                      color: Color(0xFF0E2419),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    'Laptops',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  color: AppColors.textSecondary,
                  onPressed: () {},
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.sm),

                  // ── Search bar ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                    child: SearchBarWidget(
                      readOnly: true,
                      onTap: () => context.go(RouteConstants.productList),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Hero banner ────────────────────────────────────────
                  AppStaggerItem(
                    index: 0,
                    child: _HeroBanner(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Categories ────────────────────────────────────────
                  const AppStaggerItem(
                    index: 1,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: AppSpacing.base,
                        bottom: AppSpacing.md,
                      ),
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const AppStaggerItem(
                    index: 2,
                    child: CategoryChipRow(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Featured header ───────────────────────────────────
                  AppStaggerItem(
                    index: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Featured',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go(RouteConstants.productList),
                            child: const Text('See all'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),

            // ── Featured products grid ─────────────────────────────────
            featuredAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: ProductGridSkeleton(count: 4),
              ),
              error: (_, __) => const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          'No products yet',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base,
                    0,
                    AppSpacing.base,
                    AppSpacing.xl,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => AppStaggerItem(
                        index: index + 4,
                        child: ProductCard(product: products[index]),
                      ),
                      childCount: products.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Container(
        height: 152,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.divider, width: 0.5),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E2A22),
              Color(0xFF1F2228),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Subtle teal glow top-left
            Positioned(
              top: -20,
              left: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.07),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Quality-checked\nlaptops from R3,500',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.25,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Every device graded and battery-checked, with 7-day returns.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Laptop icon top-right
            const Positioned(
              right: AppSpacing.lg,
              top: 0,
              bottom: 0,
              child: Icon(
                Icons.laptop_mac_rounded,
                size: 72,
                color: Color(0xFF2A3A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}