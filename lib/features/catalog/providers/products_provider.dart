import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/product_model.dart';
import 'categories_provider.dart';
import 'search_provider.dart';

/// All active products, live from Firestore.
final productsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.watch(productServiceProvider).streamProducts();
});

/// Products filtered by selected category AND search query.
/// Derived from productsProvider — zero extra Firestore reads.
final filteredProductsProvider = Provider<AsyncValue<List<ProductModel>>>((ref) {
  final allProducts = ref.watch(productsProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final service = ref.watch(productServiceProvider);

  return allProducts.whenData((products) {
    // Step 1: filter by category
    var filtered = selectedCategory.isEmpty
        ? products
        : products.where((p) => p.categoryId == selectedCategory).toList();

    // Step 2: filter by search query
    filtered = service.searchProducts(filtered, searchQuery);

    return filtered;
  });
});

/// Single product by ID — used by ProductDetailScreen.
final productByIdProvider =
    FutureProvider.family<ProductModel?, String>((ref, productId) {
  return ref.watch(productServiceProvider).fetchProduct(productId);
});

/// Featured products for the home screen — most recent 6.
final featuredProductsProvider = FutureProvider<List<ProductModel>>((ref) {
  return ref.watch(productServiceProvider).fetchFeaturedProducts();
});
