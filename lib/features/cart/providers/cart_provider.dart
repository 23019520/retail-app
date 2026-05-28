import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/cart_model.dart';
import '../../../core/models/product_model.dart';
import '../../../core/services/cart_service.dart';
import '../../auth/providers/auth_provider.dart';

final cartServiceProvider = Provider<CartService>((ref) => CartService());

/// Live cart stream — automatically scoped to the signed-in user.
final cartProvider = StreamProvider<CartModel>((ref) {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(cartServiceProvider).streamCart(user.uid);
});

/// Total item count — used for the cart badge on the nav bar.
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).value?.itemCount ?? 0;
});

/// Cart mutation actions — called from UI.
class CartNotifier extends StateNotifier<bool> {
  CartNotifier(this._ref) : super(false);

  final Ref _ref;

  CartService get _service => _ref.read(cartServiceProvider);

  CartModel get _cart =>
      _ref.read(cartProvider).value ??
      CartModel.empty(_ref.read(currentFirebaseUserProvider)?.uid ?? '');

  Future<void> addProduct(ProductModel product) async {
    state = true;
    try {
      await _service.addItem(_cart, product);
    } finally {
      state = false;
    }
  }

  Future<void> removeItem(String productId) async {
    state = true;
    try {
      await _service.removeItem(_cart, productId);
    } finally {
      state = false;
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    await _service.updateQuantity(_cart, productId, quantity);
  }

  Future<void> clearCart() async {
    final userId = _ref.read(currentFirebaseUserProvider)?.uid ?? '';
    await _service.clearCart(userId);
  }
}

/// isLoading = cart mutation in progress (adding/removing).
final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, bool>((ref) => CartNotifier(ref));
