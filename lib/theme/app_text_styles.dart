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
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFeatures: _smallCaps,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFeatures: _smallCaps,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontFeatures: _smallCaps,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFeatures: _smallCaps,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontFeatures: _smallCaps,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontFeatures: _smallCaps,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
        fontFeatures: _smallCaps,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        fontFeatures: _smallCaps,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: AppColors.textTertiary,
        fontFeatures: _smallCaps,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontFeatures: _smallCaps,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontFeatures: _smallCaps,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontFeatures: _smallCaps,
      ),
    ),
  );
}