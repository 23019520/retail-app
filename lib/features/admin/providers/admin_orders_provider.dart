import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/order_model.dart';
import '../../cart/providers/checkout_provider.dart';

/// All orders — admin only.
final allOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.watch(orderServiceProvider).streamAllOrders();
});

/// Orders filtered by a specific status — used by the tab views.
final ordersByStatusProvider =
    Provider.family<AsyncValue<List<OrderModel>>, List<OrderStatus>>(
        (ref, statuses) {
  return ref.watch(allOrdersProvider).whenData(
        (orders) => statuses.isEmpty
            ? orders
            : orders.where((o) => statuses.contains(o.status)).toList(),
      );
});

/// Order status update action.
final orderStatusNotifierProvider =
    Provider<OrderStatusNotifier>((ref) => OrderStatusNotifier(ref));

class OrderStatusNotifier {
  OrderStatusNotifier(this._ref);
  final Ref _ref;

  Future<bool> updateStatus(String orderId, OrderStatus status) async {
    try {
      await _ref.read(orderServiceProvider).updateOrderStatus(orderId, status);
      return true;
    } catch (_) {
      return false;
    }
  }
}
