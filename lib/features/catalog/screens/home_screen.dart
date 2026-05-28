import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/widgets/app_loading.dart';
import '../providers/products_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';
import '../widgets/promo_banner.dart';
import '../widgets/search_bar_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final featuredAsync = ref.watch(featuredProductsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            expandedHeight: 0,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: colors.onPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'My Store',
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: colors.onSurface,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── Search bar ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SearchBarWidget(
                    readOnly: true,
                    onTap: () => context.go(RouteConstants.productList),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Promo banner ──────────────────────────────────────
                const PromoBanner(),
                const SizedBox(height: 24),

                // ── Category chips ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 12),
                  child: Text(
                    'Categories',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const CategoryChipRow(),
                const SizedBox(height: 24),

                // ── Featured products header ───────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured',
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go(RouteConstants.productList),
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),

          // ── Featured products grid ─────────────────────────────────
          featuredAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: SizedBox(height: 200, child: AppLoading()),
            ),
            error: (_, __) => const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
            data: (products) {
              if (products.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No products yet'),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        ProductCard(product: products[index]),
                    childCount: products.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
