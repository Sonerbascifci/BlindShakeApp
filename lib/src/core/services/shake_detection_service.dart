import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Service for detecting shake gestures using device accelerometer
class ShakeDetectionService {
  static const double _shakeThreshold = 12.0; // Acceleration threshold for shake detection
  static const int _shakeDuration = 500; // Minimum duration between shakes (ms)
  static const int _shakeCount = 2; // Number of shake events needed

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final StreamController<ShakeEvent> _shakeController = StreamController<ShakeEvent>.broadcast();

  DateTime? _lastShakeTime;
  int _shakeCounter = 0;
  bool _isShaking = false;

  /// Stream of shake events
  Stream<ShakeEvent> get shakeStream => _shakeController.stream;

  /// Whether shake detection is currently active
  bool get isListening => _accelerometerSubscription != null;

  /// Start listening for shake gestures
  Future<void> startListening() async {
    if (_accelerometerSubscription != null) {
      return; // Already listening
    }

    try {
      _accelerometerSubscription = accelerometerEventStream().listen(
        _onAccelerometerEvent,
        onError: (error) {
          debugPrint('Accelerometer error: $error');
          _shakeController.addError(ShakeError('Accelerometer error: $error'));
        },
      );

      debugPrint('Shake detection started');
    } catch (e) {
      debugPrint('Failed to start shake detection: $e');
      _shakeController.addError(ShakeError('Failed to start shake detection: $e'));
    }
  }

  /// Stop listening for shake gestures
  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _resetShakeState();
    debugPrint('Shake detection stopped');
  }

  /// Handle accelerometer events
  void _onAccelerometerEvent(AccelerometerEvent event) {
    final now = DateTime.now();

    // Calculate total acceleration magnitude
    final acceleration = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Check if acceleration exceeds threshold
    if (acceleration > _shakeThreshold) {
      _handleShakeDetected(now);
    } else {
      // Reset shake state if no significant movement
      if (_isShaking &&
          _lastShakeTime != null &&
          now.difference(_lastShakeTime!).inMilliseconds > _shakeDuration) {
        _resetShakeState();
      }
    }
  }

  /// Handle shake detection logic
  void _handleShakeDetected(DateTime now) {
    if (_lastShakeTime == null ||
        now.difference(_lastShakeTime!).inMilliseconds > _shakeDuration) {

      _shakeCounter++;
      _lastShakeTime = now;
      _isShaking = true;

      debugPrint('Shake detected: $_shakeCounter/$_shakeCount');

      // Check if we have enough shake events
      if (_shakeCounter >= _shakeCount) {
        _triggerShakeEvent();
      }

      // Auto-reset after timeout
      Timer(Duration(milliseconds: _shakeDuration * 2), () {
        if (_isShaking) {
          _resetShakeState();
        }
      });
    }
  }

  /// Trigger a shake event
  void _triggerShakeEvent() {
    final shakeEvent = ShakeEvent(
      timestamp: DateTime.now(),
      intensity: _shakeCounter.toDouble(),
    );

    _shakeController.add(shakeEvent);
    _resetShakeState();

    debugPrint('Shake event triggered: ${shakeEvent.timestamp}');
  }

  /// Reset shake detection state
  void _resetShakeState() {
    _shakeCounter = 0;
    _isShaking = false;
    _lastShakeTime = null;
  }

  /// Test shake gesture (for development/testing)
  void simulateShake() {
    if (kDebugMode) {
      final shakeEvent = ShakeEvent(
        timestamp: DateTime.now(),
        intensity: _shakeThreshold,
        isSimulated: true,
      );
      _shakeController.add(shakeEvent);
      debugPrint('Simulated shake event triggered');
    }
  }

  /// Dispose of the service
  void dispose() {
    stopListening();
    _shakeController.close();
  }
}

/// Represents a shake event
class ShakeEvent {
  final DateTime timestamp;
  final double intensity;
  final bool isSimulated;

  const ShakeEvent({
    required this.timestamp,
    required this.intensity,
    this.isSimulated = false,
  });

  @override
  String toString() {
    return 'ShakeEvent(timestamp: $timestamp, intensity: $intensity, simulated: $isSimulated)';
  }
}

/// Shake detection error
class ShakeError {
  final String message;
  final Object? originalError;

  const ShakeError(this.message, [this.originalError]);

  @override
  String toString() => 'ShakeError: $message';
}