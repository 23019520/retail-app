import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/models/order_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_loading.dart';
import '../providers/admin_orders_provider.dart';
import '../providers/admin_products_provider.dart';
import '../providers/admin_settings_provider.dart';
import '../widgets/admin_order_tile.dart';
import '../widgets/metric_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(allOrdersProvider);
    final productsAsync = ref.watch(adminProductsProvider);
    final settingsAsync = ref.watch(adminSettingsProvider);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final businessName = settingsAsync.value?.name ?? 'My Store';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App bar ─────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    businessName,
                    style: text.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Admin Dashboard',
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── Metrics grid ──────────────────────────────────
                  ordersAsync.when(
                    loading: () => const SizedBox(
                        height: 160, child: AppLoading()),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (orders) {
                      final pending = orders
                          .where((o) => o.status == OrderStatus.pending)
                          .length;
                      final today = orders.where((o) {
                        if (o.createdAt == null) return false;
                        final now = DateTime.now();
                        return o.createdAt!.year == now.year &&
                            o.createdAt!.month == now.month &&
                            o.createdAt!.day == now.day;
                      });
                      final todayRevenue = today.fold(
                          0.0, (sum, o) => sum + o.total);
                      final totalRevenue = orders
                          .where((o) => o.status == OrderStatus.completed)
                          .fold(0.0, (sum, o) => sum + o.total);

                      return GridView.count(
                        crossAxisCount:
                            MediaQuery.sizeOf(context).width > 600
                                ? 4
                                : 2,
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                        children: [
                          MetricCard(
                            label: 'Total Orders',
                            value: '${orders.length}',
                            icon: Icons.receipt_long_rounded,
                            iconColor: colors.primary,
                            onTap: () =>
                                context.go(RouteConstants.adminOrders),
                          ),
                          MetricCard(
                            label: 'Pending',
                            value: '$pending',
                            icon: Icons.schedule_rounded,
                            iconColor: const Color(0xFFF57F17),
                            onTap: () =>
                                context.go(RouteConstants.adminOrders),
                          ),
                          MetricCard(
                            label: "Today's Revenue",
                            value: Formatters.currency(todayRevenue),
                            icon: Icons.today_rounded,
                            iconColor: Colors.green,
                          ),
                          MetricCard(
                            label: 'Total Revenue',
                            value: Formatters.currency(totalRevenue),
                            icon: Icons.payments_outlined,
                            iconColor: const Color(0xFF7B1FA2),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Low stock alert ────────────────────────────────
                  productsAsync.when(
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
                            title: '⚠️ Stock Alerts',
                            subtitle:
                                '${lowStock.length} product${lowStock.length == 1 ? '' : 's'} need attention',
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.orange
                                      .withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              children: lowStock
                                  .map((p) => ListTile(
                                        leading: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: (p.inStock
                                                    ? Colors.orange
                                                    : colors.error)
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                          ),
                                          child: Icon(
                                            Icons.inventory_2_outlined,
                                            size: 18,
                                            color: p.inStock
                                                ? Colors.orange
                                                : colors.error,
                                          ),
                                        ),
                                        title: Text(p.name,
                                            style: text.bodyMedium
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w500)),
                                        subtitle: Text(
                                          p.inStock
                                              ? '${p.stock} left'
                                              : 'Out of stock',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: p.inStock
                                                ? Colors.orange
                                                : colors.error,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        trailing: TextButton(
                                          onPressed: () => context.go(
                                              RouteConstants.adminProducts),
                                          child: const Text('Edit'),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),

                  // ── Recent orders ─────────────────────────────────
                  _SectionHeader(
                    title: 'Recent Orders',
                    actionLabel: 'See all',
                    onAction: () =>
                        context.go(RouteConstants.adminOrders),
                  ),
                  const SizedBox(height: 12),

                  ordersAsync.when(
                    loading: () =>
                        const SizedBox(height: 100, child: AppLoading()),
                    error: (_, __) =>
                        const Text('Could not load orders.'),
                    data: (orders) {
                      if (orders.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(32),
                          alignment: Alignment.center,
                          child: Text(
                            'No orders yet',
                            style: text.bodyMedium?.copyWith(
                              color: colors.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        );
                      }
                      final recent = orders.take(5).toList();
                      return Column(
                        children: recent
                            .map((o) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 10),
                                  child: AdminOrderTile(order: o),
                                ))
                            .toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
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
