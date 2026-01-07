import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blind_shake/src/app/theme/app_colors.dart';
import 'package:blind_shake/src/app/theme/app_typography.dart';
import 'package:blind_shake/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:blind_shake/src/features/auth/presentation/widgets/google_sign_in_button.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    // Show error dialog if there's an error
    if (authState.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(context, authState.errorMessage ?? 'An error occurred');
        ref.read(authNotifierProvider.notifier).clearError();
      });
    }

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
              const Spacer(flex: 2),

              // App Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.vibration,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // App Title
              Text(
                'BlindShake',
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // App Subtitle
              Text(
                'Salla ve Eşleş',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 16),

              // App Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  'Anonim olarak çevrenizdeki kişilerle eşleş, 15 dakika sohbet et, sonrasında kimliğinizi açıklamaya karar ver.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // Sign In Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      'Başlamak için giriş yapın',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Google Sign In Button
                    GoogleSignInButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
                      isLoading: authState.isLoading,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Privacy Note
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  'Giriş yaparak Kullanım Şartları ve Gizlilik Politikası\'nı kabul etmiş olursunuz.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Hata',
          style: AppTypography.titleLarge.copyWith(color: AppColors.error),
        ),
        content: Text(
          message,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tamam',
              style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}