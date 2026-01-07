import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blind_shake/src/app/theme/app_colors.dart';
import 'package:blind_shake/src/app/theme/app_typography.dart';
import 'package:blind_shake/src/app/router.dart';
import 'package:blind_shake/src/features/matching/presentation/providers/matching_providers.dart';
import 'package:blind_shake/src/features/matching/data/services/matching_service.dart';
import 'dart:async';

class MatchingScreen extends ConsumerStatefulWidget {
  const MatchingScreen({super.key});

  @override
  ConsumerState<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends ConsumerState<MatchingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  String _statusMessage = 'Waiting for shake...';
  bool _canCancel = true;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    // Listen to matching events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToMatchingEvents();
    });

    // Set a timeout for the matching process
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        _handleTimeout();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _listenToMatchingEvents() {
    ref.listen(matchingEventsProvider, (previous, next) {
      next.when(
        data: (event) => _handleMatchingEvent(event),
        loading: () {},
        error: (error, _) => _handleError('Matching error: $error'),
      );
    });
  }

  void _handleMatchingEvent(MatchingEvent event) {
    if (!mounted) return;

    switch (event) {
      case LocationObtainedEvent():
        setState(() {
          _statusMessage = 'Location obtained, shake your phone!';
        });
        break;
      case ShakeDetectedEvent():
        setState(() {
          _statusMessage = 'Shake detected! Looking for matches...';
        });
        break;
      case ShakingStartedEvent():
        setState(() {
          _statusMessage = 'Searching for nearby users...';
        });
        break;
      case MatchFoundEvent(:final match):
        _timeoutTimer?.cancel();
        setState(() {
          _statusMessage = 'Match found! Connecting...';
          _canCancel = false;
        });
        _navigateToChat(match.matchId);
        break;
      case NoMatchFoundEvent():
        _handleNoMatch();
        break;
      case MatchingErrorEvent(:final message):
        _handleError(message);
        break;
      case MatchingStoppedEvent():
        _navigateBack();
        break;
    }
  }

  void _handleTimeout() {
    setState(() {
      _statusMessage = 'No matches found nearby';
      _canCancel = false;
    });
    _showTimeoutDialog();
  }

  void _handleNoMatch() {
    setState(() {
      _statusMessage = 'No matches found';
      _canCancel = false;
    });
    _showNoMatchDialog();
  }

  void _handleError(String error) {
    setState(() {
      _statusMessage = 'Error: $error';
      _canCancel = false;
    });
    _showErrorDialog(error);
  }

  void _navigateToChat(String matchId) {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        AppNavigation.toChat(context, matchId);
      }
    });
  }

  void _navigateBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      AppNavigation.toHome(context);
    }
  }

  void _cancelMatching() {
    if (_canCancel) {
      ref.read(matchingNotifierProvider.notifier).stopMatching();
    }
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'No Matches Found',
          style: AppTypography.titleLarge,
        ),
        content: Text(
          'No one is currently shaking nearby. Try again later or move to a different location.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateBack();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              'OK',
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showNoMatchDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'No Matches Found',
          style: AppTypography.titleLarge,
        ),
        content: Text(
          'No matches found this time. Try shaking again or check back later.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateBack();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              'OK',
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Error',
          style: AppTypography.titleLarge.copyWith(color: AppColors.error),
        ),
        content: Text(
          error,
          style: AppTypography.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateBack();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              'OK',
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchingState = ref.watch(matchingNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated backgrounds
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 300 + (_pulseController.value * 100),
                  height: 300 + (_pulseController.value * 100),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: 0.2 - (_pulseController.value * 0.1),
                        ),
                        blurRadius: 100 + (_pulseController.value * 50),
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Cancel button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _canCancel
                        ? IconButton(
                            onPressed: _cancelMatching,
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.textSecondary,
                              size: 28,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  _getHeaderText(matchingState),
                  style: AppTypography.headlineMedium.copyWith(letterSpacing: 2),
                  textAlign: TextAlign.center,
                ).animate().fadeIn().scale(),
                const Spacer(),

                // Match visual
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse circles
                    ...List.generate(3, (index) {
                      return AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final scale = ((_pulseController.value + (index * 0.3)) % 1.0);
                          return Transform.scale(
                            scale: 0.5 + (scale * 1.5),
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: (1.0 - scale) * 0.3,
                                  ),
                                  width: 2,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),

                    // Center icon
                    AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_shakeController.value * 0.2),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.primaryGradient,
                            ),
                            child: Icon(
                              _getIconForState(matchingState),
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (matchingState == MatchingState.waitingForShake)
                        Text(
                          'Shake your phone to find someone nearby!',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getHeaderText(MatchingState state) {
    switch (state) {
      case MatchingState.requestingLocation:
        return 'GETTING LOCATION';
      case MatchingState.waitingForShake:
        return 'SHAKE TO MATCH';
      case MatchingState.shaking:
        return 'SEARCHING...';
      case MatchingState.matched:
        return 'MATCH FOUND!';
      default:
        return 'MATCHING';
    }
  }

  IconData _getIconForState(MatchingState state) {
    switch (state) {
      case MatchingState.requestingLocation:
        return Icons.location_searching;
      case MatchingState.waitingForShake:
        return Icons.vibration;
      case MatchingState.shaking:
        return Icons.search;
      case MatchingState.matched:
        return Icons.favorite;
      default:
        return Icons.vibration;
    }
  }
}
