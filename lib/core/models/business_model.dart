import 'package:flutter/material.dart';

/// BusinessModel drives all branding and config.
/// Loaded from Firestore at startup — nothing business-specific is hardcoded.
class BusinessModel {
  const BusinessModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.primaryColorHex,
    this.secondaryColorHex,
    this.phone,
    this.email,
    this.address,
    this.deliveryFee = 50.0,
    this.freeDeliveryThreshold = 500.0,
    this.currencySymbol = 'R',
    this.isActive = true,
  });

  final String id;
  final String name;
  final String? logoUrl;
  final String? primaryColorHex;    // e.g. "#1A1A2E"
  final String? secondaryColorHex;
  final String? phone;
  final String? email;
  final String? address;
  final double deliveryFee;
  final double freeDeliveryThreshold;
  final String currencySymbol;
  final bool isActive;

  /// Parse hex color string to Color. Falls back to null (theme default).
  Color? get primaryColor => _hexToColor(primaryColorHex);
  Color? get secondaryColor => _hexToColor(secondaryColorHex);

  Color? _hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length != 6) return null;
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'My Store',
      logoUrl: json['logoUrl'] as String?,
      primaryColorHex: json['primaryColor'] as String?,
      secondaryColorHex: json['secondaryColor'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 50.0,
      freeDeliveryThreshold: (json['freeDeliveryThreshold'] as num?)?.toDouble() ?? 500.0,
      currencySymbol: json['currencySymbol'] as String? ?? 'R',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logoUrl': logoUrl,
    'primaryColor': primaryColorHex,
    'secondaryColor': secondaryColorHex,
    'phone': phone,
    'email': email,
    'address': address,
    'deliveryFee': deliveryFee,
    'freeDeliveryThreshold': freeDeliveryThreshold,
    'currencySymbol': currencySymbol,
    'isActive': isActive,
  };

  BusinessModel copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? primaryColorHex,
    String? secondaryColorHex,
    String? phone,
    String? email,
    String? address,
    double? deliveryFee,
    double? freeDeliveryThreshold,
    String? currencySymbol,
    bool? isActive,
  }) {
    return BusinessModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      secondaryColorHex: secondaryColorHex ?? this.secondaryColorHex,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      freeDeliveryThreshold: freeDeliveryThreshold ?? this.freeDeliveryThreshold,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Default/fallback business used before Firestore loads
  static const BusinessModel empty = BusinessModel(
    id: '',
    name: 'My Store',
  );
}
