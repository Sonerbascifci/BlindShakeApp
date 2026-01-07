import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:blind_shake/src/features/auth/data/models/app_user.dart';
import 'package:blind_shake/src/features/auth/data/models/auth_state.dart';
import 'package:blind_shake/src/features/auth/data/repositories/auth_repository.dart';
import 'package:blind_shake/src/features/auth/data/services/firebase_auth_service.dart';

part 'auth_providers.g.dart';

/// Provider for Firebase Auth Service
@riverpod
FirebaseAuthService firebaseAuthService(Ref ref) {
  return FirebaseAuthService();
}

/// Provider for Auth Repository
@riverpod
AuthRepository authRepository(Ref ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return AuthRepositoryImpl(authService: authService);
}

/// Provider for current user stream
@riverpod
Stream<AppUser?> authStateStream(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
}

/// Provider for current user (nullable)
@riverpod
AppUser? currentUser(Ref ref) {
  final authState = ref.watch(authStateStreamProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
}

/// Auth State Notifier for managing authentication state and operations
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    // Listen to auth state changes and update accordingly
    ref.listen(authStateStreamProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null) {
            state = AuthState.authenticated(user);
          } else {
            state = const AuthState.unauthenticated();
          }
        },
        loading: () {
          // Only set loading if we're not already in a specific state
          if (state.status == AuthStatus.initial) {
            state = const AuthState.loading();
          }
        },
        error: (error, stackTrace) {
          state = AuthState.error(error.toString());
        },
      );
    });

    return const AuthState.initial();
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      state = const AuthState.loading();
      final repository = ref.read(authRepositoryProvider);
      await repository.signInWithGoogle();
      // State will be updated automatically via authStateStreamProvider listener
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      state = const AuthState.loading();
      final repository = ref.read(authRepositoryProvider);
      await repository.signOut();
      // State will be updated automatically via authStateStreamProvider listener
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      state = const AuthState.loading();
      final repository = ref.read(authRepositoryProvider);
      await repository.deleteAccount();
      // State will be updated automatically via authStateStreamProvider listener
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Clear error state
  void clearError() {
    if (state.hasError) {
      state = const AuthState.unauthenticated();
    }
  }
}