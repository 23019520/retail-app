import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/order_model.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/app_stagger.dart';
import '../../../theme/app_theme.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_tile.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    (label: 'All',       status: null),
    (label: 'Active',    status: _activeStatuses),
    (label: 'Completed', status: [OrderStatus.completed]),
    (label: 'Cancelled', status: [OrderStatus.cancelled]),
  ];

  static const _activeStatuses = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.ready,
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
    final ordersAsync = ref.watch(userOrdersProvider);

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
                'My Orders',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.base),

            // ── Tab bar ───────────────────────────────────────────────────
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

            const SizedBox(height: AppSpacing.base),

            // ── Tab views ─────────────────────────────────────────────────
            Expanded(
              child: ordersAsync.when(
                loading: () => const AppLoading(),
                error: (_, __) => AppErrorWidget(
                  message: 'Could not load your orders.',
                  onRetry: () => ref.invalidate(userOrdersProvider),
                ),
                data: (orders) => TabBarView(
                  controller: _tabController,
                  children: _tabs.map((tab) {
                    final filtered = tab.status == null
                        ? orders
                        : orders
                            .where((o) =>
                                (tab.status as List<OrderStatus>)
                                    .contains(o.status))
                            .toList();
                    return _OrderList(orders: filtered);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({required this.orders});

  final List<OrderModel> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No orders here',
        subtitle: 'Orders in this category will appear here.',
      );
    }

    return AppStagger(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.base,
          0,
          AppSpacing.base,
          AppSpacing.xl,
        ),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) => AppStaggerItem(
          index: index,
          child: OrderTile(order: orders[index]),
        ),
      ),
    );
  }
}
