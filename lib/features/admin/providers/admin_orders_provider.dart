import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/order_model.dart';
import '../../../core/constants/firestore_constants.dart';
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

  final _firestore = FirebaseFirestore.instance;

  /// Updates order status and appends a timestamped entry to statusHistory.
  Future<bool> updateStatus(String orderId, OrderStatus status) async {
    try {
      final newEvent = StatusEvent(
        status: status,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection(FirestoreConstants.orders)
          .doc(orderId)
          .update({
        FirestoreConstants.status: status.name,
        'updatedAt': FieldValue.serverTimestamp(),
        // FieldValue.arrayUnion appends without reading first
        'statusHistory': FieldValue.arrayUnion([newEvent.toJson()]),
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}