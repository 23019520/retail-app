import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/product_model.dart';
import '../../../core/models/category_model.dart';
import '../../../core/services/product_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/constants/firestore_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/constants/app_constants.dart';

final adminStorageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

// ── All products stream ───────────────────────────────────────────────────────

final adminProductServiceProvider =
    Provider<ProductService>((ref) => ProductService());

final adminProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.watch(adminProductServiceProvider).streamProducts();
});

final adminCategoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  return ref.watch(adminProductServiceProvider).streamCategories();
});

// ── Product form state ────────────────────────────────────────────────────────

class ProductFormState {
  const ProductFormState({
    this.name = '',
    this.description = '',
    this.price = 0,
    this.stock = 0,
    this.categoryId = '',
    this.existingImageUrls = const [],
    this.newImageFiles = const [],
    this.isActive = true,
    this.isLoading = false,
    this.errorMessage,
  });

  final String name;
  final String description;
  final double price;
  final int stock;
  final String categoryId;
  final List<String> existingImageUrls;
  final List<File> newImageFiles;
  final bool isActive;
  final bool isLoading;
  final String? errorMessage;

  bool get hasError => errorMessage != null;

  ProductFormState copyWith({
    String? name,
    String? description,
    double? price,
    int? stock,
    String? categoryId,
    List<String>? existingImageUrls,
    List<File>? newImageFiles,
    bool? isActive,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProductFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      existingImageUrls: existingImageUrls ?? this.existingImageUrls,
      newImageFiles: newImageFiles ?? this.newImageFiles,
      isActive: isActive ?? this.isActive,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  factory ProductFormState.fromProduct(ProductModel p) {
    return ProductFormState(
      name: p.name,
      description: p.description,
      price: p.price,
      stock: p.stock,
      categoryId: p.categoryId,
      existingImageUrls: p.imageUrls,
      isActive: p.isActive,
    );
  }
}

class ProductFormNotifier extends StateNotifier<ProductFormState> {
  ProductFormNotifier(this._ref) : super(const ProductFormState());

  final Ref _ref;

  final _firestore = FirebaseFirestore.instance;

  String get _businessId =>
      dotenv.env['BUSINESS_ID'] ?? AppConstants.defaultBusinessId;

  void loadProduct(ProductModel product) {
    state = ProductFormState.fromProduct(product);
  }

  void reset() => state = const ProductFormState();

  void setName(String v) => state = state.copyWith(name: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setPrice(double v) => state = state.copyWith(price: v);
  void setStock(int v) => state = state.copyWith(stock: v);
  void setCategoryId(String v) => state = state.copyWith(categoryId: v);
  void setIsActive(bool v) => state = state.copyWith(isActive: v);

  void addImageFile(File file) {
    state = state.copyWith(
        newImageFiles: [...state.newImageFiles, file]);
  }

  void removeExistingImage(String url) {
    state = state.copyWith(
      existingImageUrls:
          state.existingImageUrls.where((u) => u != url).toList(),
    );
  }

  void removeNewImage(File file) {
    state = state.copyWith(
      newImageFiles: state.newImageFiles.where((f) => f != file).toList(),
    );
  }

  /// Save (create or update). Returns true on success.
  Future<bool> save({String? existingProductId}) async {
    state = state.copyWith(isLoading: true);

    try {
      final storageService = _ref.read(adminStorageServiceProvider);

      // Upload any new images
      final newUrls = <String>[];
      for (final file in state.newImageFiles) {
        final productId = existingProductId ?? _firestore.collection('products').doc().id;
        final url = await storageService.uploadFile(
          file: file,
          path: 'products/$productId',
        );
        if (url != null) newUrls.add(url);
      }

      final allImageUrls = [...state.existingImageUrls, ...newUrls];

      final data = {
        'name': state.name.trim(),
        'description': state.description.trim(),
        'price': state.price,
        'stock': state.stock,
        'categoryId': state.categoryId,
        'imageUrls': allImageUrls,
        'isActive': state.isActive,
        'businessId': _businessId,
      };

      if (existingProductId != null) {
        // Update
        await _firestore
            .collection(FirestoreConstants.products)
            .doc(existingProductId)
            .update(data);
      } else {
        // Create
        final ref = _firestore.collection(FirestoreConstants.products).doc();
        await ref.set({...data, 'id': ref.id, 'createdAt': FieldValue.serverTimestamp()});
      }

      state = const ProductFormState();
      return true;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: 'Failed to save product.');
      return false;
    }
  }

  /// Delete a product and its images.
  Future<bool> delete(ProductModel product) async {
    state = state.copyWith(isLoading: true);
    try {
      final storageService = _ref.read(adminStorageServiceProvider);
      for (final url in product.imageUrls) {
        await storageService.deleteFile(url);
      }
      await _firestore
          .collection(FirestoreConstants.products)
          .doc(product.id)
          .delete();
      state = const ProductFormState();
      return true;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: 'Failed to delete product.');
      return false;
    }
  }
}

final productFormProvider =
    StateNotifierProvider<ProductFormNotifier, ProductFormState>(
        (ref) => ProductFormNotifier(ref));

// ── Product to edit — shared between management and form screens ──────────────

/// Holds the product being edited. Null = creating a new product.
/// Defined here so both ProductManagementScreen and ProductFormScreen
/// can import it without a private-member export issue.
final productToEditProvider = StateProvider<ProductModel?>((ref) => null);
