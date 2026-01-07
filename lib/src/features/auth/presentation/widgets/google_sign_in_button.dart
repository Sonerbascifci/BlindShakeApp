import 'package:flutter/material.dart';
import 'package:blind_shake/src/app/theme/app_colors.dart';
import 'package:blind_shake/src/app/theme/app_typography.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.surface.withValues(alpha: 0.6),
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppColors.surfaceLight,
              width: 1,
            ),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google Logo
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Image.asset(
                      'assets/images/google_logo.png',
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to a simple icon if image is not found
                        return const Icon(
                          Icons.g_mobiledata,
                          size: 24,
                          color: AppColors.primary,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Button Text
                  Text(
                    'Google ile Giriş Yap',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}