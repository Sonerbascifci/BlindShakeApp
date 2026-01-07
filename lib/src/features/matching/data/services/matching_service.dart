import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:blind_shake/src/core/services/location_service.dart';
import 'package:blind_shake/src/core/services/shake_detection_service.dart';

/// Service for handling matching logic and Cloud Function interactions
class MatchingService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final LocationService _locationService = LocationService();
  final ShakeDetectionService _shakeDetectionService = ShakeDetectionService();

  StreamSubscription<ShakeEvent>? _shakeSubscription;
  Timer? _shakingTimeout;
  String? _currentGeohash;

  /// Current matching state
  MatchingState _state = MatchingState.idle;
  MatchingState get state => _state;

  /// Stream controller for matching state changes
  final StreamController<MatchingState> _stateController = StreamController<MatchingState>.broadcast();
  Stream<MatchingState> get stateStream => _stateController.stream;

  /// Stream controller for matching events
  final StreamController<MatchingEvent> _eventController = StreamController<MatchingEvent>.broadcast();
  Stream<MatchingEvent> get eventStream => _eventController.stream;

  /// Start the matching process
  Future<void> startMatching() async {
    try {
      if (_state != MatchingState.idle) {
        throw MatchingException('Eşleştirme zaten devam ediyor');
      }

      _updateState(MatchingState.requestingLocation);

      // Check location readiness first
      final readinessResult = await _locationService.checkLocationReadiness();
      if (!readinessResult.isReady) {
        throw MatchingException(readinessResult.message);
      }

      // Get current location with enhanced error handling
      final locationResult = await _locationService.getLocationWithResult();
      if (!locationResult.isSuccess) {
        throw MatchingException(locationResult.error ?? 'Konum alınamadı');
      }

      final location = locationResult.location!;

      _updateState(MatchingState.waitingForShake);

      // Start listening for shake events
      await _shakeDetectionService.startListening();
      _shakeSubscription = _shakeDetectionService.shakeStream.listen(
        _onShakeDetected,
        onError: (error) {
          debugPrint('Shake detection error: $error');
          _eventController.add(MatchingEvent.error('Sarsma algılama hatası: $error'));
        },
      );

      _eventController.add(MatchingEvent.locationObtained(location));
      debugPrint('Matching started - waiting for shake');

    } catch (e) {
      _updateState(MatchingState.idle);
      _eventController.add(MatchingEvent.error('Eşleştirme başlayamadı: $e'));
      rethrow;
    }
  }

  /// Stop the matching process
  Future<void> stopMatching() async {
    try {
      await _shakeSubscription?.cancel();
      _shakeSubscription = null;

      _shakeDetectionService.stopListening();
      _shakingTimeout?.cancel();

      // If we were actively shaking, stop it on the server
      if (_currentGeohash != null) {
        await _stopShakingOnServer();
      }

      _updateState(MatchingState.idle);
      _eventController.add(MatchingEvent.matchingStopped());

      debugPrint('Matching stopped');
    } catch (e) {
      debugPrint('Error stopping matching: $e');
    }
  }

  /// Handle shake detection
  Future<void> _onShakeDetected(ShakeEvent shakeEvent) async {
    try {
      if (_state != MatchingState.waitingForShake) {
        return; // Ignore shakes if not in correct state
      }

      _updateState(MatchingState.shaking);
      _eventController.add(MatchingEvent.shakeDetected(shakeEvent));

      // Get current location for matching
      final location = await _locationService.getCurrentLocation();

      // Call Cloud Function to start shaking
      final result = await _startShakingOnServer(location);

      if (result['match'] != null) {
        // Match found immediately
        final match = MatchResult.fromJson(result['match']);
        _updateState(MatchingState.matched);
        _eventController.add(MatchingEvent.matchFound(match));
      } else {
        // No immediate match, continue shaking
        _currentGeohash = result['geohash'] as String?;
        _eventController.add(MatchingEvent.shakingStarted(_currentGeohash!));

        // Set timeout for shaking
        _shakingTimeout = Timer(const Duration(seconds: 30), () {
          _onShakingTimeout();
        });
      }

    } catch (e) {
      _updateState(MatchingState.waitingForShake);
      _eventController.add(MatchingEvent.error('Shake processing failed: $e'));
    }
  }

  /// Handle shaking timeout
  void _onShakingTimeout() {
    debugPrint('Shaking timeout reached');
    _updateState(MatchingState.waitingForShake);
    _eventController.add(MatchingEvent.noMatchFound());

    if (_currentGeohash != null) {
      _stopShakingOnServer();
    }
  }

  /// Start shaking on server
  Future<Map<String, dynamic>> _startShakingOnServer(AppLocation location) async {
    try {
      final callable = _functions.httpsCallable('startShaking');
      final result = await callable.call({
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
      });

      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Cloud Function error: ${e.code} - ${e.message}');
      throw MatchingException('Server error: ${e.message}');
    }
  }

  /// Stop shaking on server
  Future<void> _stopShakingOnServer() async {
    if (_currentGeohash == null) return;

    try {
      final callable = _functions.httpsCallable('stopShaking');
      await callable.call({
        'geohash': _currentGeohash,
      });

      _currentGeohash = null;
      _shakingTimeout?.cancel();
    } catch (e) {
      debugPrint('Error stopping shaking on server: $e');
    }
  }

  /// Update matching state
  void _updateState(MatchingState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(_state);
      debugPrint('Matching state changed: ${_state.name}');
    }
  }

  /// Simulate shake for testing
  void simulateShake() {
    if (kDebugMode && _state == MatchingState.waitingForShake) {
      _shakeDetectionService.simulateShake();
    }
  }

  /// Dispose of the service
  void dispose() {
    stopMatching();
    _stateController.close();
    _eventController.close();
    _shakeDetectionService.dispose();
  }
}

