import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

const List<FontFeature> _smallCaps = [FontFeature('smcp')];

class AppTextStyles {
  AppTextStyles._();

  static TextTheme get textTheme => GoogleFonts.poppinsTextTheme(
    const TextTheme(
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFeatures: _smallCaps,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFeatures: _smallCaps,
      ),
      displaySmall: TextStyle(
        fontFeatures: _smallCaps,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFeatures: _smallCaps,
      ),
      titleMedium: TextStyle(
        fontFeatures: _smallCaps,
      ),
      titleSmall: TextStyle(
        fontFeatures: _smallCaps,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textPrimary,
        fontFeatures: _smallCaps,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textSecondary,
        fontFeatures: _smallCaps,
      ),
      bodySmall: TextStyle(
        color: AppColors.textTertiary,
        fontFeatures: _smallCaps,
      ),
      labelLarge: TextStyle(
        fontFeatures: _smallCaps,
      ),
      labelMedium: TextStyle(
        fontFeatures: _smallCaps,
      ),
      labelSmall: TextStyle(
        fontFeatures: _smallCaps,
      ),
    ),
  );
}