import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling location permissions and GPS coordinates
class LocationService {
  static const Duration _timeoutDuration = Duration(seconds: 10);
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // Minimum distance in meters before update
    timeLimit: _timeoutDuration,
  );

  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('Error checking location service: $e');
      return false;
    }
  }

  /// Check current location permission status
  Future<LocationPermissionStatus> getPermissionStatus() async {
    try {
      final permission = await Permission.location.status;

      if (permission.isDenied) {
        return LocationPermissionStatus.denied;
      } else if (permission.isPermanentlyDenied) {
        return LocationPermissionStatus.deniedForever;
      } else if (permission.isGranted) {
        return LocationPermissionStatus.granted;
      } else if (permission.isRestricted) {
        return LocationPermissionStatus.restricted;
      } else {
        return LocationPermissionStatus.denied;
      }
    } catch (e) {
      debugPrint('Error checking permission status: $e');
      return LocationPermissionStatus.denied;
    }
  }

  /// Request location permission from the user
  Future<LocationPermissionStatus> requestPermission() async {
    try {
      // Check if location service is enabled first
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException('Location services are disabled');
      }

      // Request permission
      final permission = await Permission.location.request();

      if (permission.isGranted) {
        return LocationPermissionStatus.granted;
      } else if (permission.isPermanentlyDenied) {
        return LocationPermissionStatus.deniedForever;
      } else {
        return LocationPermissionStatus.denied;
      }
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      throw LocationException('Failed to request location permission: $e');
    }
  }

  /// Get the current device location
  Future<AppLocation> getCurrentLocation() async {
    try {
      // Check permissions first
      final permissionStatus = await getPermissionStatus();
      if (permissionStatus != LocationPermissionStatus.granted) {
        throw LocationException('Location permission not granted');
      }

      // Check if location service is enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException('Location services are disabled');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      ).timeout(_timeoutDuration);

      return AppLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: DateTime.fromMillisecondsSinceEpoch(position.timestamp.millisecondsSinceEpoch),
      );

    } on TimeoutException {
      throw LocationException('Location request timed out');
    } on LocationServiceDisabledException {
      throw LocationException('Location services are disabled');
    } on PermissionDeniedException {
      throw LocationException('Location permission denied');
    } catch (e) {
      debugPrint('Error getting current location: $e');
      throw LocationException('Failed to get location: $e');
    }
  }

  /// Get location stream for continuous updates
  Stream<AppLocation> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    ).map((position) => AppLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        position.timestamp.millisecondsSinceEpoch,
      ),
    )).handleError((error) {
      debugPrint('Location stream error: $error');
      throw LocationException('Location stream error: $error');
    });
  }

  /// Calculate distance between two locations in kilometers
  double distanceBetween(AppLocation location1, AppLocation location2) {
    try {
      final distanceInMeters = Geolocator.distanceBetween(
        location1.latitude,
        location1.longitude,
        location2.latitude,
        location2.longitude,
      );
      return distanceInMeters / 1000; // Convert to kilometers
    } catch (e) {
      debugPrint('Error calculating distance: $e');
      return 0;
    }
  }

  /// Open device location settings
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('Error opening location settings: $e');
      // Fall back to general app settings
      await openAppSettings();
    }
  }

  /// Request permission with comprehensive handling
  Future<LocationPermissionResult> requestPermissionWithResult() async {
    try {
      // Check if location service is enabled first
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionResult(
          status: LocationPermissionStatus.denied,
          message: 'Konum servisi devre dışı. Lütfen cihaz ayarlarından etkinleştirin.',
          canRetry: true,
          shouldOpenSettings: true,
        );
      }

      // Get current permission status
      final currentStatus = await getPermissionStatus();

      // If already granted, return success
      if (currentStatus == LocationPermissionStatus.granted) {
        return LocationPermissionResult(
          status: LocationPermissionStatus.granted,
          message: 'Konum izni verildi.',
          canRetry: false,
          shouldOpenSettings: false,
        );
      }

      // If permanently denied, can't request again
      if (currentStatus == LocationPermissionStatus.deniedForever) {
        return LocationPermissionResult(
          status: LocationPermissionStatus.deniedForever,
          message: 'Konum izni kalıcı olarak reddedildi. Ayarlardan etkinleştirin.',
          canRetry: false,
          shouldOpenSettings: true,
        );
      }

      // Request permission
      final permission = await Permission.location.request();

      if (permission.isGranted) {
        return LocationPermissionResult(
          status: LocationPermissionStatus.granted,
          message: 'Konum izni verildi.',
          canRetry: false,
          shouldOpenSettings: false,
        );
      } else if (permission.isPermanentlyDenied) {
        return LocationPermissionResult(
          status: LocationPermissionStatus.deniedForever,
          message: 'Konum izni kalıcı olarak reddedildi. Ayarlardan etkinleştirin.',
          canRetry: false,
          shouldOpenSettings: true,
        );
      } else {
        return LocationPermissionResult(
          status: LocationPermissionStatus.denied,
          message: 'Konum izni reddedildi. Tekrar denemek için izin verin.',
          canRetry: true,
          shouldOpenSettings: false,
        );
      }
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return LocationPermissionResult(
        status: LocationPermissionStatus.denied,
        message: 'Konum izni istenir: $e',
        canRetry: true,
        shouldOpenSettings: false,
      );
    }
  }

  /// Get location with comprehensive error handling
  Future<LocationResult> getLocationWithResult() async {
    try {
      // Check permissions first
      final permissionResult = await requestPermissionWithResult();
      if (permissionResult.status != LocationPermissionStatus.granted) {
        return LocationResult.error(
          permissionResult.message,
          canRetry: permissionResult.canRetry,
          shouldOpenSettings: permissionResult.shouldOpenSettings,
        );
      }

      // Get current position with timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      ).timeout(_timeoutDuration);

      final location = AppLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: DateTime.fromMillisecondsSinceEpoch(position.timestamp.millisecondsSinceEpoch),
      );

      // Validate location
      if (!isValidLocation(location)) {
        return LocationResult.error(
          'Alınan konum verisi geçersiz. Tekrar deneyin.',
          canRetry: true,
          shouldOpenSettings: false,
        );
      }

      return LocationResult.success(location);

    } on TimeoutException {
      return LocationResult.error(
        'Konum alınamadı (zaman aşımı). Tekrar deneyin.',
        canRetry: true,
        shouldOpenSettings: false,
      );
    } on LocationServiceDisabledException {
      return LocationResult.error(
        'Konum servisi devre dışı. Cihaz ayarlarından etkinleştirin.',
        canRetry: true,
        shouldOpenSettings: true,
      );
    } on PermissionDeniedException {
      return LocationResult.error(
        'Konum izni reddedildi. İzin vermek için ayarlara gidin.',
        canRetry: false,
        shouldOpenSettings: true,
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return LocationResult.error(
        'Konum alınamadı: $e',
        canRetry: true,
        shouldOpenSettings: false,
      );
    }
  }

  /// Check comprehensive readiness for location-based features
  Future<LocationReadinessResult> checkLocationReadiness() async {
    try {
      // Check location service
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationReadinessResult(
          isReady: false,
          message: 'Konum servisi devre dışı',
          action: LocationAction.enableService,
        );
      }

      // Check permissions
      final permissionStatus = await getPermissionStatus();
      switch (permissionStatus) {
        case LocationPermissionStatus.granted:
          return LocationReadinessResult(
            isReady: true,
            message: 'Konum servisi hazır',
            action: LocationAction.none,
          );
        case LocationPermissionStatus.denied:
          return LocationReadinessResult(
            isReady: false,
            message: 'Konum izni gerekli',
            action: LocationAction.requestPermission,
          );
        case LocationPermissionStatus.deniedForever:
          return LocationReadinessResult(
            isReady: false,
            message: 'Konum izni kalıcı olarak reddedildi',
            action: LocationAction.openSettings,
          );
        case LocationPermissionStatus.restricted:
          return LocationReadinessResult(
            isReady: false,
            message: 'Konum erişimi kısıtlı',
            action: LocationAction.none,
          );
      }
    } catch (e) {
      debugPrint('Error checking location readiness: $e');
      return LocationReadinessResult(
        isReady: false,
        message: 'Konum durumu kontrol edilemiyor',
        action: LocationAction.none,
      );
    }
  }

  /// Validate if location coordinates are reasonable
  bool isValidLocation(AppLocation location) {
    return location.latitude >= -90 &&
        location.latitude <= 90 &&
        location.longitude >= -180 &&
        location.longitude <= 180 &&
        location.accuracy < 1000; // Accuracy better than 1km
  }

  /// Get a location with reduced precision for privacy
  AppLocation getPrivacyLocation(AppLocation location, {int precision = 4}) {
    final factor = pow(10, precision).toDouble();

    return AppLocation(
      latitude: (location.latitude * factor).round() / factor,
      longitude: (location.longitude * factor).round() / factor,
      accuracy: location.accuracy,
      timestamp: location.timestamp,
    );
  }
}

