/// BlindShake Supabase Auth Service
/// 
/// Handles authentication with Supabase Auth
/// Replaces Firebase Auth Service
/// Supports Google Sign-In via OAuth

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SupabaseAuthService {
  final SupabaseClient _client;
  final GoogleSignIn _googleSignIn;

  SupabaseAuthService({
    required SupabaseClient client,
    GoogleSignIn? googleSignIn,
  })  : _client = client,
        _googleSignIn = googleSignIn ?? GoogleSignIn(
          scopes: ['email', 'profile'],
        );

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Get current session
  Session? get currentSession => _client.auth.currentSession;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Sign in with Google using native Google Sign-In
  /// This provides a better UX than web OAuth redirect
  Future<AuthResponse> signInWithGoogle() async {
    // Start native Google Sign-In flow
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw const AuthException('Google sign-in was cancelled');
    }

    // Get auth tokens
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw const AuthException('Failed to get Google ID token');
    }

    // Sign in to Supabase with Google OAuth
    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    return response;
  }

  /// Sign out from both Supabase and Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _client.auth.signOut();
  }

  /// Get user profile from Supabase
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;

    final response = await _client
        .from('users')
        .select()
        .eq('id', currentUser!.id)
        .maybeSingle();

    return response;
  }

  /// Update user profile in Supabase
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    if (currentUser == null) throw const AuthException('User not signed in');

    await _client.from('users').update({
      if (displayName != null) 'display_name': displayName,
      if (photoUrl != null) 'photo_url': photoUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', currentUser!.id);
  }
}
