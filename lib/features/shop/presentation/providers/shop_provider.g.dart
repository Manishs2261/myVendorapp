// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shopRemoteSourceHash() => r'4fda915aa9c258082f5558e7130b6bacb1d04358';

/// See also [shopRemoteSource].
@ProviderFor(shopRemoteSource)
final shopRemoteSourceProvider = AutoDisposeProvider<ShopRemoteSource>.internal(
  shopRemoteSource,
  name: r'shopRemoteSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shopRemoteSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShopRemoteSourceRef = AutoDisposeProviderRef<ShopRemoteSource>;
String _$shopRepositoryHash() => r'3c3ae4ee798b73a87e436d6670df0e9cd76943f9';

/// See also [shopRepository].
@ProviderFor(shopRepository)
final shopRepositoryProvider = AutoDisposeProvider<IShopRepository>.internal(
  shopRepository,
  name: r'shopRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shopRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShopRepositoryRef = AutoDisposeProviderRef<IShopRepository>;
String _$shopReviewStatsHash() => r'5b6552c0fffd48225e6af5eb746503caeff6cbf9';

/// See also [shopReviewStats].
@ProviderFor(shopReviewStats)
final shopReviewStatsProvider =
    AutoDisposeFutureProvider<ShopReviewStats>.internal(
      shopReviewStats,
      name: r'shopReviewStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$shopReviewStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShopReviewStatsRef = AutoDisposeFutureProviderRef<ShopReviewStats>;
String _$shopNotifierHash() => r'2dbc69cca7dba19d294c4750526605a297bea0f0';

/// See also [ShopNotifier].
@ProviderFor(ShopNotifier)
final shopNotifierProvider = AsyncNotifierProvider<ShopNotifier, Shop>.internal(
  ShopNotifier.new,
  name: r'shopNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shopNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShopNotifier = AsyncNotifier<Shop>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
