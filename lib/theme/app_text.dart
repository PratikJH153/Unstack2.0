import 'package:flutter/material.dart';
import 'package:unstack/theme/app_colors.dart';
import 'package:unstack/theme/app_theme.dart';

class AppTextStyles {
  static const String fontFamily = 'Montserrat';

  // Heading styles
  static TextStyle get xlargeTitle => TextStyle(
        fontFamily: fontFamily,
        fontSize: 60 * ResponsiveUtils.fontScale,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        height: 1.25,
      );
  static TextStyle get largeTitle => TextStyle(
        fontFamily: fontFamily,
        fontSize: 50 * ResponsiveUtils.fontScale,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.25,
      );
  static TextStyle get inputTitle => TextStyle(
        fontFamily: fontFamily,
        fontSize: 32 * ResponsiveUtils.fontScale,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.25,
      );

  static TextStyle get h1 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 30 * ResponsiveUtils.fontScale,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.25,
      );
  static TextStyle get titleText => TextStyle(
        fontFamily: fontFamily,
        fontSize: 26 * ResponsiveUtils.fontScale,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.25,
      );
  static TextStyle get h2 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 24 * ResponsiveUtils.fontScale,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.25,
      );

  static TextStyle get h3 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 20 * ResponsiveUtils.fontScale,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.25,
      );

  // Body styles
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18 * ResponsiveUtils.fontScale,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16 * ResponsiveUtils.fontScale,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14 * ResponsiveUtils.fontScale,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  // Button styles
  static TextStyle get buttonLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16 * ResponsiveUtils.fontScale,
        fontWeight: FontWeight.w600,
        color: AppColors.textInverse,
      );

  static TextStyle get buttonMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14 * ResponsiveUtils.fontScale,
        fontWeight: FontWeight.w500,
        color: AppColors.textInverse,
      );

  // Caption styles
  static TextStyle get caption => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12 * ResponsiveUtils.fontScale,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 1.5,
      );
}
