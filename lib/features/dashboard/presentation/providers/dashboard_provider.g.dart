// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardRemoteSourceHash() =>
    r'5791df3f820844a12203a75314b5c76cceb71c3a';

/// See also [dashboardRemoteSource].
@ProviderFor(dashboardRemoteSource)
final dashboardRemoteSourceProvider =
    AutoDisposeProvider<DashboardRemoteSource>.internal(
      dashboardRemoteSource,
      name: r'dashboardRemoteSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardRemoteSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardRemoteSourceRef =
    AutoDisposeProviderRef<DashboardRemoteSource>;
String _$dashboardRepositoryHash() =>
    r'9262c5d37bce21da5cba57dedd3442ed19881ee5';

/// See also [dashboardRepository].
@ProviderFor(dashboardRepository)
final dashboardRepositoryProvider =
    AutoDisposeProvider<IDashboardRepository>.internal(
      dashboardRepository,
      name: r'dashboardRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardRepositoryRef = AutoDisposeProviderRef<IDashboardRepository>;
String _$dashboardNotifierHash() => r'2dee6412f6855216280c36ee5cf903cb568ef98c';

/// See also [DashboardNotifier].
@ProviderFor(DashboardNotifier)
final dashboardNotifierProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardOverview>.internal(
      DashboardNotifier.new,
      name: r'dashboardNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DashboardNotifier = AsyncNotifier<DashboardOverview>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
