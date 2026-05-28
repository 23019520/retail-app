/// Firestore collection and field name constants.
/// Never use raw strings for collection/field names in service files.
class FirestoreConstants {
  FirestoreConstants._();

  // Collections
  static const String users = 'users';
  static const String businesses = 'businesses';
  static const String products = 'products';
  static const String categories = 'categories';
  static const String orders = 'orders';
  static const String carts = 'carts';
  static const String settings = 'settings';

  // User fields
  static const String uid = 'uid';
  static const String name = 'name';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String role = 'role';
  static const String createdAt = 'createdAt';

  // Product fields
  static const String price = 'price';
  static const String stock = 'stock';
  static const String categoryId = 'categoryId';
  static const String isActive = 'isActive';
  static const String imageUrls = 'imageUrls';

  // Order fields
  static const String userId = 'userId';
  static const String status = 'status';
  static const String total = 'total';
  static const String items = 'items';
  static const String businessId = 'businessId';

  // Roles
  static const String roleCustomer = 'customer';
  static const String roleAdmin = 'admin';

  // Settings document
  static const String configDoc = 'config';
}
