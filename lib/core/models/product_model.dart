import 'package:cloud_firestore/cloud_firestore.dart';

/// Condition grade for used items.
/// Stored in Firestore as a lowercase string matching the enum name.
enum ProductCondition { likeNew, excellent, good, fair }

extension ProductConditionX on ProductCondition {
  String get label {
    switch (this) {
      case ProductCondition.likeNew:   return 'Like New';
      case ProductCondition.excellent: return 'Excellent';
      case ProductCondition.good:      return 'Good';
      case ProductCondition.fair:      return 'Fair';
    }
  }

  static ProductCondition? fromString(String? value) {
    switch (value) {
      case 'likeNew':   return ProductCondition.likeNew;
      case 'excellent': return ProductCondition.excellent;
      case 'good':       return ProductCondition.good;
      case 'fair':       return ProductCondition.fair;
      default:           return null;
    }
  }
}

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
    // ── Resale trust fields ──────────────────────────────────────────────
    // Nullable: only meaningful for electronics/accessories. A category's
    // ProductType determines whether the form collects these at all.
    this.condition,
    this.batteryHealth,
    this.isInspected = false,
    this.returnPolicyDays = 7,
    this.warrantyMonths = 0,
    this.deliveredFrom = '',
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

  // ── Resale trust fields ────────────────────────────────────────────────────

  /// Condition grade. Null for product types that don't track condition
  /// (e.g. brand-new tools).
  final ProductCondition? condition;

  /// Battery health as a fraction 0.0–1.0. Null for non-battery items.
  final double? batteryHealth;

  /// Whether this unit has passed the quality-check inspection.
  final bool isInspected;

  /// Number of days the buyer has to return this item. 0 = no returns.
  final int returnPolicyDays;

  /// Warranty length in months. 0 = no warranty.
  final int warrantyMonths;

  /// Where this specific unit ships from, e.g. "Johannesburg, Gauteng".
  final String deliveredFrom;

  bool get inStock => stock > 0;
  bool get lowStock => stock > 0 && stock <= 5;
  String? get primaryImage => imageUrls.isNotEmpty ? imageUrls.first : null;
  bool get hasReturnPolicy => returnPolicyDays > 0;
  bool get hasWarranty => warrantyMonths > 0;
  bool get hasCondition => condition != null;
  bool get hasBatteryInfo => batteryHealth != null;

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
      condition: ProductConditionX.fromString(json['condition'] as String?),
      batteryHealth: (json['batteryHealth'] as num?)?.toDouble(),
      isInspected: json['isInspected'] as bool? ?? false,
      returnPolicyDays: json['returnPolicyDays'] as int? ?? 7,
      warrantyMonths: json['warrantyMonths'] as int? ?? 0,
      deliveredFrom: json['deliveredFrom'] as String? ?? '',
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
    if (condition != null) 'condition': condition!.name,
    if (batteryHealth != null) 'batteryHealth': batteryHealth,
    'isInspected': isInspected,
    'returnPolicyDays': returnPolicyDays,
    'warrantyMonths': warrantyMonths,
    'deliveredFrom': deliveredFrom,
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
    ProductCondition? condition,
    bool clearCondition = false,
    double? batteryHealth,
    bool clearBatteryHealth = false,
    bool? isInspected,
    int? returnPolicyDays,
    int? warrantyMonths,
    String? deliveredFrom,
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
      condition: clearCondition ? null : (condition ?? this.condition),
      batteryHealth:
          clearBatteryHealth ? null : (batteryHealth ?? this.batteryHealth),
      isInspected: isInspected ?? this.isInspected,
      returnPolicyDays: returnPolicyDays ?? this.returnPolicyDays,
      warrantyMonths: warrantyMonths ?? this.warrantyMonths,
      deliveredFrom: deliveredFrom ?? this.deliveredFrom,
    );
  }
}