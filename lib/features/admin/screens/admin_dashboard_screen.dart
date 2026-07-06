import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/models/order_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/app_stagger.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../theme/app_theme.dart';
import '../providers/admin_orders_provider.dart';
import '../providers/admin_products_provider.dart';
import '../providers/admin_settings_provider.dart';
import '../widgets/admin_order_tile.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync  = ref.watch(allOrdersProvider);
    final productsAsync = ref.watch(adminProductsProvider);
    final settingsAsync = ref.watch(adminSettingsProvider);

    final businessName = settingsAsync.value?.name ?? 'My Store';

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      body: SafeArea(
        child: AppStagger(
          child: CustomScrollView(
            slivers: [
              // ── App bar ────────────────────────────────────────────────
              SliverAppBar(
                floating: true,
                snap: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: AppColors.backgroundBase,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.base),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // ── Metrics grid ───────────────────────────────────────
                    AppStaggerItem(
                      index: 0,
                      child: ordersAsync.when(
                        loading: () => const SizedBox(
                          height: 160,
                          child: AppLoading(),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (orders) {
                          final pending = orders
                              .where((o) => o.status == OrderStatus.pending)
                              .length;
                          final today = orders.where((o) {
                            if (o.createdAt == null) return false;
                            final now = DateTime.now();
                            return o.createdAt!.year  == now.year  &&
                                   o.createdAt!.month == now.month &&
                                   o.createdAt!.day   == now.day;
                          });
                          final todayRevenue = today.fold(
                              0.0, (s, o) => s + o.total);
                          final totalRevenue = orders
                              .where((o) => o.status == OrderStatus.completed)
                              .fold(0.0, (s, o) => s + o.total);

                          return GridView.count(
                            crossAxisCount:
                                MediaQuery.sizeOf(context).width > 600 ? 4 : 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: AppSpacing.sm,
                            mainAxisSpacing: AppSpacing.sm,
                            childAspectRatio: 1.15,
                            children: [
                              MetricCard(
                                label: 'Total Orders',
                                value: '${orders.length}',
                                icon: Icons.receipt_long_rounded,
                                iconColor: AppColors.primary,
                                onTap: () => context.go(RouteConstants.adminOrders),
                              ),
                              MetricCard(
                                label: 'Pending',
                                value: '$pending',
                                icon: Icons.schedule_rounded,
                                iconColor: AppColors.secondary,
                                onTap: () => context.go(RouteConstants.adminOrders),
                              ),
                              MetricCard(
                                label: "Today's Revenue",
                                value: Formatters.currency(todayRevenue),
                                icon: Icons.today_rounded,
                                iconColor: AppColors.gradeNew,
                              ),
                              MetricCard(
                                label: 'Total Revenue',
                                value: Formatters.currency(totalRevenue),
                                icon: Icons.payments_outlined,
                                iconColor: const Color(0xFF9B7FD4),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Low stock alert ────────────────────────────────────
                    AppStaggerItem(
                      index: 1,
                      child: productsAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (products) {
                          final lowStock = products
                              .where((p) => p.lowStock || !p.inStock)
                              .toList();
                          if (lowStock.isEmpty) return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionHeader(
                                title: 'Stock Alerts',
                                subtitle:
                                    '${lowStock.length} product${lowStock.length == 1 ? '' : 's'} need attention',
                                titleColor: AppColors.secondary,
                                icon: Icons.warning_amber_rounded,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundCard,
                                  borderRadius: BorderRadius.circular(AppRadius.card),
                                  border: Border.all(
                                    color: AppColors.secondary.withValues(alpha: 0.2),
                                    width: 0.5,
                                  ),
                                ),
                                child: Column(
                                  children: lowStock.asMap().entries.map((e) {
                                    final i = e.key;
                                    final p = e.value;
                                    return Column(
                                      children: [
                                        ListTile(
                                          leading: Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: (p.inStock
                                                      ? AppColors.secondary
                                                      : AppColors.error)
                                                  .withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(AppRadius.chip),
                                            ),
                                            child: Icon(
                                              Icons.inventory_2_outlined,
                                              size: 16,
                                              color: p.inStock
                                                  ? AppColors.secondary
                                                  : AppColors.error,
                                            ),
                                          ),
                                          title: Text(
                                            p.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          subtitle: Text(
                                            p.inStock
                                                ? '${p.stock} left'
                                                : 'Out of stock',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: p.inStock
                                                  ? AppColors.secondary
                                                  : AppColors.error,
                                            ),
                                          ),
                                          trailing: TextButton(
                                            onPressed: () => context
                                                .go(RouteConstants.adminProducts),
                                            child: const Text('Edit'),
                                          ),
                                        ),
                                        if (i < lowStock.length - 1)
                                          Container(
                                            height: 0.5,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.base,
                                            ),
                                            color: AppColors.divider,
                                          ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                          );
                        },
                      ),
                    ),

                    // ── Recent orders ──────────────────────────────────────
                    AppStaggerItem(
                      index: 2,
                      child: _SectionHeader(
                        title: 'Recent Orders',
                        actionLabel: 'See all',
                        onAction: () => context.go(RouteConstants.adminOrders),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AppStaggerItem(
                      index: 3,
                      child: ordersAsync.when(
                        loading: () => const SizedBox(
                          height: 100,
                          child: AppLoading(),
                        ),
                        error: (_, __) => const Text(
                          'Could not load orders.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        data: (orders) {
                          if (orders.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundCard,
                                borderRadius: BorderRadius.circular(AppRadius.card),
                                border: Border.all(color: AppColors.divider, width: 0.5),
                              ),
                              child: const Text(
                                'No orders yet',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }
                          final recent = orders.take(5).toList();
                          return Column(
                            children: recent
                                .map((o) => Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: AppSpacing.sm),
                                      child: AdminOrderTile(order: o),
                                    ))
                                .toList(),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.titleColor,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: titleColor ?? AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: titleColor ?? AppColors.textPrimary,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}
