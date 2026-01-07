import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blind_shake/src/app/theme/app_colors.dart';
import 'package:blind_shake/src/app/theme/app_typography.dart';
import 'package:blind_shake/src/app/router.dart';
import 'package:blind_shake/src/shared/widgets/shake_button.dart';
import 'package:blind_shake/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:blind_shake/src/features/matching/presentation/providers/matching_providers.dart';
import 'package:blind_shake/src/core/services/location_service.dart';
import 'package:blind_shake/src/features/matching/data/services/matching_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isSearching = false;


  void _handleMatchingEvent(MatchingEvent event) {
    switch (event) {
      case MatchFoundEvent(:final match):
        setState(() => _isSearching = false);
        AppNavigation.toChat(context, match.matchId);
        break;
      case MatchingErrorEvent(:final message):
        setState(() => _isSearching = false);
        _showErrorDialog(message);
        break;
      case NoMatchFoundEvent():
        setState(() => _isSearching = false);
        _showNoMatchDialog();
        break;
      case ShakingStartedEvent():
        // User is shaking, continue with loading state
        break;
      case MatchingStoppedEvent():
        setState(() => _isSearching = false);
        break;
      default:
        break;
    }
  }

  Future<void> _handleShake() async {
    setState(() => _isSearching = true);

    try {
      // Use the enhanced matching controller for comprehensive checks
      final controller = ref.read(matchingControllerNotifierProvider.notifier);
      final success = await controller.initiateMatching();

      if (success && mounted) {
        // Navigate to matching screen to show progress
        AppNavigation.toMatching(context);
      } else {
        setState(() => _isSearching = false);
        // Error is handled by the controller and will be shown via listeners
      }
    } catch (error) {
      setState(() => _isSearching = false);
      _showErrorDialog('Failed to start matching: $error');
    }
  }

  Future<void> _handlePermissionRequest() async {
    final controller = ref.read(matchingControllerNotifierProvider.notifier);
    final granted = await controller.ensurePermissions();

    if (granted) {
      // Try matching again after permission is granted
      _handleShake();
    }
  }


  void _showErrorDialog(String message) {
    // Don't show duplicate dialogs
    if (ModalRoute.of(context)?.isCurrent != true) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Error',
          style: AppTypography.titleLarge.copyWith(color: AppColors.error),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 16),
            // Add helpful suggestions based on error type
            if (message.contains('location') || message.contains('konum'))
              Text(
                'Suggestion: Check location settings and permissions',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            if (message.contains('network') || message.contains('internet'))
              Text(
                'Suggestion: Check your internet connection',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            if (message.contains('permission') || message.contains('izin'))
              Text(
                'Suggestion: Grant necessary permissions in Settings',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        actions: [
          if (message.contains('permission') || message.contains('izin'))
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(locationPermissionNotifierProvider.notifier).openSettings();
              },
              child: Text(
                'Settings',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.primary),
              ),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
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
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'No Match Found',
          style: AppTypography.titleLarge,
        ),
        content: Text(
          'No one is currently shaking nearby. Try again in a few moments or move to a different location.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
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

  void _showSetupDialog() {
    final matchingStatus = ref.read(matchingStatusNotifierProvider);

    String title = 'Setup Required';
    String content = 'Please complete setup to start matching:';
    List<String> issues = [];

    if (matchingStatus.permissionStatus != LocationPermissionStatus.granted) {
      issues.add('• Location permission needed');
    }

    if (!matchingStatus.locationServiceEnabled) {
      issues.add('• Location services must be enabled');
    }

    content += '\n\n${issues.join('\n')}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          title,
          style: AppTypography.titleLarge,
        ),
        content: Text(
          content,
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (matchingStatus.permissionStatus != LocationPermissionStatus.granted) {
                await _handlePermissionRequest();
              } else if (!matchingStatus.locationServiceEnabled) {
                await ref.read(locationPermissionNotifierProvider.notifier).openSettings();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              'Fix Setup',
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu() {
    final user = ref.read(currentUserProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user != null) ...[
              CircleAvatar(
                radius: 32,
                backgroundImage: user.photoURL != null
                    ? NetworkImage(user.photoURL!)
                    : null,
                backgroundColor: AppColors.primary,
                child: user.photoURL == null
                    ? Text(
                        user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase()
                            : 'U',
                        style: AppTypography.headlineMedium.copyWith(
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user.displayName,
                style: AppTypography.titleLarge,
              ),
              Text(
                user.email,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
            ],
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.primary),
              title: Text('Ayarlar', style: AppTypography.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                AppNavigation.toSettings(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text(
                'Çıkış Yap',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                ref.read(authNotifierProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    // Listen to matching events
    ref.listen(matchingEventsProvider, (previous, next) {
      next.when(
        data: (event) => _handleMatchingEvent(event),
        loading: () {},
        error: (error, _) => _showErrorDialog('Matching error: $error'),
      );
    });

    // Listen to errors from the enhanced controller
    ref.listen(matchingErrorNotifierProvider, (previous, next) {
      if (next != null && mounted) {
        setState(() => _isSearching = false);
        _showErrorDialog(next);
      }
    });

    // Listen to comprehensive matching status
    ref.listen(matchingStatusNotifierProvider, (previous, next) {
      if (mounted && next.lastError != null) {
        setState(() => _isSearching = false);
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [AppColors.surface, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BlindShake', style: AppTypography.headlineMedium),
                        Text(
                          'Salla ve Eşleş',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.accent),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _showProfileMenu,
                      child: CircleAvatar(
                        backgroundColor: AppColors.surfaceLight,
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? Icon(
                                Icons.person_outline,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Consumer(
                builder: (context, ref, child) {
                  final matchingStatus = ref.watch(matchingStatusNotifierProvider);
                  final isReady = matchingStatus.permissionStatus == LocationPermissionStatus.granted &&
                                 matchingStatus.locationServiceEnabled;

                  return ShakeButton(
                    onPressed: isReady ? _handleShake : _showSetupDialog,
                    isSearching: _isSearching || matchingStatus.state != MatchingState.idle,
                  );
                },
              ),
              const SizedBox(height: 40),
              Consumer(
                builder: (context, ref, child) {
                  final matchingStatus = ref.watch(matchingStatusNotifierProvider);
                  final matchingStatusNotifier = ref.read(matchingStatusNotifierProvider.notifier);
                  final isReady = matchingStatus.permissionStatus == LocationPermissionStatus.granted &&
                                 matchingStatus.locationServiceEnabled;

                  String message = matchingStatusNotifier.statusMessage;

                  // Override with loading state if needed
                  if (_isSearching && matchingStatus.state == MatchingState.idle) {
                    message = 'Starting matching...';
                  }

                  return Column(
                    children: [
                      Text(
                        message,
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (!isReady && !_isSearching) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Check location permissions and services',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.surfaceLight),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.accent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Eşleştiğinde 15 dakika anonim kalacaksınız. Sonrasında karar sizin!',
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
