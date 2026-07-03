import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/order_model.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/app_stagger.dart';
import '../../../theme/app_theme.dart';
import '../providers/admin_orders_provider.dart';
import '../widgets/admin_order_tile.dart';

class OrderManagementScreen extends ConsumerStatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  ConsumerState<OrderManagementScreen> createState() =>
      _OrderManagementScreenState();
}

class _OrderManagementScreenState extends ConsumerState<OrderManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    (label: 'All',     statuses: <OrderStatus>[]),
    (label: 'Pending', statuses: [OrderStatus.pending]),
    (label: 'Active',  statuses: [
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
    ]),
    (label: 'Done',    statuses: [OrderStatus.completed]),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.base,
                0,
              ),
              child: Text(
                'Orders',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.base),

            // ── Tab bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  border: Border.all(color: AppColors.divider, width: 0.5),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF0E2419),
                  unselectedLabelColor: AppColors.textMuted,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.chip + 2),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  padding: const EdgeInsets.all(3),
                  tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Tab views ─────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabs.map((tab) {
                  final ordersAsync =
                      ref.watch(ordersByStatusProvider(tab.statuses));

                  return ordersAsync.when(
                    loading: () => const AppLoading(),
                    error: (_, __) => AppErrorWidget(
                      message: 'Could not load orders.',
                      onRetry: () => ref.invalidate(allOrdersProvider),
                    ),
                    data: (orders) {
                      if (orders.isEmpty) {
                        return const AppEmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'No orders here',
                          subtitle: 'Orders will appear here as they come in.',
                        );
                      }
                      return AppStagger(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.base,
                            AppSpacing.xs,
                            AppSpacing.base,
                            AppSpacing.xl,
                          ),
                          itemCount: orders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) => AppStaggerItem(
                            index: index,
                            child: AdminOrderTile(order: orders[index]),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
