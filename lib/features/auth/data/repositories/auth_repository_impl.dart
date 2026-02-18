import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:amazon_syria/core/constants/app_constants.dart';
import 'package:amazon_syria/features/auth/domain/entities/user_entity.dart';
import 'package:amazon_syria/features/auth/domain/repositories/auth_repository.dart';
import 'package:amazon_syria/features/auth/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserEntity? _cachedUser;

  String _emailFromPhone(String phone) => '$phone@amazonsyria.app';

  CollectionReference get _usersRef =>
      _firestore.collection(AppConstants.usersCollection);

  @override
  Future<UserEntity?> signIn(String phone) async {
    final email = _emailFromPhone(phone);

    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: phone,
    );

    final uid = credential.user?.uid;
    if (uid == null) return null;

    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;

    _cachedUser = UserModel.fromMap(
      doc.data() as Map<String, dynamic>,
      uid,
    );
    return _cachedUser;
  }

  @override
  Future<UserEntity> register(
    String phone,
    String name,
    String userType,
  ) async {
    final email = _emailFromPhone(phone);

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: phone,
    );

    final uid = credential.user!.uid;

    final user = UserModel(
      id: uid,
      phone: phone,
      name: name,
      userType: userType,
      createdAt: DateTime.now(),
    );

    await _usersRef.doc(uid).set(user.toMap());

    _cachedUser = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    _cachedUser = null;
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        _cachedUser = null;
        return null;
      }

      final doc = await _usersRef.doc(firebaseUser.uid).get();
      if (!doc.exists) {
        _cachedUser = null;
        return null;
      }

      _cachedUser = UserModel.fromMap(
        doc.data() as Map<String, dynamic>,
        firebaseUser.uid,
      );
      return _cachedUser;
    });
  }

  @override
  UserEntity? get currentUser => _cachedUser;
}
