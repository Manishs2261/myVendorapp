import 'package:flutter/material.dart';

/// Fixed dark-mode neutrals. Used directly by [AppTheme.darkTheme] (which must
/// stay dark regardless of the current global brightness) as well as via the
/// dynamic [AppColors] getters.
abstract final class AppColorsDark {
  static const Color background = Color(0xFF09090B);
  static const Color surface = Color(0xFF1C1C23);
  static const Color surface2 = Color(0xFF18181F);
  static const Color surface3 = Color(0xFF22222E);

  static const Color border = Color(0xFF2A2A35);
  static const Color borderHover = Color(0xFF3A3A48);

  static const Color textPrimary = Color(0xFFEEEEF5);
  static const Color textMuted = Color(0xFF7878A0);
  static const Color textDim = Color(0xFF3D3D5C);

  static const Color onBackground = Color(0xFFEEEEF5);
  static const Color onSurface = Color(0xFFEEEEF5);
}

/// Fixed light-mode neutrals. Used directly by [AppTheme.lightTheme] as well
/// as via the dynamic [AppColors] getters.
abstract final class AppColorsLight {
  static const Color background = Color(0xFFF5F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF0F0F3);
  static const Color surface3 = Color(0xFFE8E8ED);

  static const Color border = Color(0xFFDDDDE3);
  static const Color borderHover = Color(0xFFC8C8D2);

  static const Color textPrimary = Color(0xFF15151F);
  static const Color textMuted = Color(0xFF6B6B80);
  static const Color textDim = Color(0xFFA8A8B8);

  static const Color onBackground = Color(0xFF15151F);
  static const Color onSurface = Color(0xFF15151F);
}

abstract final class AppColors {
  static bool _isDark = true;

  /// Called by the theme provider whenever the effective brightness changes.
  static void syncBrightness(bool isDark) {
    _isDark = isDark;
  }

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
  static Color get background => _isDark ? AppColorsDark.background : AppColorsLight.background;
  static Color get surface => _isDark ? AppColorsDark.surface : AppColorsLight.surface;
  static Color get surface2 => _isDark ? AppColorsDark.surface2 : AppColorsLight.surface2;
  static Color get surface3 => _isDark ? AppColorsDark.surface3 : AppColorsLight.surface3;

  // Borders
  static Color get border => _isDark ? AppColorsDark.border : AppColorsLight.border;
  static Color get borderHover => _isDark ? AppColorsDark.borderHover : AppColorsLight.borderHover;

  // Text
  static Color get textPrimary => _isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
  static Color get textMuted => _isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
  static Color get textDim => _isDark ? AppColorsDark.textDim : AppColorsLight.textDim;

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0x1A10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0x1AF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0x1AEF4444);

  // On-color variants
  static const Color onPrimary = Color(0xFF000000);
  static Color get onBackground => _isDark ? AppColorsDark.onBackground : AppColorsLight.onBackground;
  static Color get onSurface => _isDark ? AppColorsDark.onSurface : AppColorsLight.onSurface;
  static const Color onError = Color(0xFFFFFFFF);
}
