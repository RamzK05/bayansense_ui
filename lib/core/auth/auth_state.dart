import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../api/api_client.dart';

class AuthState extends ChangeNotifier {
  static final AuthState _instance = AuthState._internal();
  factory AuthState() => _instance;
  AuthState._internal();

  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  UserRole? get userRole => _currentUser?.role;

  /// Call this when login or registration succeeds
  void login(User user) {
    _currentUser = user;
    if (user.token != null) {
      ApiClient().setAuthToken(user.token);
    }
    notifyListeners();
  }

  /// Call this when signing out
  void logout() {
    _currentUser = null;
    ApiClient().clearAuthToken();
    notifyListeners();
  }
}
