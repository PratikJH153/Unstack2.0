import 'package:flutter/foundation.dart';
import 'package:unstack/logic/user/user_impl.dart';
import 'package:unstack/models/auth/user.model.dart';
import 'package:unstack/utils/app_logger.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final UserManager _userManager = UserManager();

  AuthState _authState = AuthState.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  // Getters
  AuthState get authState => _authState;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  bool get isLoading => _authState == AuthState.loading;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _setAuthState(AuthState.loading);

    try {
      // Check if user is already signed in
      final isLoggedIn = await _userManager.isUserLoggedIn();
      if (isLoggedIn) {
        final user = await _userManager.getUser();
        if (user != null) {
          _currentUser = user;
          _setAuthState(AuthState.authenticated);
          AppLogger.info('User already signed in: ${user.username}');
        } else {
          _setAuthState(AuthState.unauthenticated);
        }
      } else {
        _setAuthState(AuthState.unauthenticated);
      }
    } catch (e) {
      AppLogger.error('Error initializing auth: $e');
      _setError('Failed to initialize authentication');
    }
  }

  Future<bool> signInWithUsername(String username) async {
    _setAuthState(AuthState.loading);

    try {
      // Create and save user
      await _userManager.createUserFromUsername(username);

      // Get the created user
      final user = await _userManager.getUser();
      if (user != null) {
        _currentUser = user;
        _setAuthState(AuthState.authenticated);
        AppLogger.info('User signed in with username: $username');
        return true;
      } else {
        _setError('Failed to create user');
        return false;
      }
    } catch (e) {
      AppLogger.error('Username sign-in error: $e');
      _setError('Sign-in failed: ${e.toString()}');
      return false;
    }
  }

  Future<bool> signOut() async {
    _setAuthState(AuthState.loading);

    try {
      await _userManager.deleteAccount();
      _currentUser = null;
      _setAuthState(AuthState.unauthenticated);
      AppLogger.info('User signed out');
      return true;
    } catch (e) {
      AppLogger.error('Sign out error: $e');
      _setError('Sign out failed: ${e.toString()}');
      return false;
    }
  }

  Future<String?> getUsername() async {
    try {
      return await _userManager.getUsername();
    } catch (e) {
      AppLogger.error('Error getting username: $e');
      return null;
    }
  }

  // Helper methods
  void _setAuthState(AuthState state) {
    _authState = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _authState = AuthState.error;
    notifyListeners();
  }
}
