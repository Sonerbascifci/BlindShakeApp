import 'package:flutter/material.dart';
import 'package:blind_shake/src/app/theme/app_colors.dart';
import 'package:blind_shake/src/app/theme/app_typography.dart';

class TimerWidget extends StatelessWidget {
  final Duration remaining;
  final double progress;

  const TimerWidget({
    super.key,
    required this.remaining,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: AppColors.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(
              remaining.inMinutes < 1 ? AppColors.error : AppColors.accent,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$minutes:$seconds',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              'REVEAL',
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 8,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
