import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:blind_shake/src/core/services/location_service.dart';

/// Service that manages app setup and readiness checks for matching functionality
class AppSetupService {
  final LocationService _locationService = LocationService();

  /// Stream controller for setup state changes
  final StreamController<AppSetupState> _setupStateController = StreamController<AppSetupState>.broadcast();
  Stream<AppSetupState> get setupStateStream => _setupStateController.stream;

  AppSetupState _currentState = AppSetupState.initial();
  AppSetupState get currentState => _currentState;

  /// Initialize and check all setup requirements
  Future<void> initializeSetup() async {
    try {
      _updateState(AppSetupState.checking());

      // Check location service status
      final serviceEnabled = await _locationService.isLocationServiceEnabled();

      // Check permission status
      final permissionStatus = await _locationService.getPermissionStatus();

      // Determine overall readiness
      final isReady = serviceEnabled && permissionStatus == LocationPermissionStatus.granted;

      if (isReady) {
        _updateState(AppSetupState.ready());
      } else {
        final setupResult = await _locationService.checkLocationReadiness();
        _updateState(AppSetupState.needsSetup(
          message: setupResult.message,
          action: setupResult.action,
          permissionStatus: permissionStatus,
          locationServiceEnabled: serviceEnabled,
        ));
      }
    } catch (e) {
      debugPrint('Error initializing setup: $e');
      _updateState(AppSetupState.error('Kurulum kontrolü başarısız: $e'));
    }
  }

  /// Request all necessary permissions and setup
  Future<SetupResult> requestSetup() async {
    try {
      _updateState(AppSetupState.requesting());

      // Check location service first
      final serviceEnabled = await _locationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _updateState(AppSetupState.needsSetup(
          message: 'Konum servisi devre dışı',
          action: LocationAction.enableService,
          permissionStatus: LocationPermissionStatus.denied,
          locationServiceEnabled: false,
        ));
        return SetupResult.failure(
          'Konum servisini etkinleştirin',
          shouldOpenSettings: true,
        );
      }

      // Request location permission with comprehensive handling
      final permissionResult = await _locationService.requestPermissionWithResult();

      if (permissionResult.status == LocationPermissionStatus.granted) {
        _updateState(AppSetupState.ready());
        return SetupResult.success();
      } else {
        _updateState(AppSetupState.needsSetup(
          message: permissionResult.message,
          action: permissionResult.shouldOpenSettings ? LocationAction.openSettings : LocationAction.requestPermission,
          permissionStatus: permissionResult.status,
          locationServiceEnabled: true,
        ));
        return SetupResult.failure(
          permissionResult.message,
          shouldOpenSettings: permissionResult.shouldOpenSettings,
        );
      }
    } catch (e) {
      debugPrint('Error requesting setup: $e');
      _updateState(AppSetupState.error('Kurulum isteği başarısız: $e'));
      return SetupResult.failure('Kurulum başarısız: $e');
    }
  }

  /// Open device settings for location/permissions
  Future<void> openSettings() async {
    try {
      await _locationService.openLocationSettings();
      // Refresh state after returning from settings
      Future.delayed(const Duration(milliseconds: 500), () {
        initializeSetup();
      });
    } catch (e) {
      debugPrint('Error opening settings: $e');
    }
  }

  /// Refresh setup state
  Future<void> refreshState() async {
    await initializeSetup();
  }

  /// Update the current setup state
  void _updateState(AppSetupState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _setupStateController.add(_currentState);
      debugPrint('App setup state changed: ${_currentState.runtimeType}');
    }
  }

  /// Dispose of the service
  void dispose() {
    _setupStateController.close();
  }
}

/// Represents the current setup state of the app
sealed class AppSetupState {
  const AppSetupState();

  /// Initial state before any checks
  factory AppSetupState.initial() = AppSetupInitialState;

  /// Checking setup requirements
  factory AppSetupState.checking() = AppSetupCheckingState;

  /// Ready to use matching features
  factory AppSetupState.ready() = AppSetupReadyState;

  /// Needs setup to continue
  factory AppSetupState.needsSetup({
    required String message,
    required LocationAction action,
    required LocationPermissionStatus permissionStatus,
    required bool locationServiceEnabled,
  }) = AppSetupNeedsSetupState;

  /// Currently requesting permissions/setup
  factory AppSetupState.requesting() = AppSetupRequestingState;

  /// Error occurred during setup
  factory AppSetupState.error(String message) = AppSetupErrorState;
}

class AppSetupInitialState extends AppSetupState {
  const AppSetupInitialState();
}

class AppSetupCheckingState extends AppSetupState {
  const AppSetupCheckingState();
}

class AppSetupReadyState extends AppSetupState {
  const AppSetupReadyState();
}

class AppSetupNeedsSetupState extends AppSetupState {
  final String message;
  final LocationAction action;
  final LocationPermissionStatus permissionStatus;
  final bool locationServiceEnabled;

  const AppSetupNeedsSetupState({
    required this.message,
    required this.action,
    required this.permissionStatus,
    required this.locationServiceEnabled,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSetupNeedsSetupState &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          action == other.action &&
          permissionStatus == other.permissionStatus &&
          locationServiceEnabled == other.locationServiceEnabled;

  @override
  int get hashCode =>
      message.hashCode ^
      action.hashCode ^
      permissionStatus.hashCode ^
      locationServiceEnabled.hashCode;
}

class AppSetupRequestingState extends AppSetupState {
  const AppSetupRequestingState();
}

class AppSetupErrorState extends AppSetupState {
  final String message;

  const AppSetupErrorState(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSetupErrorState &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Result of setup request operation
class SetupResult {
  final bool isSuccess;
  final String? message;
  final bool shouldOpenSettings;

  const SetupResult._({
    required this.isSuccess,
    this.message,
    this.shouldOpenSettings = false,
  });

  factory SetupResult.success() {
    return const SetupResult._(isSuccess: true);
  }

  factory SetupResult.failure(String message, {bool shouldOpenSettings = false}) {
    return SetupResult._(
      isSuccess: false,
      message: message,
      shouldOpenSettings: shouldOpenSettings,
    );
  }
}