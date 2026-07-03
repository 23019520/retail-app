import 'package:cloud_firestore/cloud_firestore.dart';

/// Determines which trust fields (condition grade, battery health) apply
/// to products in this category.
///
///  - electronics: full condition + battery (laptops, desktops, tablets)
///  - accessory:   condition grade only, no battery (bags, mice, cables)
///  - tool:        no condition/battery fields at all (screwdrivers, kits)
enum ProductType { electronics, accessory, tool }

extension ProductTypeX on ProductType {
  String get label {
    switch (this) {
      case ProductType.electronics: return 'Electronics';
      case ProductType.accessory:   return 'Accessory';
      case ProductType.tool:        return 'Tool';
    }
  }

  /// Whether this product type shows the battery health slider.
  bool get hasBattery => this == ProductType.electronics;

  /// Whether this product type shows the condition grade selector
  /// and condition meter at all.
  bool get hasCondition =>
      this == ProductType.electronics || this == ProductType.accessory;

  static ProductType fromString(String? value) {
    switch (value) {
      case 'electronics': return ProductType.electronics;
      case 'accessory':   return ProductType.accessory;
      case 'tool':         return ProductType.tool;
      default:             return ProductType.electronics;
    }
  }
}

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.iconName = 'grid_view',
    this.sortOrder = 0,
    this.isActive = true,
    this.productType = ProductType.electronics,
  });

  final String id;
  final String name;
  final String iconName; // Maps to a Material icon name
  final int sortOrder;
  final bool isActive;

  /// Determines which trust fields apply to products in this category.
  final ProductType productType;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      iconName: json['iconName'] as String? ?? 'grid_view',
      sortOrder: json['sortOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      productType: ProductTypeX.fromString(json['productType'] as String?),
    );
  }

  factory CategoryModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconName': iconName,
    'sortOrder': sortOrder,
    'isActive': isActive,
    'productType': productType.name,
  };

  /// "All" pseudo-category shown as the first chip
  static const CategoryModel all = CategoryModel(
    id: '',
    name: 'All',
    iconName: 'apps',
  );
}