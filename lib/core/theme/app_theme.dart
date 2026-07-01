import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        background: AppColorsDark.background,
        surface: AppColorsDark.surface,
        surface2: AppColorsDark.surface2,
        surface3: AppColorsDark.surface3,
        border: AppColorsDark.border,
        borderHover: AppColorsDark.borderHover,
        textPrimary: AppColorsDark.textPrimary,
        textMuted: AppColorsDark.textMuted,
        textDim: AppColorsDark.textDim,
        onBackground: AppColorsDark.onBackground,
        onSurface: AppColorsDark.onSurface,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        secondaryContainer: const Color(0xFF1D4ED8),
        onSecondaryContainer: const Color(0xFFBFDBFE),
        tertiaryContainer: const Color(0xFF7E22CE),
        onTertiaryContainer: const Color(0xFFF3E8FF),
        onPrimaryContainer: const Color(0xFFCFFAFE),
        inverseSurface: AppColorsDark.textPrimary,
        onInverseSurface: AppColorsDark.background,
        snackBarBackground: AppColorsDark.textPrimary,
        snackBarContentColor: AppColorsDark.background,
      );

  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        background: AppColorsLight.background,
        surface: AppColorsLight.surface,
        surface2: AppColorsLight.surface2,
        surface3: AppColorsLight.surface3,
        border: AppColorsLight.border,
        borderHover: AppColorsLight.borderHover,
        textPrimary: AppColorsLight.textPrimary,
        textMuted: AppColorsLight.textMuted,
        textDim: AppColorsLight.textDim,
        onBackground: AppColorsLight.onBackground,
        onSurface: AppColorsLight.onSurface,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        secondaryContainer: const Color(0xFFBFDBFE),
        onSecondaryContainer: const Color(0xFF1D4ED8),
        tertiaryContainer: const Color(0xFFF3E8FF),
        onTertiaryContainer: const Color(0xFF7E22CE),
        onPrimaryContainer: const Color(0xFF083344),
        inverseSurface: AppColorsLight.textPrimary,
        onInverseSurface: AppColorsLight.background,
        snackBarBackground: AppColorsLight.textPrimary,
        snackBarContentColor: AppColorsLight.background,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surface2,
    required Color surface3,
    required Color border,
    required Color borderHover,
    required Color textPrimary,
    required Color textMuted,
    required Color textDim,
    required Color onBackground,
    required Color onSurface,
    required Color onSecondary,
    required Color onTertiary,
    required Color secondaryContainer,
    required Color onSecondaryContainer,
    required Color tertiaryContainer,
    required Color onTertiaryContainer,
    required Color onPrimaryContainer,
    required Color inverseSurface,
    required Color onInverseSurface,
    required Color snackBarBackground,
    required Color snackBarContentColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,

      // Color Scheme
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryDark,
        onPrimaryContainer: onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surface3,
        onSurfaceVariant: textMuted,
        outline: border,
        outlineVariant: borderHover,
        inverseSurface: inverseSurface,
        onInverseSurface: onInverseSurface,
        inversePrimary: AppColors.primaryDark,
        shadow: Colors.black,
        scrim: Colors.black,
      ),

      // Typography
      textTheme: AppTypography.textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      // Elevated Button — Primary filled (cyan)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // Input / Search fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: GoogleFonts.outfit(fontSize: 14, color: textDim),
        labelStyle: GoogleFonts.outfit(fontSize: 13, color: textMuted),
        prefixIconColor: textMuted,
        suffixIconColor: textMuted,
      ),

      // Navigation Bar (M3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.primaryGlow,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return IconThemeData(color: textMuted, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            );
          }
          return GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textMuted,
          );
        }),
      ),

      // Bottom Navigation Bar (M2 legacy)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: textMuted,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w400),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: surface3,
        selectedColor: AppColors.primaryGlow,
        labelStyle: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w600),
        side: BorderSide(color: border),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: CircleBorder(),
        elevation: 4,
      ),

      // Progress Indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: surface3,
        circularTrackColor: surface3,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? AppColors.primary : textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? AppColors.primaryGlow : surface3;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? AppColors.primary : Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.onPrimary),
        side: BorderSide(color: border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.primaryGlow,
        textColor: textPrimary,
        iconColor: textMuted,
        selectedColor: AppColors.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: border),
        ),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),

      // Snack Bar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: snackBarBackground,
        contentTextStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: snackBarContentColor,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      // Icon
      iconTheme: IconThemeData(
        color: textMuted,
        size: 24,
      ),
    );
  }
}
