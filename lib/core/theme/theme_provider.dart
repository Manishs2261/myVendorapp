import 'dart:ui';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

part 'theme_provider.g.dart';

const _kThemeModeKey = 'theme_mode';

ThemeMode _decodeThemeMode(String? value) => switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

String _encodeThemeMode(ThemeMode mode) => switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeThemeMode(prefs.getString(_kThemeModeKey));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, _encodeThemeMode(mode));
    state = AsyncData(mode);
  }
}

/// Resolves the persisted [ThemeMode] against the current platform brightness
/// (for `system`) and keeps [AppColors] in sync so the static color getters
/// reflect it immediately. Screens watch this to know when to rebuild.
@riverpod
class IsDarkMode extends _$IsDarkMode {
  @override
  bool build() {
    final mode = ref.watch(themeModeNotifierProvider).valueOrNull ?? ThemeMode.system;
    final isDark = switch (mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => PlatformDispatcher.instance.platformBrightness == Brightness.dark,
    };
    AppColors.syncBrightness(isDark);
    return isDark;
  }
}
