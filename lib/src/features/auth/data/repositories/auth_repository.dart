import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blind_shake/src/features/auth/data/models/app_user.dart';
import 'package:blind_shake/src/features/auth/data/services/firebase_auth_service.dart';

abstract class AuthRepository {
  /// Get current user
  AppUser? get currentUser;

  /// Stream of auth state changes
  Stream<AppUser?> get authStateChanges;

  /// Sign in with Google
  Future<AppUser> signInWithGoogle();

  /// Sign out
  Future<void> signOut();

  /// Delete account
  Future<void> deleteAccount();

  /// Get user data from remote source
  Future<AppUser?> getUser(String uid);
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;

  AuthRepositoryImpl({
    required FirebaseAuthService authService,
  }) : _authService = authService;

  @override
  AppUser? get currentUser => _authService.currentUser;

  @override
  Stream<AppUser?> get authStateChanges {
    return _authService.authStateChanges.map((User? firebaseUser) {
      if (firebaseUser == null) return null;

      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? 'Anonymous',
        photoURL: firebaseUser.photoURL,
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    });
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) {
        throw Exception('Failed to sign in with Google');
      }
      return user;
    } catch (e) {
      throw Exception('Repository: Failed to sign in with Google - $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw Exception('Repository: Failed to sign out - $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _authService.deleteAccount();
    } catch (e) {
      throw Exception('Repository: Failed to delete account - $e');
    }
  }

  @override
  Future<AppUser?> getUser(String uid) async {
    try {
      return await _authService.getUserFromFirestore(uid);
    } catch (e) {
      throw Exception('Repository: Failed to get user - $e');
    }
  }
}