/// Matching states
enum MatchingState {
  idle,
  requestingLocation,
  waitingForShake,
  shaking,
  matched,
}

/// Matching events
sealed class MatchingEvent {
  const MatchingEvent();

  factory MatchingEvent.locationObtained(AppLocation location) = LocationObtainedEvent;
  factory MatchingEvent.shakeDetected(ShakeEvent shake) = ShakeDetectedEvent;
  factory MatchingEvent.shakingStarted(String geohash) = ShakingStartedEvent;
  factory MatchingEvent.matchFound(MatchResult match) = MatchFoundEvent;
  factory MatchingEvent.noMatchFound() = NoMatchFoundEvent;
  factory MatchingEvent.matchingStopped() = MatchingStoppedEvent;
  factory MatchingEvent.error(String message) = MatchingErrorEvent;
}

class LocationObtainedEvent extends MatchingEvent {
  final AppLocation location;
  const LocationObtainedEvent(this.location);
}

class ShakeDetectedEvent extends MatchingEvent {
  final ShakeEvent shake;
  const ShakeDetectedEvent(this.shake);
}

class ShakingStartedEvent extends MatchingEvent {
  final String geohash;
  const ShakingStartedEvent(this.geohash);
}

class MatchFoundEvent extends MatchingEvent {
  final MatchResult match;
  const MatchFoundEvent(this.match);
}

class NoMatchFoundEvent extends MatchingEvent {
  const NoMatchFoundEvent();
}

class MatchingStoppedEvent extends MatchingEvent {
  const MatchingStoppedEvent();
}

class MatchingErrorEvent extends MatchingEvent {
  final String message;
  const MatchingErrorEvent(this.message);
}

/// Match result from Cloud Function
class MatchResult {
  final String matchId;
  final OtherUser otherUser;
  final DateTime anonymousPhaseEnds;

  const MatchResult({
    required this.matchId,
    required this.otherUser,
    required this.anonymousPhaseEnds,
  });

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      matchId: json['matchId'] as String,
      otherUser: OtherUser.fromJson(json['otherUser'] as Map<String, dynamic>),
      anonymousPhaseEnds: DateTime.parse(json['anonymousPhaseEnds'] as String),
    );
  }
}

/// Other user in the match (during anonymous phase)
class OtherUser {
  final String id;
  final String displayName; // "Anonymous" during anonymous phase
  final String? photoURL; // null during anonymous phase

  const OtherUser({
    required this.id,
    required this.displayName,
    this.photoURL,
  });

  factory OtherUser.fromJson(Map<String, dynamic> json) {
    return OtherUser(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      photoURL: json['photoURL'] as String?,
    );
  }
}

/// Matching service exception
class MatchingException implements Exception {
  final String message;
  final Object? originalError;

  const MatchingException(this.message, [this.originalError]);

  @override
  String toString() => 'MatchingException: $message';
}