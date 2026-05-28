import 'product_model.dart';

class CartItem {
  const CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.maxStock = 99,
  });

  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;
  final int maxStock;

  double get subtotal => price * quantity;
  bool get atMaxQuantity => quantity >= maxStock;

  CartItem copyWith({
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    String? imageUrl,
    int? maxStock,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      maxStock: maxStock ?? this.maxStock,
    );
  }

  factory CartItem.fromProduct(ProductModel product, {int quantity = 1}) {
    return CartItem(
      productId: product.id,
      productName: product.name,
      price: product.price,
      quantity: quantity,
      imageUrl: product.primaryImage,
      maxStock: product.stock,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
      imageUrl: json['imageUrl'] as String?,
      maxStock: json['maxStock'] as int? ?? 99,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'price': price,
    'quantity': quantity,
    'imageUrl': imageUrl,
    'maxStock': maxStock,
  };
}

class CartModel {
  const CartModel({
    required this.userId,
    this.items = const [],
  });

  final String userId;
  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  /// True if a product is already in the cart.
  bool containsProduct(String productId) =>
      items.any((item) => item.productId == productId);

  /// Get a cart item by product ID.
  CartItem? itemForProduct(String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (_) {
      return null;
    }
  }

  CartModel copyWith({String? userId, List<CartItem>? items}) {
    return CartModel(
      userId: userId ?? this.userId,
      items: items ?? this.items,
    );
  }

  factory CartModel.empty(String userId) => CartModel(userId: userId);

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      userId: json['userId'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'items': items.map((e) => e.toJson()).toList(),
  };
}
