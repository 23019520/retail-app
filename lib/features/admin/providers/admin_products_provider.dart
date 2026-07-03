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
    // ── Resale trust fields ──────────────────────────────────────────────
    this.condition,
    this.batteryHealth,
    this.isInspected = false,
    this.returnPolicyDays = 7,
    this.warrantyMonths = 0,
    this.deliveredFrom = '',
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

  // ── Resale trust fields ────────────────────────────────────────────────────
  final ProductCondition? condition;
  final double? batteryHealth;
  final bool isInspected;
  final int returnPolicyDays;
  final int warrantyMonths;
  final String deliveredFrom;

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
    ProductCondition? condition,
    bool clearCondition = false,
    double? batteryHealth,
    bool clearBatteryHealth = false,
    bool? isInspected,
    int? returnPolicyDays,
    int? warrantyMonths,
    String? deliveredFrom,
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
      condition: clearCondition ? null : (condition ?? this.condition),
      batteryHealth:
          clearBatteryHealth ? null : (batteryHealth ?? this.batteryHealth),
      isInspected: isInspected ?? this.isInspected,
      returnPolicyDays: returnPolicyDays ?? this.returnPolicyDays,
      warrantyMonths: warrantyMonths ?? this.warrantyMonths,
      deliveredFrom: deliveredFrom ?? this.deliveredFrom,
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
      condition: p.condition,
      batteryHealth: p.batteryHealth,
      isInspected: p.isInspected,
      returnPolicyDays: p.returnPolicyDays,
      warrantyMonths: p.warrantyMonths,
      deliveredFrom: p.deliveredFrom,
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

  // ── Resale trust field setters ────────────────────────────────────────────
  void setCondition(ProductCondition v) => state = state.copyWith(condition: v);
  void clearCondition() => state = state.copyWith(clearCondition: true);

  void setBatteryHealth(double v) => state = state.copyWith(batteryHealth: v);
  void clearBatteryHealth() => state = state.copyWith(clearBatteryHealth: true);

  void setIsInspected(bool v) => state = state.copyWith(isInspected: v);
  void setReturnPolicyDays(int v) => state = state.copyWith(returnPolicyDays: v);
  void setWarrantyMonths(int v) => state = state.copyWith(warrantyMonths: v);
  void setDeliveredFrom(String v) => state = state.copyWith(deliveredFrom: v);

  void addImageFile(File file) {
    state = state.copyWith(newImageFiles: [...state.newImageFiles, file]);
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

      // Lock in ONE product ID upfront so Storage path and Firestore doc match
      final productId = existingProductId ??
          _firestore.collection(FirestoreConstants.products).doc().id;

      // Upload any new images
      final newUrls = <String>[];
      for (final file in state.newImageFiles) {
        final url = await storageService.uploadFile(
          file: file,
          path: 'products/$productId',
        );
        if (url != null) newUrls.add(url);
      }

      final allImageUrls = [...state.existingImageUrls, ...newUrls];

      final data = <String, dynamic>{
        'name': state.name.trim(),
        'description': state.description.trim(),
        'price': state.price,
        'stock': state.stock,
        'categoryId': state.categoryId,
        'imageUrls': allImageUrls,
        'isActive': state.isActive,
        'businessId': _businessId,
        // ── Resale trust fields ──────────────────────────────────────────
        'condition': state.condition?.name,
        'batteryHealth': state.batteryHealth,
        'isInspected': state.isInspected,
        'returnPolicyDays': state.returnPolicyDays,
        'warrantyMonths': state.warrantyMonths,
        'deliveredFrom': state.deliveredFrom.trim(),
      };

      if (existingProductId != null) {
        // Use FieldValue.delete() so switching a product to a type without
        // condition/battery actually clears the old values in Firestore,
        // rather than leaving stale data behind.
        if (state.condition == null) {
          data['condition'] = FieldValue.delete();
        }
        if (state.batteryHealth == null) {
          data['batteryHealth'] = FieldValue.delete();
        }
        await _firestore
            .collection(FirestoreConstants.products)
            .doc(productId)
            .update(data);
      } else {
        // Create new — strip nulls instead of writing FieldValue.delete()
        // (delete() is only valid on update(), not set()).
        data.removeWhere((key, value) => value == null);
        await _firestore
            .collection(FirestoreConstants.products)
            .doc(productId)
            .set({
          ...data,
          'id': productId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      state = const ProductFormState();
      return true;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: 'Failed to save product.');
      return false;
    }
  }

  /// Delete a product and all its Storage images.
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

// ── Product to edit ───────────────────────────────────────────────────────────

/// Holds the product being edited. Null = creating a new product.
final productToEditProvider = StateProvider<ProductModel?>((ref) => null);