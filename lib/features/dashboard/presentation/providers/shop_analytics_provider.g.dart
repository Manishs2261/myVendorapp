// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_analytics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shopAnalyticsRemoteSourceHash() =>
    r'b5ef74b143e1a80f90154cc0acd6b681dba77375';

/// See also [shopAnalyticsRemoteSource].
@ProviderFor(shopAnalyticsRemoteSource)
final shopAnalyticsRemoteSourceProvider =
    AutoDisposeProvider<ShopAnalyticsRemoteSource>.internal(
      shopAnalyticsRemoteSource,
      name: r'shopAnalyticsRemoteSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$shopAnalyticsRemoteSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShopAnalyticsRemoteSourceRef =
    AutoDisposeProviderRef<ShopAnalyticsRemoteSource>;
String _$shopAnalyticsNotifierHash() =>
    r'dc5a9cf88f7d354c81788fbe0cf1571c3dfc66d7';

/// See also [ShopAnalyticsNotifier].
@ProviderFor(ShopAnalyticsNotifier)
final shopAnalyticsNotifierProvider =
    AsyncNotifierProvider<ShopAnalyticsNotifier, ShopAnalytics>.internal(
      ShopAnalyticsNotifier.new,
      name: r'shopAnalyticsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$shopAnalyticsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ShopAnalyticsNotifier = AsyncNotifier<ShopAnalytics>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
