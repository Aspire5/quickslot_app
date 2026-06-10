import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme.copyWith(
          displayLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
          titleLarge: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
          bodyLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal, color: AppColors.textPrimaryLight),
          bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal, color: AppColors.textSecondaryLight),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondaryDark,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
          titleLarge: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
          bodyLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal, color: AppColors.textPrimaryDark),
          bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal, color: AppColors.textSecondaryDark),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}
