import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_constants.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

/// CartService syncs the cart to Firestore in real time.
/// The cart document ID equals the user's UID — one cart per user.
/// The entire cart is written as a single document to keep reads minimal.
class CartService {
  CartService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _cartDoc(String userId) =>
      _firestore.collection(FirestoreConstants.carts).doc(userId);

  // ── Read ─────────────────────────────────────────────────────────────────

  /// Stream the user's cart. Emits CartModel.empty on first load.
  Stream<CartModel> streamCart(String userId) {
    return _cartDoc(userId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return CartModel.empty(userId);
      }
      return CartModel.fromJson(snap.data()!);
    });
  }

  // ── Write helpers ─────────────────────────────────────────────────────────

  Future<void> _saveCart(CartModel cart) async {
    await _cartDoc(cart.userId).set(cart.toJson());
  }

  // ── Mutations — all return the updated CartModel ─────────────────────────

  Future<CartModel> addItem(CartModel cart, ProductModel product) async {
    final existing = cart.itemForProduct(product.id);
    List<CartItem> updated;

    if (existing != null) {
      // Increment quantity, respect stock ceiling
      final newQty = (existing.quantity + 1).clamp(1, product.stock);
      updated = cart.items
          .map((item) => item.productId == product.id
              ? item.copyWith(quantity: newQty)
              : item)
          .toList();
    } else {
      updated = [...cart.items, CartItem.fromProduct(product)];
    }

    final newCart = cart.copyWith(items: updated);
    await _saveCart(newCart);
    return newCart;
  }

  Future<CartModel> removeItem(CartModel cart, String productId) async {
    final updated =
        cart.items.where((item) => item.productId != productId).toList();
    final newCart = cart.copyWith(items: updated);
    await _saveCart(newCart);
    return newCart;
  }

  Future<CartModel> updateQuantity(
      CartModel cart, String productId, int quantity) async {
    if (quantity <= 0) return removeItem(cart, productId);

    final updated = cart.items
        .map((item) => item.productId == productId
            ? item.copyWith(quantity: quantity.clamp(1, item.maxStock))
            : item)
        .toList();

    final newCart = cart.copyWith(items: updated);
    await _saveCart(newCart);
    return newCart;
  }

  Future<CartModel> clearCart(String userId) async {
    final empty = CartModel.empty(userId);
    await _saveCart(empty);
    return empty;
  }
}
