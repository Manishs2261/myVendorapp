// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ordersRemoteSourceHash() =>
    r'885c28d58c06097ff7cea8eff17429f313cce002';

/// See also [ordersRemoteSource].
@ProviderFor(ordersRemoteSource)
final ordersRemoteSourceProvider =
    AutoDisposeProvider<OrdersRemoteSource>.internal(
      ordersRemoteSource,
      name: r'ordersRemoteSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ordersRemoteSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrdersRemoteSourceRef = AutoDisposeProviderRef<OrdersRemoteSource>;
String _$ordersRepositoryHash() => r'5f006037d8f7817e5b806d4885a8ebed6e0d8be4';

/// See also [ordersRepository].
@ProviderFor(ordersRepository)
final ordersRepositoryProvider =
    AutoDisposeProvider<IOrdersRepository>.internal(
      ordersRepository,
      name: r'ordersRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ordersRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrdersRepositoryRef = AutoDisposeProviderRef<IOrdersRepository>;
String _$orderDetailHash() => r'9ccae188eeb93f5a46ab857e4f704148bd71d5fe';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [orderDetail].
@ProviderFor(orderDetail)
const orderDetailProvider = OrderDetailFamily();

/// See also [orderDetail].
class OrderDetailFamily extends Family<AsyncValue<Order>> {
  /// See also [orderDetail].
  const OrderDetailFamily();

  /// See also [orderDetail].
  OrderDetailProvider call(int id) {
    return OrderDetailProvider(id);
  }

  @override
  OrderDetailProvider getProviderOverride(
    covariant OrderDetailProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderDetailProvider';
}

/// See also [orderDetail].
class OrderDetailProvider extends AutoDisposeFutureProvider<Order> {
  /// See also [orderDetail].
  OrderDetailProvider(int id)
    : this._internal(
        (ref) => orderDetail(ref as OrderDetailRef, id),
        from: orderDetailProvider,
        name: r'orderDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$orderDetailHash,
        dependencies: OrderDetailFamily._dependencies,
        allTransitiveDependencies: OrderDetailFamily._allTransitiveDependencies,
        id: id,
      );

  OrderDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<Order> Function(OrderDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrderDetailProvider._internal(
        (ref) => create(ref as OrderDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Order> createElement() {
    return _OrderDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderDetailRef on AutoDisposeFutureProviderRef<Order> {
  /// The parameter `id` of this provider.
  int get id;
}

class _OrderDetailProviderElement
    extends AutoDisposeFutureProviderElement<Order>
    with OrderDetailRef {
  _OrderDetailProviderElement(super.provider);

  @override
  int get id => (origin as OrderDetailProvider).id;
}

String _$ordersNotifierHash() => r'0737bba845eae3e1eea7d937a55f3a5f396fadf5';

/// Cached page-1 orders (no status filter). Pages 2+ and filtered views fetch
/// directly from the repository.
///
/// Copied from [OrdersNotifier].
@ProviderFor(OrdersNotifier)
final ordersNotifierProvider =
    AsyncNotifierProvider<OrdersNotifier, PaginatedResponse<Order>>.internal(
      OrdersNotifier.new,
      name: r'ordersNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ordersNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OrdersNotifier = AsyncNotifier<PaginatedResponse<Order>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
