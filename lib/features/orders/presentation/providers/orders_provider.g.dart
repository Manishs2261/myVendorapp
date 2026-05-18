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
String _$ordersListHash() => r'157e5f93241839577596320aec40cbabcd29887b';

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

/// See also [ordersList].
@ProviderFor(ordersList)
const ordersListProvider = OrdersListFamily();

/// See also [ordersList].
class OrdersListFamily extends Family<AsyncValue<PaginatedResponse<Order>>> {
  /// See also [ordersList].
  const OrdersListFamily();

  /// See also [ordersList].
  OrdersListProvider call({int page = 1, String? status}) {
    return OrdersListProvider(page: page, status: status);
  }

  @override
  OrdersListProvider getProviderOverride(
    covariant OrdersListProvider provider,
  ) {
    return call(page: provider.page, status: provider.status);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'ordersListProvider';
}

/// See also [ordersList].
class OrdersListProvider
    extends AutoDisposeFutureProvider<PaginatedResponse<Order>> {
  /// See also [ordersList].
  OrdersListProvider({int page = 1, String? status})
    : this._internal(
        (ref) => ordersList(ref as OrdersListRef, page: page, status: status),
        from: ordersListProvider,
        name: r'ordersListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$ordersListHash,
        dependencies: OrdersListFamily._dependencies,
        allTransitiveDependencies: OrdersListFamily._allTransitiveDependencies,
        page: page,
        status: status,
      );

  OrdersListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.page,
    required this.status,
  }) : super.internal();

  final int page;
  final String? status;

  @override
  Override overrideWith(
    FutureOr<PaginatedResponse<Order>> Function(OrdersListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrdersListProvider._internal(
        (ref) => create(ref as OrdersListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        page: page,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<PaginatedResponse<Order>> createElement() {
    return _OrdersListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrdersListProvider &&
        other.page == page &&
        other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrdersListRef on AutoDisposeFutureProviderRef<PaginatedResponse<Order>> {
  /// The parameter `page` of this provider.
  int get page;

  /// The parameter `status` of this provider.
  String? get status;
}

class _OrdersListProviderElement
    extends AutoDisposeFutureProviderElement<PaginatedResponse<Order>>
    with OrdersListRef {
  _OrdersListProviderElement(super.provider);

  @override
  int get page => (origin as OrdersListProvider).page;
  @override
  String? get status => (origin as OrdersListProvider).status;
}

String _$orderDetailHash() => r'9ccae188eeb93f5a46ab857e4f704148bd71d5fe';

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

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
