// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productsRemoteSourceHash() =>
    r'42098bcfeeeb361050fb6c354144177afc18395d';

/// See also [productsRemoteSource].
@ProviderFor(productsRemoteSource)
final productsRemoteSourceProvider =
    AutoDisposeProvider<ProductsRemoteSource>.internal(
      productsRemoteSource,
      name: r'productsRemoteSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$productsRemoteSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductsRemoteSourceRef = AutoDisposeProviderRef<ProductsRemoteSource>;
String _$productsRepositoryHash() =>
    r'b766ee37122dd1947d6d01514a52ad578a6a514d';

/// See also [productsRepository].
@ProviderFor(productsRepository)
final productsRepositoryProvider =
    AutoDisposeProvider<IProductsRepository>.internal(
      productsRepository,
      name: r'productsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$productsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductsRepositoryRef = AutoDisposeProviderRef<IProductsRepository>;
String _$productsListHash() => r'98c07e78d5cbb92c2878dc0823e4090eb6dd99e2';

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

/// See also [productsList].
@ProviderFor(productsList)
const productsListProvider = ProductsListFamily();

/// See also [productsList].
class ProductsListFamily
    extends Family<AsyncValue<PaginatedResponse<Product>>> {
  /// See also [productsList].
  const ProductsListFamily();

  /// See also [productsList].
  ProductsListProvider call({int page = 1, String? status}) {
    return ProductsListProvider(page: page, status: status);
  }

  @override
  ProductsListProvider getProviderOverride(
    covariant ProductsListProvider provider,
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
  String? get name => r'productsListProvider';
}

/// See also [productsList].
class ProductsListProvider
    extends AutoDisposeFutureProvider<PaginatedResponse<Product>> {
  /// See also [productsList].
  ProductsListProvider({int page = 1, String? status})
    : this._internal(
        (ref) =>
            productsList(ref as ProductsListRef, page: page, status: status),
        from: productsListProvider,
        name: r'productsListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$productsListHash,
        dependencies: ProductsListFamily._dependencies,
        allTransitiveDependencies:
            ProductsListFamily._allTransitiveDependencies,
        page: page,
        status: status,
      );

  ProductsListProvider._internal(
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
    FutureOr<PaginatedResponse<Product>> Function(ProductsListRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductsListProvider._internal(
        (ref) => create(ref as ProductsListRef),
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
  AutoDisposeFutureProviderElement<PaginatedResponse<Product>> createElement() {
    return _ProductsListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductsListProvider &&
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
mixin ProductsListRef
    on AutoDisposeFutureProviderRef<PaginatedResponse<Product>> {
  /// The parameter `page` of this provider.
  int get page;

  /// The parameter `status` of this provider.
  String? get status;
}

class _ProductsListProviderElement
    extends AutoDisposeFutureProviderElement<PaginatedResponse<Product>>
    with ProductsListRef {
  _ProductsListProviderElement(super.provider);

  @override
  int get page => (origin as ProductsListProvider).page;
  @override
  String? get status => (origin as ProductsListProvider).status;
}

String _$productDetailHash() => r'620b9781155e38f1d5d02fd0e0bf19170e3a3b39';

/// See also [productDetail].
@ProviderFor(productDetail)
const productDetailProvider = ProductDetailFamily();

/// See also [productDetail].
class ProductDetailFamily extends Family<AsyncValue<Product>> {
  /// See also [productDetail].
  const ProductDetailFamily();

  /// See also [productDetail].
  ProductDetailProvider call(int id) {
    return ProductDetailProvider(id);
  }

  @override
  ProductDetailProvider getProviderOverride(
    covariant ProductDetailProvider provider,
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
  String? get name => r'productDetailProvider';
}

/// See also [productDetail].
class ProductDetailProvider extends AutoDisposeFutureProvider<Product> {
  /// See also [productDetail].
  ProductDetailProvider(int id)
    : this._internal(
        (ref) => productDetail(ref as ProductDetailRef, id),
        from: productDetailProvider,
        name: r'productDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$productDetailHash,
        dependencies: ProductDetailFamily._dependencies,
        allTransitiveDependencies:
            ProductDetailFamily._allTransitiveDependencies,
        id: id,
      );

  ProductDetailProvider._internal(
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
    FutureOr<Product> Function(ProductDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductDetailProvider._internal(
        (ref) => create(ref as ProductDetailRef),
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
  AutoDisposeFutureProviderElement<Product> createElement() {
    return _ProductDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductDetailProvider && other.id == id;
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
mixin ProductDetailRef on AutoDisposeFutureProviderRef<Product> {
  /// The parameter `id` of this provider.
  int get id;
}

class _ProductDetailProviderElement
    extends AutoDisposeFutureProviderElement<Product>
    with ProductDetailRef {
  _ProductDetailProviderElement(super.provider);

  @override
  int get id => (origin as ProductDetailProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
