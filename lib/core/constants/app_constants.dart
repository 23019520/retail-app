/// Global app-wide constants.
/// Nothing business-specific lives here — that goes in BusinessModel.
class AppConstants {
  AppConstants._();

  // App identity
  static const String appName = 'Retail App';
  static const String appVersion = '1.0.0';

  // Default business ID — loaded from .env in production
  static const String defaultBusinessId = 'default';

  // Pagination
  static const int productsPageSize = 20;
  static const int ordersPageSize = 30;

  // Image
  static const int maxImageSizeBytes = 2 * 1024 * 1024; // 2 MB
  static const int imageQuality = 80;

  // Cart
  static const int maxCartQuantity = 99;

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 15);

  // Delivery
  static const double defaultDeliveryFee = 50.0;
  static const double freeDeliveryThreshold = 500.0;
}
