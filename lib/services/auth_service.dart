import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static GoogleSignInAccount? _currentUser;

  // Initialize the auth service
  static Future<void> init() async {
    try {
      // Check if user is already signed in
      _currentUser = await _googleSignIn.signInSilently();
      print('Auth Service initialized. Current user: ${_currentUser?.displayName}');
    } catch (error) {
      print('Error initializing auth service: $error');
    }
  }

  // Sign in with Google
  static Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        _currentUser = account;
        
        // Save user data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', account.id);
        await prefs.setString('user_name', account.displayName ?? '');
        await prefs.setString('user_email', account.email);
        await prefs.setString('user_photo', account.photoUrl ?? '');
        
        print('User signed in: ${account.displayName}');
        return account;
      }
    } catch (error) {
      print('Error signing in with Google: $error');
    }
    return null;
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      
      // Clear user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('user_photo');
      
      print('User signed out');
    } catch (error) {
      print('Error signing out: $error');
    }
  }

  // Get current user
  static GoogleSignInAccount? get currentUser => _currentUser;

  // Check if user is signed in
  static bool get isSignedIn => _currentUser != null;

  // Get user display name
  static String get userDisplayName => _currentUser?.displayName ?? 'Guest';

  // Get user email
  static String get userEmail => _currentUser?.email ?? '';

  // Get user photo URL
  static String get userPhotoUrl => _currentUser?.photoUrl ?? '';

  // Get user ID
  static String get userId => _currentUser?.id ?? '';

  // Listen to sign in state changes
  static Stream<GoogleSignInAccount?> get onCurrentUserChanged => _googleSignIn.onCurrentUserChanged;
} 