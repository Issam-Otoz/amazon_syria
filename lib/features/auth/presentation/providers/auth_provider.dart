import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:amazon_syria/features/auth/domain/entities/user_entity.dart';
import 'package:amazon_syria/features/auth/domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<UserEntity?>? _authSub;

  AuthProvider(this._repository) {
    init();
  }

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  void init() {
    _authSub?.cancel();
    _authSub = _repository.authStateChanges.listen(
      (user) {
        _currentUser = user;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> signIn(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _repository.signIn(phone);
    } catch (e) {
      _error = _mapError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String phone, String name, String userType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _repository.register(phone, name, userType);
    } catch (e) {
      _error = _mapError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.signOut();
      _currentUser = null;
    } catch (e) {
      _error = _mapError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _mapError(Object e) {
    final msg = e.toString();
    if (msg.contains('user-not-found') || msg.contains('wrong-password')) {
      return 'رقم الهاتف أو كلمة المرور غير صحيحة';
    }
    if (msg.contains('email-already-in-use')) {
      return 'هذا الرقم مسجّل مسبقاً';
    }
    if (msg.contains('network-request-failed')) {
      return 'لا يوجد اتصال بالإنترنت';
    }
    if (msg.contains('invalid-credential')) {
      return 'رقم الهاتف أو كلمة المرور غير صحيحة';
    }
    return 'حدث خطأ غير متوقع، حاول مرة أخرى';
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
