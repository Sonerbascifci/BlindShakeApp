import 'package:flutter/material.dart';
import 'package:blind_shake/src/app/theme/app_colors.dart';
import 'package:blind_shake/src/app/theme/app_typography.dart';
import 'package:blind_shake/src/shared/widgets/anonymous_avatar.dart';

class DecisionModal extends StatelessWidget {
  final VoidCallback onReveal;
  final VoidCallback onDecline;

  const DecisionModal({
    super.key,
    required this.onReveal,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const AnonymousAvatar(size: 100),
          const SizedBox(height: 16),
          Text(
            '15 DAKİKA DOLDU!',
            style: AppTypography.headlineMedium.copyWith(color: AppColors.accent),
          ),
          const SizedBox(height: 8),
          Text(
            'Bilinmeyen Kişi ile sohbetin sona erdi. Devam etmek istiyor musun?',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'HAYIR',
                    style: AppTypography.labelLarge.copyWith(color: AppColors.error),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: onReveal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('EVET'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
