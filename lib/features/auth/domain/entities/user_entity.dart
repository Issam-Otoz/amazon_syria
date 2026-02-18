class UserEntity {
  final String id;
  final String phone;
  final String name;
  final String userType;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.phone,
    required this.name,
    required this.userType,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? id,
    String? phone,
    String? name,
    String? userType,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          phone == other.phone &&
          name == other.name &&
          userType == other.userType &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      phone.hashCode ^
      name.hashCode ^
      userType.hashCode ^
      createdAt.hashCode;

  @override
  String toString() =>
      'UserEntity(id: $id, phone: $phone, name: $name, userType: $userType)';
}
