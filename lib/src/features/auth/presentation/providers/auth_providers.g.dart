// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseAuthServiceHash() =>
    r'5b8afeb2ee48dd318a224972ba814148af29a18c';

/// Provider for Firebase Auth Service
///
/// Copied from [firebaseAuthService].
@ProviderFor(firebaseAuthService)
final firebaseAuthServiceProvider =
    AutoDisposeProvider<FirebaseAuthService>.internal(
      firebaseAuthService,
      name: r'firebaseAuthServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$firebaseAuthServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseAuthServiceRef = AutoDisposeProviderRef<FirebaseAuthService>;
String _$authRepositoryHash() => r'54759410dbb05046f2d03d057d73d4db99db59cc';

/// Provider for Auth Repository
///
/// Copied from [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$authStateStreamHash() => r'01c99aff2024dc6162572a0d6331e6dfe8ad3d71';

/// Provider for current user stream
///
/// Copied from [authStateStream].
@ProviderFor(authStateStream)
final authStateStreamProvider = AutoDisposeStreamProvider<AppUser?>.internal(
  authStateStream,
  name: r'authStateStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateStreamRef = AutoDisposeStreamProviderRef<AppUser?>;
String _$currentUserHash() => r'a39cac68fc1d30d5af564837228f31b42606796c';

/// Provider for current user (nullable)
///
/// Copied from [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<AppUser?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeProviderRef<AppUser?>;
String _$authNotifierHash() => r'9eee0138db1303ca4f2ca7c6c85fb58e3c04c21c';

/// Auth State Notifier for managing authentication state and operations
///
/// Copied from [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AutoDisposeNotifierProvider<AuthNotifier, AuthState>.internal(
      AuthNotifier.new,
      name: r'authNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthNotifier = AutoDisposeNotifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
