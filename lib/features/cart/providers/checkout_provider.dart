import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/order_service.dart';
import '../../auth/providers/auth_provider.dart';
import 'cart_provider.dart';

final orderServiceProvider = Provider<OrderService>((ref) => OrderService());

// ── Checkout form state ────────────────────────────────────────────────────

class CheckoutState {
  const CheckoutState({
    this.deliveryMethod = DeliveryMethod.delivery,
    this.paymentMethod = PaymentMethod.cash,
    this.street = '',
    this.city = '',
    this.postalCode = '',
    this.notes = '',
    this.isLoading = false,
    this.errorMessage,
  });

  final DeliveryMethod deliveryMethod;
  final PaymentMethod paymentMethod;
  final String street;
  final String city;
  final String postalCode;
  final String notes;
  final bool isLoading;
  final String? errorMessage;

  bool get hasError => errorMessage != null;

  bool get addressRequired => deliveryMethod == DeliveryMethod.delivery;

  bool get addressComplete =>
      !addressRequired ||
      (street.trim().isNotEmpty &&
          city.trim().isNotEmpty &&
          postalCode.trim().isNotEmpty);

  String get fullAddress => '$street, $city, $postalCode';

  double get deliveryFee {
    if (deliveryMethod == DeliveryMethod.pickup) return 0;
    return double.tryParse(
            dotenv.env['DELIVERY_FEE'] ?? '') ??
        AppConstants.defaultDeliveryFee;
  }

  CheckoutState copyWith({
    DeliveryMethod? deliveryMethod,
    PaymentMethod? paymentMethod,
    String? street,
    String? city,
    String? postalCode,
    String? notes,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CheckoutState(
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      street: street ?? this.street,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier(this._ref) : super(const CheckoutState());

  final Ref _ref;

  void setDeliveryMethod(DeliveryMethod method) =>
      state = state.copyWith(deliveryMethod: method);

  void setPaymentMethod(PaymentMethod method) =>
      state = state.copyWith(paymentMethod: method);

  void setStreet(String v) => state = state.copyWith(street: v);
  void setCity(String v) => state = state.copyWith(city: v);
  void setPostalCode(String v) => state = state.copyWith(postalCode: v);
  void setNotes(String v) => state = state.copyWith(notes: v);
  void clearError() => state = state.copyWith(errorMessage: null);

  /// Validates, creates the order, clears the cart, returns order ID or null.
  Future<String?> submitOrder() async {
    if (!state.addressComplete) {
      state = state.copyWith(
          errorMessage: 'Please fill in your delivery address.');
      return null;
    }

    state = state.copyWith(isLoading: true);

    try {
      final user = _ref.read(currentFirebaseUserProvider);
      if (user == null) {
        state = state.copyWith(
            isLoading: false, errorMessage: 'You must be signed in.');
        return null;
      }

      final cart = _ref.read(cartProvider).value;
      if (cart == null || cart.isEmpty) {
        state = state.copyWith(
            isLoading: false, errorMessage: 'Your cart is empty.');
        return null;
      }

      final orderId = await _ref.read(orderServiceProvider).createOrder(
            userId: user.uid,
            cart: cart,
            deliveryMethod: state.deliveryMethod,
            paymentMethod: state.paymentMethod,
            deliveryFee: state.deliveryFee,
            deliveryAddress:
                state.addressRequired ? state.fullAddress : null,
            notes: state.notes.trim().isNotEmpty ? state.notes.trim() : null,
          );

      // Clear the cart after successful order
      await _ref.read(cartNotifierProvider.notifier).clearCart();

      state = const CheckoutState(); // reset form
      return orderId;
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          errorMessage: 'Order failed. Please try again.');
      return null;
    }
  }
}

final checkoutProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>(
        (ref) => CheckoutNotifier(ref));
