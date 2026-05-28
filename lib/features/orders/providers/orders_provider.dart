import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/order_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/checkout_provider.dart';

/// Live stream of the current user's orders, newest first.
final userOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(orderServiceProvider).streamUserOrders(user.uid);
});

/// Single order by ID — used by OrderDetailScreen.
final orderByIdProvider =
    FutureProvider.family<OrderModel?, String>((ref, orderId) {
  return ref.watch(orderServiceProvider).fetchOrder(orderId);
});
