import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/app_constants.dart';
import '../constants/firestore_constants.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class ProductService {
  ProductService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String get _businessId =>
      dotenv.env['BUSINESS_ID'] ?? AppConstants.defaultBusinessId;

  // ── Collection references ────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection(FirestoreConstants.products);

  CollectionReference<Map<String, dynamic>> get _categories =>
      _firestore.collection(FirestoreConstants.categories);

  // ── Products ─────────────────────────────────────────────────────────────

  /// Live stream of all active products for this business.
  Stream<List<ProductModel>> streamProducts() {
    return _products
        .where(FirestoreConstants.businessId, isEqualTo: _businessId)
        .where(FirestoreConstants.isActive, isEqualTo: true)
        .orderBy(FirestoreConstants.createdAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ProductModel.fromDoc).toList());
  }

  /// Live stream filtered by category.
  Stream<List<ProductModel>> streamProductsByCategory(String categoryId) {
    if (categoryId.isEmpty) return streamProducts();
    return _products
        .where(FirestoreConstants.businessId, isEqualTo: _businessId)
        .where(FirestoreConstants.isActive, isEqualTo: true)
        .where(FirestoreConstants.categoryId, isEqualTo: categoryId)
        .orderBy(FirestoreConstants.createdAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ProductModel.fromDoc).toList());
  }

  /// Fetch a single product by ID.
  Future<ProductModel?> fetchProduct(String productId) async {
    try {
      final doc = await _products.doc(productId).get();
      if (!doc.exists) return null;
      return ProductModel.fromDoc(doc);
    } catch (_) {
      return null;
    }
  }

  /// Fetch featured products — most recent 6 active products.
  Future<List<ProductModel>> fetchFeaturedProducts() async {
    try {
      final snap = await _products
          .where(FirestoreConstants.businessId, isEqualTo: _businessId)
          .where(FirestoreConstants.isActive, isEqualTo: true)
          .orderBy(FirestoreConstants.createdAt, descending: true)
          .limit(6)
          .get();
      return snap.docs.map(ProductModel.fromDoc).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Categories ───────────────────────────────────────────────────────────

  /// Live stream of active categories, sorted by sortOrder.
  Stream<List<CategoryModel>> streamCategories() {
    return _categories
        .where(FirestoreConstants.isActive, isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) => snap.docs.map(CategoryModel.fromDoc).toList());
  }

  // ── Search ────────────────────────────────────────────────────────────────

  /// Client-side search across a pre-fetched product list.
  /// Firestore doesn't support full-text search natively — this is fine for MVP.
  /// For large catalogs (1000+ products), replace with Algolia in a later sprint.
  List<ProductModel> searchProducts(List<ProductModel> products, String query) {
    if (query.trim().isEmpty) return products;
    final q = query.trim().toLowerCase();
    return products.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
    }).toList();
  }
}
