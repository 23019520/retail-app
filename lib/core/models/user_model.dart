import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles stored as a string in Firestore.
/// Checked on the auth token claim for admin access.
enum UserRole { customer, admin }

extension UserRoleX on UserRole {
  String get value => name; // 'customer' | 'admin'
  static UserRole fromString(String? s) =>
      s == 'admin' ? UserRole.admin : UserRole.customer;
}

class UserModel {
  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.role = UserRole.customer,
    this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final UserRole role;
  final DateTime? createdAt;

  bool get isAdmin => role == UserRole.admin;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      role: UserRoleX.fromString(json['role'] as String?),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'role': role.value,
    'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
  };

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? address,
    UserRole? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
