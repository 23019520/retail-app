import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/category_model.dart';
import '../../../core/services/product_service.dart';

final productServiceProvider = Provider<ProductService>((ref) => ProductService());

/// Live stream of categories from Firestore.
final categoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  return ref.watch(productServiceProvider).streamCategories();
});

/// The currently selected category ID. Empty string = All.
final selectedCategoryProvider = StateProvider<String>((ref) => '');
