import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary — Cyan #06B6D4
  static const Color primary = Color(0xFF06B6D4);
  static const Color primaryLight = Color(0xFF22D3EE);
  static const Color primaryDark = Color(0xFF0891B2);
  static const Color primaryGlow = Color(0x2606B6D4); // ~15% alpha

  // Secondary — Blue #3B82F6
  static const Color secondary = Color(0xFF3B82F6);
  static const Color secondaryLight = Color(0xFF60A5FA);
  static const Color secondaryDark = Color(0xFF2563EB);

  // Tertiary — Purple #A855F7
  static const Color tertiary = Color(0xFFA855F7);
  static const Color tertiaryLight = Color(0xFFBB77F8);
  static const Color tertiaryDark = Color(0xFF9333EA);
  static const Color tertiaryGlow = Color(0x1AA855F7); // ~10% alpha

  // Backgrounds & Surfaces
  static const Color background = Color(0xFF09090B);
  static const Color surface = Color(0xFF1C1C23);
  static const Color surface2 = Color(0xFF18181F);
  static const Color surface3 = Color(0xFF22222E);

  // Borders
  static const Color border = Color(0xFF2A2A35);
  static const Color borderHover = Color(0xFF3A3A48);

  // Text
  static const Color textPrimary = Color(0xFFEEEEF5);
  static const Color textMuted = Color(0xFF7878A0);
  static const Color textDim = Color(0xFF3D3D5C);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0x1A10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0x1AF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0x1AEF4444);

  // On-color variants
  static const Color onPrimary = Color(0xFF000000);
  static const Color onBackground = Color(0xFFEEEEF5);
  static const Color onSurface = Color(0xFFEEEEF5);
  static const Color onError = Color(0xFFFFFFFF);
}
