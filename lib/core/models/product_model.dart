import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.description = '',
    this.stock = 0,
    this.categoryId = '',
    this.imageUrls = const [],
    this.isActive = true,
    this.businessId = '',
    this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String categoryId;
  final List<String> imageUrls;
  final bool isActive;
  final String businessId;
  final DateTime? createdAt;

  bool get inStock => stock > 0;
  bool get lowStock => stock > 0 && stock <= 5;
  String? get primaryImage => imageUrls.isNotEmpty ? imageUrls.first : null;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] as int? ?? 0,
      categoryId: json['categoryId'] as String? ?? '',
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
      isActive: json['isActive'] as bool? ?? true,
      businessId: json['businessId'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory ProductModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'stock': stock,
    'categoryId': categoryId,
    'imageUrls': imageUrls,
    'isActive': isActive,
    'businessId': businessId,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? categoryId,
    List<String>? imageUrls,
    bool? isActive,
    String? businessId,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      imageUrls: imageUrls ?? this.imageUrls,
      isActive: isActive ?? this.isActive,
      businessId: businessId ?? this.businessId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
