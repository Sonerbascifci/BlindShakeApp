import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:blind_shake/src/features/auth/data/models/app_user.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  static const String _usersCollection = 'users';

  /// Get current user as AppUser
  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;

    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'Anonymous',
      photoURL: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with Google
  Future<AppUser?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        throw Exception('Google sign-in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to sign in with Google');
      }

      // Create AppUser object
      final appUser = AppUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'Anonymous',
        photoURL: user.photoURL,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // Save/update user data in Firestore
      await _saveUserToFirestore(appUser);

      debugPrint('Successfully signed in: ${appUser.displayName}');
      return appUser;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      debugPrint('Successfully signed out');
    } catch (e) {
      debugPrint('Sign out error: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user is currently signed in');

      // Delete user data from Firestore
      await _firestore.collection(_usersCollection).doc(user.uid).delete();

      // Delete Firebase Auth account
      await user.delete();

      // Sign out from Google
      await _googleSignIn.signOut();

      debugPrint('Successfully deleted account');
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during account deletion: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      debugPrint('Account deletion error: $e');
      throw Exception('Failed to delete account: $e');
    }
  }

  /// Get user data from Firestore
  Future<AppUser?> getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();

      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      return AppUser.fromJson(data);
    } catch (e) {
      debugPrint('Error getting user from Firestore: $e');
      return null;
    }
  }

  /// Save user data to Firestore
  Future<void> _saveUserToFirestore(AppUser user) async {
    try {
      await _firestore.collection(_usersCollection).doc(user.uid).set(
        user.toJson(),
        SetOptions(merge: true),
      );
      debugPrint('User data saved to Firestore: ${user.uid}');
    } catch (e) {
      debugPrint('Error saving user to Firestore: $e');
      // Don't throw here to avoid breaking the sign-in flow
      // The user will still be authenticated even if Firestore save fails
    }
  }

  /// Handle Firebase Auth exceptions
  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return Exception('An account already exists with a different credential.');
      case 'invalid-credential':
        return Exception('The credential received is malformed or has expired.');
      case 'operation-not-allowed':
        return Exception('Google sign-in is not enabled for this project.');
      case 'user-disabled':
        return Exception('This user account has been disabled.');
      case 'user-not-found':
        return Exception('No user found with this email address.');
      case 'wrong-password':
        return Exception('Incorrect password provided.');
      case 'invalid-email':
        return Exception('The email address is not valid.');
      case 'email-already-in-use':
        return Exception('An account with this email already exists.');
      case 'weak-password':
        return Exception('The password provided is too weak.');
      case 'network-request-failed':
        return Exception('A network error occurred. Please check your connection.');
      case 'too-many-requests':
        return Exception('Too many failed attempts. Please try again later.');
      default:
        return Exception('An authentication error occurred: ${e.message}');
    }
  }
}