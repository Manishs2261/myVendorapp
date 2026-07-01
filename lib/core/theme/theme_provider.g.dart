// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themeModeNotifierHash() => r'd3fad2ee22d433e68d971518b01aa0860f7aee25';

/// See also [ThemeModeNotifier].
@ProviderFor(ThemeModeNotifier)
final themeModeNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ThemeModeNotifier, ThemeMode>.internal(
      ThemeModeNotifier.new,
      name: r'themeModeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$themeModeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ThemeModeNotifier = AutoDisposeAsyncNotifier<ThemeMode>;
String _$isDarkModeHash() => r'd64b5db5aade315372567c5b78b4f57a5320690c';

/// Resolves the persisted [ThemeMode] against the current platform brightness
/// (for `system`) and keeps [AppColors] in sync so the static color getters
/// reflect it immediately. Screens watch this to know when to rebuild.
///
/// Copied from [IsDarkMode].
@ProviderFor(IsDarkMode)
final isDarkModeProvider =
    AutoDisposeNotifierProvider<IsDarkMode, bool>.internal(
      IsDarkMode.new,
      name: r'isDarkModeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$isDarkModeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$IsDarkMode = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
