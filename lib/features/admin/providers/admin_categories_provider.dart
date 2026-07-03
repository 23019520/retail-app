import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/category_model.dart';
import '../../../core/constants/firestore_constants.dart';

// ── Category form state ───────────────────────────────────────────────────────

class CategoryFormState {
  const CategoryFormState({
    this.name = '',
    this.iconName = 'grid_view',
    this.sortOrder = 0,
    this.isActive = true,
    this.productType = ProductType.electronics,
    this.isLoading = false,
    this.errorMessage,
  });

  final String name;
  final String iconName;
  final int sortOrder;
  final bool isActive;
  final ProductType productType;
  final bool isLoading;
  final String? errorMessage;

  bool get hasError => errorMessage != null;

  CategoryFormState copyWith({
    String? name,
    String? iconName,
    int? sortOrder,
    bool? isActive,
    ProductType? productType,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CategoryFormState(
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      productType: productType ?? this.productType,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  factory CategoryFormState.fromCategory(CategoryModel c) {
    return CategoryFormState(
      name: c.name,
      iconName: c.iconName,
      sortOrder: c.sortOrder,
      isActive: c.isActive,
      productType: c.productType,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class CategoryFormNotifier extends StateNotifier<CategoryFormState> {
  CategoryFormNotifier() : super(const CategoryFormState());

  final _firestore = FirebaseFirestore.instance;

  void loadCategory(CategoryModel c) {
    state = CategoryFormState.fromCategory(c);
  }

  void reset() => state = const CategoryFormState();

  void setName(String v) => state = state.copyWith(name: v);
  void setIconName(String v) => state = state.copyWith(iconName: v);
  void setSortOrder(int v) => state = state.copyWith(sortOrder: v);
  void setIsActive(bool v) => state = state.copyWith(isActive: v);
  void setProductType(ProductType v) => state = state.copyWith(productType: v);

  Future<bool> save({String? existingId}) async {
    if (state.name.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Category name is required.');
      return false;
    }
    state = state.copyWith(isLoading: true);
    try {
      final col = _firestore.collection(FirestoreConstants.categories);
      final data = {
        'name': state.name.trim(),
        'iconName': state.iconName,
        'sortOrder': state.sortOrder,
        'isActive': state.isActive,
        'productType': state.productType.name,
      };

      if (existingId != null) {
        await col.doc(existingId).update(data);
      } else {
        final doc = col.doc();
        await doc.set({...data, 'id': doc.id});
      }
      state = const CategoryFormState();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save category.',
      );
      return false;
    }
  }

  Future<bool> delete(String categoryId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _firestore
          .collection(FirestoreConstants.categories)
          .doc(categoryId)
          .delete();
      state = const CategoryFormState();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete category.',
      );
      return false;
    }
  }
}

final categoryFormProvider =
    StateNotifierProvider<CategoryFormNotifier, CategoryFormState>(
        (ref) => CategoryFormNotifier());

final categoryToEditProvider = StateProvider<CategoryModel?>((ref) => null);