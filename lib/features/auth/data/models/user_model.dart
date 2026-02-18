import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:amazon_syria/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.phone,
    required super.name,
    required super.userType,
    required super.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      phone: map['phone'] as String? ?? '',
      name: map['name'] as String? ?? '',
      userType: map['userType'] as String? ?? 'orderUser',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      phone: entity.phone,
      name: entity.name,
      userType: entity.userType,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'name': name,
      'userType': userType,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
