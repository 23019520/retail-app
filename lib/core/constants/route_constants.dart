/// All route paths and names in one place.
/// Import this wherever you use go_router — never hardcode path strings.
class RouteConstants {
  RouteConstants._();

  // --- Customer routes ---
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  static const String home = '/home';
  static const String productList = '/products';
  static const String productDetail = '/products/:productId';

  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';

  static const String orderHistory = '/orders';
  static const String orderDetail = '/orders/:orderId';

  static const String profile = '/profile';

  // --- Admin routes ---
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminProducts = '/admin/products';
  static const String adminProductForm = '/admin/products/form';
  static const String adminOrders = '/admin/orders';
  static const String adminOrderDetail = '/admin/orders/:orderId';
  static const String adminSettings = '/admin/settings';
}
