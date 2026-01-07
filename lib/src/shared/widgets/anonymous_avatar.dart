import 'package:flutter/material.dart';
import 'package:blind_shake/src/app/theme/app_colors.dart';

class AnonymousAvatar extends StatelessWidget {
  final double size;
  final bool glow;

  const AnonymousAvatar({
    super.key,
    this.size = 80,
    this.glow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceLight,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.person,
            size: size * 0.6,
            color: AppColors.textHint,
          ),
          Positioned(
            right: size * 0.1,
            top: size * 0.1,
            child: Icon(
              Icons.help_outline,
              size: size * 0.25,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
