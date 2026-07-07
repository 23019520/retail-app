import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/models/category_model.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/app_stagger.dart';
import '../../../theme/app_theme.dart';
import '../providers/admin_categories_provider.dart';
import '../providers/admin_products_provider.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);

    return Scaffold(
      
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.lg,
              ),
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            Expanded(
              child: categoriesAsync.when(
                loading: () => const AppLoading(),
                error: (_, __) => AppErrorWidget(
                  message: 'Could not load categories.',
                  onRetry: () => ref.invalidate(adminCategoriesProvider),
                ),
                data: (categories) {
                  if (categories.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.category_outlined,
                      title: 'No categories yet',
                      subtitle: 'Tap + to add your first category.',
                    );
                  }

                  return AppStagger(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.base,
                        0,
                        AppSpacing.base,
                        100,
                      ),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) => AppStaggerItem(
                        index: index,
                        child: _CategoryTile(
                          category: categories[index],
                          onTap: () {
                            ref
                                .read(categoryToEditProvider.notifier)
                                .state = categories[index];
                            context.push(RouteConstants.adminCategoryForm);
                          },
                        ),
                      ),
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
          ref.read(categoryToEditProvider.notifier).state = null;
          ref.read(categoryFormProvider.notifier).reset();
          context.push(RouteConstants.adminCategoryForm);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Category'),
        backgroundColor: AppColors.primary,
        foregroundColor: const Color(0xFF0E2419),
        elevation: 0,
      ),
    );
  }
}

// ── Category tile ─────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final CategoryModel category;
  final VoidCallback onTap;

  Color get _typeColor {
    switch (category.productType) {
      case ProductType.electronics: return AppColors.primary;
      case ProductType.accessory:   return AppColors.secondary;
      case ProductType.tool:        return AppColors.gradeGood;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: Icon(
                _iconFor(category.iconName),
                size: 20,
                color: _typeColor,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Name + type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category.productType.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _typeColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Sort: ${category.sortOrder}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Active indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: category.isActive
                    ? AppColors.primary
                    : AppColors.textMuted,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    const map = <String, IconData>{
      'laptop':          Icons.laptop_mac_outlined,
      'desktop_windows': Icons.desktop_windows_outlined,
      'keyboard':        Icons.keyboard_outlined,
      'mouse':           Icons.mouse_outlined,
      'headphones':      Icons.headphones_outlined,
      'phone':           Icons.phone_android_outlined,
      'tablet':          Icons.tablet_outlined,
      'build':           Icons.build_outlined,
      'cable':           Icons.cable_outlined,
      'battery':         Icons.battery_full_outlined,
      'bag':             Icons.work_outline_rounded,
      'monitor':         Icons.monitor_outlined,
      'apps':            Icons.apps_rounded,
      'grid_view':       Icons.grid_view_rounded,
    };
    return map[name] ?? Icons.category_outlined;
  }
}