import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_model.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.pending:   return 'Pending';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.preparing: return 'Preparing';
      case OrderStatus.ready:     return 'Ready';
      case OrderStatus.completed: return 'Completed';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }

  String get description {
    switch (this) {
      case OrderStatus.pending:   return 'We\'ve received your order and are reviewing it.';
      case OrderStatus.confirmed: return 'Your order has been confirmed and is being prepared.';
      case OrderStatus.preparing: return 'Your item is being packed and made ready.';
      case OrderStatus.ready:     return 'Your order is ready for collection or out for delivery.';
      case OrderStatus.completed: return 'Order delivered. Enjoy!';
      case OrderStatus.cancelled: return 'This order was cancelled.';
    }
  }

  static OrderStatus fromString(String? s) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => OrderStatus.pending,
    );
  }

  /// The ordered pipeline — excludes cancelled since it's a terminal
  /// branch, not a step in the normal flow.
  static const List<OrderStatus> pipeline = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.completed,
  ];
}

enum DeliveryMethod { delivery, pickup }

extension DeliveryMethodX on DeliveryMethod {
  String get label => this == DeliveryMethod.delivery ? 'Delivery' : 'Pickup';
}

enum PaymentMethod { yoco, cash }

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.yoco: return 'Yoco';
      case PaymentMethod.cash: return 'Cash on Delivery';
    }
  }
}

// ── Status history entry ──────────────────────────────────────────────────────

/// Records when a specific status was reached.
class StatusEvent {
  const StatusEvent({required this.status, required this.timestamp});

  final OrderStatus status;
  final DateTime timestamp;

  factory StatusEvent.fromJson(Map<String, dynamic> json) {
    return StatusEvent(
      status: OrderStatus.fromString(json['status'] as String?),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'timestamp': Timestamp.fromDate(timestamp),
  };
}

// ── Order item ────────────────────────────────────────────────────────────────

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;

  double get subtotal => price * quantity;

  factory OrderItem.fromCartItem(CartItem item) {
    return OrderItem(
      productId: item.productId,
      productName: item.productName,
      price: item.price,
      quantity: item.quantity,
      imageUrl: item.imageUrl,
    );
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'price': price,
    'quantity': quantity,
    'imageUrl': imageUrl,
  };
}

// ── Order model ───────────────────────────────────────────────────────────────

class OrderModel {
  const OrderModel({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.deliveryMethod,
    required this.paymentMethod,
    this.deliveryAddress,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.statusHistory = const [],
  });

  final String id;
  final String userId;
  final String businessId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final DeliveryMethod deliveryMethod;
  final PaymentMethod paymentMethod;
  final String? deliveryAddress;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Chronological list of status transitions.
  /// Written by the admin when they update an order's status.
  final List<StatusEvent> statusHistory;

  int get itemCount => items.fold(0, (acc, item) => acc + item.quantity);

  /// Returns the timestamp for a specific status from history, if recorded.
  DateTime? timestampFor(OrderStatus s) {
    try {
      return statusHistory.firstWhere((e) => e.status == s).timestamp;
    } catch (_) {
      return null;
    }
  }

  OrderModel copyWith({
    String? id,
    OrderStatus? status,
    DateTime? updatedAt,
    String? notes,
    List<StatusEvent>? statusHistory,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId,
      businessId: businessId,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      status: status ?? this.status,
      deliveryMethod: deliveryMethod,
      paymentMethod: paymentMethod,
      deliveryAddress: deliveryAddress,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      businessId: json['businessId'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.fromString(json['status'] as String?),
      deliveryMethod: json['deliveryMethod'] == 'pickup'
          ? DeliveryMethod.pickup
          : DeliveryMethod.delivery,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      deliveryAddress: json['deliveryAddress'] as String?,
      notes: json['notes'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      statusHistory: (json['statusHistory'] as List<dynamic>?)
              ?.map((e) => StatusEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory OrderModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'businessId': businessId,
    'items': items.map((e) => e.toJson()).toList(),
    'subtotal': subtotal,
    'deliveryFee': deliveryFee,
    'total': total,
    'status': status.name,
    'deliveryMethod': deliveryMethod.name,
    'paymentMethod': paymentMethod.name,
    'deliveryAddress': deliveryAddress,
    'notes': notes,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    'statusHistory': statusHistory.map((e) => e.toJson()).toList(),
  };
}