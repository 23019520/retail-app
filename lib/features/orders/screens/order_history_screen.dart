import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/order_model.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loading.dart';
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
    (label: 'All', status: null),
    (label: 'Active', status: _activeStatuses),
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
    final colors = Theme.of(context).colorScheme;
    final ordersAsync = ref.watch(userOrdersProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'My Orders',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Tab bar ──────────────────────────────────────────────
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
                  unselectedLabelColor: colors.onSurface.withValues(alpha: 0.6),
                  indicator: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: _tabs
                      .map((t) => Tab(text: t.label))
                      .toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Tab views ────────────────────────────────────────────
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

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => OrderTile(order: orders[index]),
    );
  }
}
