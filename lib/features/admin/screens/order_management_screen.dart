import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/order_model.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loading.dart';
import '../providers/admin_orders_provider.dart';
import '../widgets/admin_order_tile.dart';

class OrderManagementScreen extends ConsumerStatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  ConsumerState<OrderManagementScreen> createState() =>
      _OrderManagementScreenState();
}

class _OrderManagementScreenState
    extends ConsumerState<OrderManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    (label: 'All', statuses: <OrderStatus>[]),
    (label: 'Pending', statuses: [OrderStatus.pending]),
    (label: 'Active', statuses: [
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready
    ]),
    (label: 'Done', statuses: [OrderStatus.completed]),
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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Orders',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: colors.onPrimary,
                  unselectedLabelColor:
                      colors.onSurface.withValues(alpha: 0.6),
                  indicator: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  tabs: _tabs
                      .map((t) => Tab(text: t.label))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),

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
                      onRetry: () =>
                          ref.invalidate(allOrdersProvider),
                    ),
                    data: (orders) {
                      if (orders.isEmpty) {
                        return const AppEmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'No orders here',
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                            20, 4, 20, 32),
                        itemCount: orders.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            AdminOrderTile(order: orders[index]),
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
