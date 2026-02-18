import 'package:amazon_syria/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> signIn(String phone);
  Future<UserEntity> register(String phone, String name, String userType);
  Future<void> signOut();
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;
}
