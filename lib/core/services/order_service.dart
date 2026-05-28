import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/app_constants.dart';
import '../constants/firestore_constants.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';

class OrderService {
  OrderService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String get _businessId =>
      dotenv.env['BUSINESS_ID'] ?? AppConstants.defaultBusinessId;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection(FirestoreConstants.orders);

  // ── Create ────────────────────────────────────────────────────────────────

  /// Creates a new order document and returns the generated order ID.
  Future<String> createOrder({
    required String userId,
    required CartModel cart,
    required DeliveryMethod deliveryMethod,
    required PaymentMethod paymentMethod,
    required double deliveryFee,
    String? deliveryAddress,
    String? notes,
  }) async {
    final docRef = _orders.doc(); // auto-generate ID

    final subtotal = cart.subtotal;
    final total = subtotal + (deliveryMethod == DeliveryMethod.delivery ? deliveryFee : 0);

    final order = OrderModel(
      id: docRef.id,
      userId: userId,
      businessId: _businessId,
      items: cart.items.map(OrderItem.fromCartItem).toList(),
      subtotal: subtotal,
      deliveryFee: deliveryMethod == DeliveryMethod.delivery ? deliveryFee : 0,
      total: total,
      status: OrderStatus.pending,
      deliveryMethod: deliveryMethod,
      paymentMethod: paymentMethod,
      deliveryAddress: deliveryAddress,
      notes: notes,
    );

    await docRef.set(order.toJson());
    return docRef.id;
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Stream all orders for a specific user, newest first.
  Stream<List<OrderModel>> streamUserOrders(String userId) {
    return _orders
        .where(FirestoreConstants.userId, isEqualTo: userId)
        .where(FirestoreConstants.businessId, isEqualTo: _businessId)
        .orderBy(FirestoreConstants.createdAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(OrderModel.fromDoc).toList());
  }

  /// Stream all orders for admin — newest first.
  Stream<List<OrderModel>> streamAllOrders() {
    return _orders
        .where(FirestoreConstants.businessId, isEqualTo: _businessId)
        .orderBy(FirestoreConstants.createdAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(OrderModel.fromDoc).toList());
  }

  /// Fetch a single order by ID.
  Future<OrderModel?> fetchOrder(String orderId) async {
    try {
      final doc = await _orders.doc(orderId).get();
      if (!doc.exists) return null;
      return OrderModel.fromDoc(doc);
    } catch (_) {
      return null;
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────

  /// Update order status — admin only.
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _orders.doc(orderId).update({
      FirestoreConstants.status: status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
