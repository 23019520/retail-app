import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.iconName = 'grid_view',
    this.sortOrder = 0,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String iconName; // Maps to a Material icon name
  final int sortOrder;
  final bool isActive;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      iconName: json['iconName'] as String? ?? 'grid_view',
      sortOrder: json['sortOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
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
  };

  /// "All" pseudo-category shown as the first chip
  static const CategoryModel all = CategoryModel(
    id: '',
    name: 'All',
    iconName: 'apps',
  );
}
