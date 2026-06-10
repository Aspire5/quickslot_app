import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand colors (Indigo theme)
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8F8AFF);
  static const Color primaryDark = Color(0xFF4B42D6);

  // Secondary colors (Cyan/Teal)
  static const Color secondary = Color(0xFF00F2FE);
  static const Color secondaryDark = Color(0xFF4FACFE);

  // Neutral backgrounds
  static const Color backgroundLight = Color(0xFFF8F9FD);
  static const Color backgroundDark = Color(0xFF090A0F);
  
  // Surfaces
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF131622);

  // Text
  static const Color textPrimaryLight = Color(0xFF1E202C);
  static const Color textSecondaryLight = Color(0xFF7A869A);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // State colors
  static const Color error = Color(0xFFFF4D4F);
  static const Color success = Color(0xFF52C41A);
  static const Color warning = Color(0xFFFAAD14);
  static const Color info = Color(0xFF1890FF);
}
