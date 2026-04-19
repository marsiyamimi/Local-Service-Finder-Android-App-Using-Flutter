import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _state == AuthState.authenticated;

  AuthController() {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        _currentUser = await _authService.getUserData(user.uid);
        _state = AuthState.authenticated;
      } else {
        _currentUser = null;
        _state = AuthState.unauthenticated;
      }
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e.toString());
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signIn(email: email, password: password);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e.toString());
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = _parseError(e.toString());
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  String _parseError(String error) {
    if (error.contains('email-already-in-use')) {
      return 'Email is already registered.';
    } else if (error.contains('wrong-password') || error.contains('invalid-credential')) {
      return 'Invalid email or password.';
    } else if (error.contains('user-not-found')) {
      return 'No account found with this email.';
    } else if (error.contains('weak-password')) {
      return 'Password should be at least 6 characters.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Check your connection.';
    }
    return 'Something went wrong. Please try again.';
  }
}
