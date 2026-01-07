import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blind_shake/src/app/theme/app_colors.dart';
import 'package:blind_shake/src/app/theme/app_typography.dart';

class ShakeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isSearching;

  const ShakeButton({
    super.key,
    required this.onPressed,
    this.isSearching = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSearching ? null : onPressed,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: isSearching
              ? const CircularProgressIndicator(color: Colors.white)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.vibration, size: 48, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      'SALLA',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
        ),
      ).animate(
        onPlay: (controller) => controller.repeat(reverse: true),
      ).scale(
        begin: const Offset(1, 1),
        end: const Offset(1.05, 1.05),
        duration: 2.seconds,
        curve: Curves.easeInOut,
      ).shimmer(
        duration: 3.seconds,
        color: Colors.white.withValues(alpha: 0.2),
      ),
    );
  }
}
