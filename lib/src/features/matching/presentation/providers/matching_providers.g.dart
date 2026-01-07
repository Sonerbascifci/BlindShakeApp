// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matching_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$locationServiceHash() => r'38d15292e1d1d4553c8f07a36b00411aa0a8d30e';

/// Provider for Location Service
///
/// Copied from [locationService].
@ProviderFor(locationService)
final locationServiceProvider = AutoDisposeProvider<LocationService>.internal(
  locationService,
  name: r'locationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationServiceRef = AutoDisposeProviderRef<LocationService>;
String _$shakeDetectionServiceHash() =>
    r'a306b6447370c8a6a0b8f9eadb08c0681ba78b96';

/// Provider for Shake Detection Service
///
/// Copied from [shakeDetectionService].
@ProviderFor(shakeDetectionService)
final shakeDetectionServiceProvider =
    AutoDisposeProvider<ShakeDetectionService>.internal(
      shakeDetectionService,
      name: r'shakeDetectionServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$shakeDetectionServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShakeDetectionServiceRef =
    AutoDisposeProviderRef<ShakeDetectionService>;
String _$appSetupServiceHash() => r'd4e838e96745b1a65cff9c0cee6781618719fb4d';

/// Provider for App Setup Service
///
/// Copied from [appSetupService].
@ProviderFor(appSetupService)
final appSetupServiceProvider = AutoDisposeProvider<AppSetupService>.internal(
  appSetupService,
  name: r'appSetupServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appSetupServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppSetupServiceRef = AutoDisposeProviderRef<AppSetupService>;
String _$matchingServiceHash() => r'a6ce6240ea799c30e279d01f80eb2168edd0f9e2';

/// Provider for Matching Service
///
/// Copied from [matchingService].
@ProviderFor(matchingService)
final matchingServiceProvider = AutoDisposeProvider<MatchingService>.internal(
  matchingService,
  name: r'matchingServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$matchingServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MatchingServiceRef = AutoDisposeProviderRef<MatchingService>;
String _$matchingEventsHash() => r'1c5c9dbc15f462341001d8e226543f3583ae11a3';

/// Provider for matching events stream
///
/// Copied from [matchingEvents].
@ProviderFor(matchingEvents)
final matchingEventsProvider =
    AutoDisposeStreamProvider<MatchingEvent>.internal(
      matchingEvents,
      name: r'matchingEventsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$matchingEventsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MatchingEventsRef = AutoDisposeStreamProviderRef<MatchingEvent>;
String _$shakeEventsHash() => r'd18002c44407a6a0266231a5b27a49bda5d63449';

/// Provider for shake events stream
///
/// Copied from [shakeEvents].
@ProviderFor(shakeEvents)
final shakeEventsProvider = AutoDisposeStreamProvider<ShakeEvent>.internal(
  shakeEvents,
  name: r'shakeEventsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shakeEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShakeEventsRef = AutoDisposeStreamProviderRef<ShakeEvent>;
String _$appSetupStateStreamHash() =>
    r'142cdbc7295f21a48036de7e159e999e6df4afc7';

/// Provider for app setup state stream
///
/// Copied from [appSetupStateStream].
@ProviderFor(appSetupStateStream)
final appSetupStateStreamProvider =
    AutoDisposeStreamProvider<AppSetupState>.internal(
      appSetupStateStream,
      name: r'appSetupStateStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appSetupStateStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppSetupStateStreamRef = AutoDisposeStreamProviderRef<AppSetupState>;
String _$locationPermissionNotifierHash() =>
    r'7ec04895d826454a354e72aa7b2a4e5d9efcb751';

/// Provider for location permission status
///
/// Copied from [LocationPermissionNotifier].
@ProviderFor(LocationPermissionNotifier)
final locationPermissionNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      LocationPermissionNotifier,
      LocationPermissionStatus
    >.internal(
      LocationPermissionNotifier.new,
      name: r'locationPermissionNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$locationPermissionNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LocationPermissionNotifier =
    AutoDisposeAsyncNotifier<LocationPermissionStatus>;
String _$currentLocationNotifierHash() =>
    r'7a51c94fbccf796eb35d06e54bfb08104da741e1';

/// Provider for current location
///
/// Copied from [CurrentLocationNotifier].
@ProviderFor(CurrentLocationNotifier)
final currentLocationNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      CurrentLocationNotifier,
      AppLocation?
    >.internal(
      CurrentLocationNotifier.new,
      name: r'currentLocationNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentLocationNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentLocationNotifier = AutoDisposeAsyncNotifier<AppLocation?>;
String _$matchingNotifierHash() => r'763ee79df8ef187fb269be3314813645e29759ba';

/// Provider for matching state
///
/// Copied from [MatchingNotifier].
@ProviderFor(MatchingNotifier)
final matchingNotifierProvider =
    AutoDisposeNotifierProvider<MatchingNotifier, MatchingState>.internal(
      MatchingNotifier.new,
      name: r'matchingNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$matchingNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MatchingNotifier = AutoDisposeNotifier<MatchingState>;
String _$currentMatchNotifierHash() =>
    r'521b4283afc6e31607cec8c4c2bbf9960a1c0992';

/// Provider for current match result
///
/// Copied from [CurrentMatchNotifier].
@ProviderFor(CurrentMatchNotifier)
final currentMatchNotifierProvider =
    AutoDisposeNotifierProvider<CurrentMatchNotifier, MatchResult?>.internal(
      CurrentMatchNotifier.new,
      name: r'currentMatchNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentMatchNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentMatchNotifier = AutoDisposeNotifier<MatchResult?>;
String _$matchingErrorNotifierHash() =>
    r'eed2348a8729d3c9b5a22f531ddcd0c580b7dcaf';

/// Provider for matching error state
///
/// Copied from [MatchingErrorNotifier].
@ProviderFor(MatchingErrorNotifier)
final matchingErrorNotifierProvider =
    AutoDisposeNotifierProvider<MatchingErrorNotifier, String?>.internal(
      MatchingErrorNotifier.new,
      name: r'matchingErrorNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$matchingErrorNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MatchingErrorNotifier = AutoDisposeNotifier<String?>;
String _$matchingStatusNotifierHash() =>
    r'14f2abc4d247536596f71747ae8c3ab407c1d4fb';

/// Provider for comprehensive matching status
///
/// Copied from [MatchingStatusNotifier].
@ProviderFor(MatchingStatusNotifier)
final matchingStatusNotifierProvider =
    AutoDisposeNotifierProvider<
      MatchingStatusNotifier,
      MatchingStatus
    >.internal(
      MatchingStatusNotifier.new,
      name: r'matchingStatusNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$matchingStatusNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MatchingStatusNotifier = AutoDisposeNotifier<MatchingStatus>;
String _$locationServiceStatusNotifierHash() =>
    r'30fd4fc89a12254e979719fecd77b5055e3a26e5';

/// Provider for location service enabled status
///
/// Copied from [LocationServiceStatusNotifier].
@ProviderFor(LocationServiceStatusNotifier)
final locationServiceStatusNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      LocationServiceStatusNotifier,
      bool
    >.internal(
      LocationServiceStatusNotifier.new,
      name: r'locationServiceStatusNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$locationServiceStatusNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LocationServiceStatusNotifier = AutoDisposeAsyncNotifier<bool>;
String _$matchingControllerNotifierHash() =>
    r'e3dfc68e3e74996cd91d4c71590aea3201615549';

/// Provider for unified matching controller
///
/// Copied from [MatchingControllerNotifier].
@ProviderFor(MatchingControllerNotifier)
final matchingControllerNotifierProvider =
    AutoDisposeAsyncNotifierProvider<MatchingControllerNotifier, void>.internal(
      MatchingControllerNotifier.new,
      name: r'matchingControllerNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$matchingControllerNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MatchingControllerNotifier = AutoDisposeAsyncNotifier<void>;
String _$appSetupNotifierHash() => r'60ad0cd15ba167705ef8eaa6d40b6a4d3dc28a70';

/// Provider for app setup notifier
///
/// Copied from [AppSetupNotifier].
@ProviderFor(AppSetupNotifier)
final appSetupNotifierProvider =
    AutoDisposeNotifierProvider<AppSetupNotifier, AppSetupState>.internal(
      AppSetupNotifier.new,
      name: r'appSetupNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appSetupNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AppSetupNotifier = AutoDisposeNotifier<AppSetupState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