/// Represents a location coordinate
class AppLocation {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  const AppLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  /// Convert to map for Cloud Functions
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  /// Create from map
  factory AppLocation.fromMap(Map<String, dynamic> map) {
    return AppLocation(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  String toString() {
    return 'AppLocation(lat: ${latitude.toStringAsFixed(6)}, lng: ${longitude.toStringAsFixed(6)}, accuracy: ${accuracy.toStringAsFixed(1)}m)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLocation &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

/// Location permission status
enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  restricted,
}

/// Location service exception
class LocationException implements Exception {
  final String message;
  final Object? originalError;

  const LocationException(this.message, [this.originalError]);

  @override
  String toString() => 'LocationException: $message';
}

/// Result of location permission request
class LocationPermissionResult {
  final LocationPermissionStatus status;
  final String message;
  final bool canRetry;
  final bool shouldOpenSettings;

  const LocationPermissionResult({
    required this.status,
    required this.message,
    required this.canRetry,
    required this.shouldOpenSettings,
  });
}

/// Result of location request
class LocationResult {
  final AppLocation? location;
  final String? error;
  final bool isSuccess;
  final bool canRetry;
  final bool shouldOpenSettings;

  const LocationResult._(
    this.location,
    this.error,
    this.isSuccess,
    this.canRetry,
    this.shouldOpenSettings,
  );

  factory LocationResult.success(AppLocation location) {
    return LocationResult._(location, null, true, false, false);
  }

  factory LocationResult.error(
    String error, {
    required bool canRetry,
    required bool shouldOpenSettings,
  }) {
    return LocationResult._(null, error, false, canRetry, shouldOpenSettings);
  }
}

/// Location readiness check result
class LocationReadinessResult {
  final bool isReady;
  final String message;
  final LocationAction action;

  const LocationReadinessResult({
    required this.isReady,
    required this.message,
    required this.action,
  });
}

/// Actions that can be taken based on location status
enum LocationAction {
  none,
  enableService,
  requestPermission,
  openSettings,
}

/// Utility function for pow operation
double pow(num x, num exponent) {
  return math.pow(x, exponent).toDouble();
}