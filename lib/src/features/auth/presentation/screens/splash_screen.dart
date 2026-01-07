import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blind_shake/src/app/theme/app_colors.dart';
import 'package:blind_shake/src/app/theme/app_typography.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo with animation
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
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms)
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.05, 1.05),
                  duration: 1000.ms,
                  curve: Curves.easeInOut,
                )
                .then()
                .scale(
                  begin: const Offset(1.05, 1.05),
                  end: const Offset(1.0, 1.0),
                  duration: 1000.ms,
                  curve: Curves.easeInOut,
                ),

            const SizedBox(height: 32),

            // App Title
            Text(
              'BlindShake',
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(duration: 800.ms).slideY(
                  begin: 0.3,
                  end: 0,
                  duration: 800.ms,
                  curve: Curves.easeOut,
                ),

            const SizedBox(height: 16),

            // Loading indicator
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ).animate(delay: 500.ms).fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}