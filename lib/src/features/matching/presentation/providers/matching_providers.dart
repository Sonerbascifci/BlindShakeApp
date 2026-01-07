import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:blind_shake/src/core/services/location_service.dart';
import 'package:blind_shake/src/core/services/shake_detection_service.dart';
import 'package:blind_shake/src/core/services/app_setup_service.dart';
import 'package:blind_shake/src/features/matching/data/services/matching_service.dart';

part 'matching_providers.g.dart';

/// Provider for Location Service
@riverpod
LocationService locationService(Ref ref) {
  return LocationService();
}

/// Provider for Shake Detection Service
@riverpod
ShakeDetectionService shakeDetectionService(Ref ref) {
  return ShakeDetectionService();
}

/// Provider for App Setup Service
@riverpod
AppSetupService appSetupService(Ref ref) {
  final service = AppSetupService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// Provider for Matching Service
@riverpod
MatchingService matchingService(Ref ref) {
  return MatchingService();
}

/// Provider for location permission status
@riverpod
class LocationPermissionNotifier extends _$LocationPermissionNotifier {
  @override
  Future<LocationPermissionStatus> build() async {
    final service = ref.watch(locationServiceProvider);
    return await service.getPermissionStatus();
  }

  /// Request location permission
  Future<void> requestPermission() async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(locationServiceProvider);
      final status = await service.requestPermission();
      state = AsyncValue.data(status);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Open location settings
  Future<void> openSettings() async {
    try {
      final service = ref.read(locationServiceProvider);
      await service.openLocationSettings();
      // Refresh permission status after returning from settings
      build();
    } catch (error) {
      // Settings opening failed, but don't update state
    }
  }
}

/// Provider for current location
@riverpod
class CurrentLocationNotifier extends _$CurrentLocationNotifier {
  @override
  Future<AppLocation?> build() async {
    // Don't auto-fetch location, wait for explicit request
    return null;
  }

  /// Get current location
  Future<void> getCurrentLocation() async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(locationServiceProvider);
      final location = await service.getCurrentLocation();
      state = AsyncValue.data(location);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Clear current location
  void clearLocation() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for matching state
@riverpod
class MatchingNotifier extends _$MatchingNotifier {
  MatchingService? _matchingService;

  @override
  MatchingState build() {
    _matchingService = ref.watch(matchingServiceProvider);

    // Listen to matching service state changes
    final subscription = _matchingService!.stateStream.listen((newState) {
      state = newState;
    });

    // Dispose subscription when provider is disposed
    ref.onDispose(() {
      subscription.cancel();
      _matchingService?.dispose();
    });

    return MatchingState.idle;
  }

  /// Start matching process
  Future<void> startMatching() async {
    try {
      await _matchingService?.startMatching();
    } catch (error) {
      // Error is handled by the matching service event stream
    }
  }

  /// Stop matching process
  Future<void> stopMatching() async {
    try {
      await _matchingService?.stopMatching();
    } catch (error) {
      // Error is handled by the matching service event stream
    }
  }

  /// Simulate shake for testing
  void simulateShake() {
    _matchingService?.simulateShake();
  }

  /// Check if permissions and location are ready
  Future<bool> checkReadiness() async {
    try {
      // Check location service
      final locationService = ref.read(locationServiceProvider);
      final serviceEnabled = await locationService.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      // Check permissions
      final permissionStatus = await locationService.getPermissionStatus();
      return permissionStatus == LocationPermissionStatus.granted;
    } catch (e) {
      return false;
    }
  }
}

/// Provider for matching events stream
@riverpod
Stream<MatchingEvent> matchingEvents(Ref ref) {
  final service = ref.watch(matchingServiceProvider);
  return service.eventStream;
}

/// Provider for shake events stream
@riverpod
Stream<ShakeEvent> shakeEvents(Ref ref) {
  final service = ref.watch(shakeDetectionServiceProvider);
  return service.shakeStream;
}

/// Provider for current match result
@riverpod
class CurrentMatchNotifier extends _$CurrentMatchNotifier {
  @override
  MatchResult? build() {
    return null;
  }

  /// Set current match result
  void setMatch(MatchResult? match) {
    state = match;
  }

  /// Clear current match
  void clearMatch() {
    state = null;
  }
}

/// Provider for matching error state
@riverpod
class MatchingErrorNotifier extends _$MatchingErrorNotifier {
  @override
  String? build() {
    return null;
  }

  /// Set error message
  void setError(String? error) {
    state = error;
  }

  /// Clear error
  void clearError() {
    state = null;
  }
}

/// Provider for comprehensive matching status
@riverpod
class MatchingStatusNotifier extends _$MatchingStatusNotifier {
  @override
  MatchingStatus build() {
    return MatchingStatus(
      state: MatchingState.idle,
      permissionStatus: LocationPermissionStatus.denied,
      locationServiceEnabled: false,
      currentLocation: null,
      currentMatch: null,
      lastError: null,
    );
  }

  /// Update status from various sources
  void updateFromState(MatchingState newState) {
    state = state.copyWith(state: newState);
  }

  void updateFromPermission(LocationPermissionStatus permission) {
    state = state.copyWith(permissionStatus: permission);
  }

  void updateFromLocation(AppLocation? location) {
    state = state.copyWith(currentLocation: location);
  }

  void updateFromMatch(MatchResult? match) {
    state = state.copyWith(currentMatch: match);
  }

  void updateFromError(String? error) {
    state = state.copyWith(lastError: error);
  }

  void updateLocationService(bool enabled) {
    state = state.copyWith(locationServiceEnabled: enabled);
  }

  /// Check if ready to start matching
  bool get canStartMatching {
    return state.permissionStatus == LocationPermissionStatus.granted &&
           state.locationServiceEnabled &&
           state.state == MatchingState.idle;
  }

  /// Get user-friendly status message
  String get statusMessage {
    if (state.lastError != null) return state.lastError!;

    switch (state.state) {
      case MatchingState.idle:
        if (!state.locationServiceEnabled) return 'Konum servisi devre dışı';
        if (state.permissionStatus != LocationPermissionStatus.granted) {
          return 'Konum izni gerekli';
        }
        return 'Telefonunu salla!';
      case MatchingState.requestingLocation:
        return 'Konum alınıyor...';
      case MatchingState.waitingForShake:
        return 'Telefonu salla ve eşleş!';
      case MatchingState.shaking:
        return 'Eşleştirme yapılıyor...';
      case MatchingState.matched:
        return 'Eşleşme bulundu!';
    }
  }
}

/// Comprehensive matching status data class
class MatchingStatus {
  final MatchingState state;
  final LocationPermissionStatus permissionStatus;
  final bool locationServiceEnabled;
  final AppLocation? currentLocation;
  final MatchResult? currentMatch;
  final String? lastError;

  const MatchingStatus({
    required this.state,
    required this.permissionStatus,
    required this.locationServiceEnabled,
    required this.currentLocation,
    required this.currentMatch,
    required this.lastError,
  });

  MatchingStatus copyWith({
    MatchingState? state,
    LocationPermissionStatus? permissionStatus,
    bool? locationServiceEnabled,
    AppLocation? currentLocation,
    MatchResult? currentMatch,
    String? lastError,
  }) {
    return MatchingStatus(
      state: state ?? this.state,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      locationServiceEnabled: locationServiceEnabled ?? this.locationServiceEnabled,
      currentLocation: currentLocation ?? this.currentLocation,
      currentMatch: currentMatch ?? this.currentMatch,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchingStatus &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          permissionStatus == other.permissionStatus &&
          locationServiceEnabled == other.locationServiceEnabled &&
          currentLocation == other.currentLocation &&
          currentMatch == other.currentMatch &&
          lastError == other.lastError;

  @override
  int get hashCode =>
      state.hashCode ^
      permissionStatus.hashCode ^
      locationServiceEnabled.hashCode ^
      currentLocation.hashCode ^
      currentMatch.hashCode ^
      lastError.hashCode;
}

/// Provider for location service enabled status
@riverpod
class LocationServiceStatusNotifier extends _$LocationServiceStatusNotifier {
  @override
  Future<bool> build() async {
    final service = ref.watch(locationServiceProvider);
    return await service.isLocationServiceEnabled();
  }

  /// Refresh location service status
  Future<void> refresh() async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(locationServiceProvider);
      final enabled = await service.isLocationServiceEnabled();
      state = AsyncValue.data(enabled);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Provider for unified matching controller
@riverpod
class MatchingControllerNotifier extends _$MatchingControllerNotifier {
  @override
  Future<void> build() async {
    // Listen to various state changes and update unified status
    _listenToStateChanges();
  }

  void _listenToStateChanges() {
    // Listen to matching events
    ref.listen(matchingEventsProvider, (previous, next) {
      next.when(
        data: (event) => _handleMatchingEvent(event),
        loading: () {},
        error: (error, stack) {
          ref.read(matchingErrorNotifierProvider.notifier).setError(error.toString());
          ref.read(matchingStatusNotifierProvider.notifier).updateFromError(error.toString());
        },
      );
    });

    // Listen to matching state changes
    ref.listen(matchingNotifierProvider, (previous, next) {
      ref.read(matchingStatusNotifierProvider.notifier).updateFromState(next);
    });

    // Listen to permission changes
    ref.listen(locationPermissionNotifierProvider, (previous, next) {
      next.whenData((permission) {
        ref.read(matchingStatusNotifierProvider.notifier).updateFromPermission(permission);
      });
    });

    // Listen to location service status
    ref.listen(locationServiceStatusNotifierProvider, (previous, next) {
      next.whenData((enabled) {
        ref.read(matchingStatusNotifierProvider.notifier).updateLocationService(enabled);
      });
    });

    // Listen to location updates
    ref.listen(currentLocationNotifierProvider, (previous, next) {
      next.whenData((location) {
        ref.read(matchingStatusNotifierProvider.notifier).updateFromLocation(location);
      });
    });
  }

  void _handleMatchingEvent(MatchingEvent event) {
    switch (event) {
      case LocationObtainedEvent(location: final location):
        ref.read(currentLocationNotifierProvider.notifier).state = AsyncValue.data(location);
        break;
      case MatchFoundEvent(match: final match):
        ref.read(currentMatchNotifierProvider.notifier).setMatch(match);
        ref.read(matchingStatusNotifierProvider.notifier).updateFromMatch(match);
        break;
      case MatchingErrorEvent(message: final message):
        ref.read(matchingErrorNotifierProvider.notifier).setError(message);
        ref.read(matchingStatusNotifierProvider.notifier).updateFromError(message);
        break;
      case NoMatchFoundEvent():
        ref.read(matchingErrorNotifierProvider.notifier).setError('Eşleşme bulunamadı');
        break;
      case MatchingStoppedEvent():
        ref.read(currentMatchNotifierProvider.notifier).clearMatch();
        ref.read(matchingErrorNotifierProvider.notifier).clearError();
        break;
      default:
        break;
    }
  }

  /// Initiate matching with all checks
  Future<bool> initiateMatching() async {
    try {
      // Clear previous errors
      ref.read(matchingErrorNotifierProvider.notifier).clearError();

      // Check location service
      final locationService = ref.read(locationServiceProvider);
      final serviceEnabled = await locationService.isLocationServiceEnabled();

      if (!serviceEnabled) {
        ref.read(matchingErrorNotifierProvider.notifier)
            .setError('Konum servisi devre dışı. Lütfen etkinleştirin.');
        return false;
      }

      // Check permissions
      final permissionStatus = await locationService.getPermissionStatus();
      if (permissionStatus != LocationPermissionStatus.granted) {
        ref.read(matchingErrorNotifierProvider.notifier)
            .setError('Konum izni gerekli. Lütfen izin verin.');
        return false;
      }

      // Start matching
      await ref.read(matchingNotifierProvider.notifier).startMatching();
      return true;
    } catch (e) {
      ref.read(matchingErrorNotifierProvider.notifier)
          .setError('Eşleştirme başlatılamadı: $e');
      return false;
    }
  }

  /// Stop matching
  Future<void> stopMatching() async {
    await ref.read(matchingNotifierProvider.notifier).stopMatching();
    ref.read(matchingErrorNotifierProvider.notifier).clearError();
  }

  /// Request permissions if needed
  Future<bool> ensurePermissions() async {
    try {
      final permissionNotifier = ref.read(locationPermissionNotifierProvider.notifier);
      await permissionNotifier.requestPermission();

      final permission = await ref.read(locationPermissionNotifierProvider.future);
      return permission == LocationPermissionStatus.granted;
    } catch (e) {
      ref.read(matchingErrorNotifierProvider.notifier)
          .setError('İzin alınamadı: $e');
      return false;
    }
  }
}

/// Provider for app setup state stream
@riverpod
Stream<AppSetupState> appSetupStateStream(Ref ref) {
  final service = ref.watch(appSetupServiceProvider);
  return service.setupStateStream;
}

/// Provider for app setup notifier
@riverpod
class AppSetupNotifier extends _$AppSetupNotifier {
  @override
  AppSetupState build() {
    final service = ref.watch(appSetupServiceProvider);

    // Listen to setup state changes
    final subscription = service.setupStateStream.listen((state) {
      this.state = state;
    });

    ref.onDispose(() => subscription.cancel());

    // Initialize setup check
    Future.microtask(() => service.initializeSetup());

    return service.currentState;
  }

  /// Request setup permissions
  Future<SetupResult> requestSetup() async {
    final service = ref.read(appSetupServiceProvider);
    return await service.requestSetup();
  }

  /// Open settings
  Future<void> openSettings() async {
    final service = ref.read(appSetupServiceProvider);
    await service.openSettings();
  }

  /// Refresh setup state
  Future<void> refresh() async {
    final service = ref.read(appSetupServiceProvider);
    await service.refreshState();
  }
}