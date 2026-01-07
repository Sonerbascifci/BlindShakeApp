import 'package:flutter/material.dart';

class AppColors {
  // Primary gradient
  static const primary = Color(0xFF6C63FF);
  static const primaryDark = Color(0xFF4A42D9);
  static const accent = Color(0xFFFF6B9D);
  
  // Background
  static const background = Color(0xFF0D0D1A);
  static const surface = Color(0xFF1A1A2E);
  static const surfaceLight = Color(0xFF252542);
  
  // Status
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFB74D);
  static const error = Color(0xFFEF5350);
  
  // Text
  static const textPrimary = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFFB0B0B0);
  static const textHint = Color(0xFF6B6B6B);

  // Gradients
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );

  static const darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, Color(0xFF16162D)],
  );
}
