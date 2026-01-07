/// BlindShake Supabase Auth Repository
/// 
/// Repository layer for authentication
/// Provides a clean interface for auth operations

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blind_shake/src/features/auth/data/services/supabase_auth_service.dart';
import 'package:blind_shake/src/features/auth/data/models/user_model.dart';

class SupabaseAuthRepository {
  final SupabaseAuthService _authService;

  SupabaseAuthRepository({required SupabaseAuthService authService})
      : _authService = authService;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges =>
      _authService.authStateChanges.map((event) => event.session?.user);

  /// Current authenticated user
  User? get currentUser => _authService.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _authService.isSignedIn;

  /// Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final response = await _authService.signInWithGoogle();
      if (response.user != null) {
        return _mapToUserModel(response.user!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Get user profile from database
  Future<UserModel?> getUserProfile() async {
    final profile = await _authService.getUserProfile();
    if (profile == null) return null;

    return UserModel(
      id: profile['id'] as String,
      email: profile['email'] as String?,
      displayName: profile['display_name'] as String?,
      photoUrl: profile['photo_url'] as String?,
      currentMatchId: profile['current_match_id'] as String?,
      stats: profile['stats'] as Map<String, dynamic>?,
    );
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    await _authService.updateUserProfile(
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  /// Map Supabase User to UserModel
  UserModel _mapToUserModel(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.userMetadata?['full_name'] as String? ??
          user.userMetadata?['name'] as String?,
      photoUrl: user.userMetadata?['avatar_url'] as String?,
    );
  }
}
