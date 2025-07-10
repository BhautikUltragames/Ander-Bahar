import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    init();
  }
  GoogleSignInAccount? _user;
  bool _isInitialized = false;
  bool _isSigningIn = false;
  String _errorMessage = '';

  // Getters
  GoogleSignInAccount? get user => _user;
  bool get isSignedIn => _user != null;
  bool get isInitialized => _isInitialized;
  bool get isSigningIn => _isSigningIn;
  String get errorMessage => _errorMessage;
  String get userDisplayName => _user?.displayName ?? 'Guest';
  String get userEmail => _user?.email ?? '';
  String get userPhotoUrl => _user?.photoUrl ?? '';
  String get userId => _user?.id ?? '';

  // Initialize auth provider
  Future<void> init() async {
    try {
      await AuthService.init();
      _user = AuthService.currentUser;
      _isInitialized = true;
      notifyListeners();
      
      // Listen to auth state changes
      AuthService.onCurrentUserChanged.listen((GoogleSignInAccount? user) {
        _user = user;
        notifyListeners();
      });
    } catch (error) {
      _errorMessage = error.toString();
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _isSigningIn = true;
      _errorMessage = '';
      notifyListeners();

      final GoogleSignInAccount? account = await AuthService.signInWithGoogle();
      
      if (account != null) {
        _user = account;
        _isSigningIn = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Sign in was cancelled';
        _isSigningIn = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = error.toString();
      _isSigningIn = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await AuthService.signOut();
      _user = null;
      _errorMessage = '';
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
} 