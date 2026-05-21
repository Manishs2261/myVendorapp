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
String _$productsListHash() => r'3794b55734c020b60e74bd7147b5435b500d2f00';

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
  ProductsListProvider call({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    int? categoryId,
    String? stockFilter,
    String sortBy = 'recent',
    bool discountOnly = false,
    double? minPrice,
    double? maxPrice,
    int? minStock,
    int? maxStock,
  }) {
    return ProductsListProvider(
      page: page,
      limit: limit,
      search: search,
      status: status,
      categoryId: categoryId,
      stockFilter: stockFilter,
      sortBy: sortBy,
      discountOnly: discountOnly,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minStock: minStock,
      maxStock: maxStock,
    );
  }

  @override
  ProductsListProvider getProviderOverride(
    covariant ProductsListProvider provider,
  ) {
    return call(
      page: provider.page,
      limit: provider.limit,
      search: provider.search,
      status: provider.status,
      categoryId: provider.categoryId,
      stockFilter: provider.stockFilter,
      sortBy: provider.sortBy,
      discountOnly: provider.discountOnly,
      minPrice: provider.minPrice,
      maxPrice: provider.maxPrice,
      minStock: provider.minStock,
      maxStock: provider.maxStock,
    );
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
  ProductsListProvider({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    int? categoryId,
    String? stockFilter,
    String sortBy = 'recent',
    bool discountOnly = false,
    double? minPrice,
    double? maxPrice,
    int? minStock,
    int? maxStock,
  }) : this._internal(
         (ref) => productsList(
           ref as ProductsListRef,
           page: page,
           limit: limit,
           search: search,
           status: status,
           categoryId: categoryId,
           stockFilter: stockFilter,
           sortBy: sortBy,
           discountOnly: discountOnly,
           minPrice: minPrice,
           maxPrice: maxPrice,
           minStock: minStock,
           maxStock: maxStock,
         ),
         from: productsListProvider,
         name: r'productsListProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$productsListHash,
         dependencies: ProductsListFamily._dependencies,
         allTransitiveDependencies:
             ProductsListFamily._allTransitiveDependencies,
         page: page,
         limit: limit,
         search: search,
         status: status,
         categoryId: categoryId,
         stockFilter: stockFilter,
         sortBy: sortBy,
         discountOnly: discountOnly,
         minPrice: minPrice,
         maxPrice: maxPrice,
         minStock: minStock,
         maxStock: maxStock,
       );

  ProductsListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.page,
    required this.limit,
    required this.search,
    required this.status,
    required this.categoryId,
    required this.stockFilter,
    required this.sortBy,
    required this.discountOnly,
    required this.minPrice,
    required this.maxPrice,
    required this.minStock,
    required this.maxStock,
  }) : super.internal();

  final int page;
  final int limit;
  final String? search;
  final String? status;
  final int? categoryId;
  final String? stockFilter;
  final String sortBy;
  final bool discountOnly;
  final double? minPrice;
  final double? maxPrice;
  final int? minStock;
  final int? maxStock;

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
        limit: limit,
        search: search,
        status: status,
        categoryId: categoryId,
        stockFilter: stockFilter,
        sortBy: sortBy,
        discountOnly: discountOnly,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minStock: minStock,
        maxStock: maxStock,
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
        other.limit == limit &&
        other.search == search &&
        other.status == status &&
        other.categoryId == categoryId &&
        other.stockFilter == stockFilter &&
        other.sortBy == sortBy &&
        other.discountOnly == discountOnly &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice &&
        other.minStock == minStock &&
        other.maxStock == maxStock;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);
    hash = _SystemHash.combine(hash, search.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);
    hash = _SystemHash.combine(hash, stockFilter.hashCode);
    hash = _SystemHash.combine(hash, sortBy.hashCode);
    hash = _SystemHash.combine(hash, discountOnly.hashCode);
    hash = _SystemHash.combine(hash, minPrice.hashCode);
    hash = _SystemHash.combine(hash, maxPrice.hashCode);
    hash = _SystemHash.combine(hash, minStock.hashCode);
    hash = _SystemHash.combine(hash, maxStock.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductsListRef
    on AutoDisposeFutureProviderRef<PaginatedResponse<Product>> {
  /// The parameter `page` of this provider.
  int get page;

  /// The parameter `limit` of this provider.
  int get limit;

  /// The parameter `search` of this provider.
  String? get search;

  /// The parameter `status` of this provider.
  String? get status;

  /// The parameter `categoryId` of this provider.
  int? get categoryId;

  /// The parameter `stockFilter` of this provider.
  String? get stockFilter;

  /// The parameter `sortBy` of this provider.
  String get sortBy;

  /// The parameter `discountOnly` of this provider.
  bool get discountOnly;

  /// The parameter `minPrice` of this provider.
  double? get minPrice;

  /// The parameter `maxPrice` of this provider.
  double? get maxPrice;

  /// The parameter `minStock` of this provider.
  int? get minStock;

  /// The parameter `maxStock` of this provider.
  int? get maxStock;
}

class _ProductsListProviderElement
    extends AutoDisposeFutureProviderElement<PaginatedResponse<Product>>
    with ProductsListRef {
  _ProductsListProviderElement(super.provider);

  @override
  int get page => (origin as ProductsListProvider).page;
  @override
  int get limit => (origin as ProductsListProvider).limit;
  @override
  String? get search => (origin as ProductsListProvider).search;
  @override
  String? get status => (origin as ProductsListProvider).status;
  @override
  int? get categoryId => (origin as ProductsListProvider).categoryId;
  @override
  String? get stockFilter => (origin as ProductsListProvider).stockFilter;
  @override
  String get sortBy => (origin as ProductsListProvider).sortBy;
  @override
  bool get discountOnly => (origin as ProductsListProvider).discountOnly;
  @override
  double? get minPrice => (origin as ProductsListProvider).minPrice;
  @override
  double? get maxPrice => (origin as ProductsListProvider).maxPrice;
  @override
  int? get minStock => (origin as ProductsListProvider).minStock;
  @override
  int? get maxStock => (origin as ProductsListProvider).maxStock;
}

String _$inactiveCountHash() => r'b9c96441230e735eff44e68fb20165b4a2a7a253';

/// See also [inactiveCount].
@ProviderFor(inactiveCount)
final inactiveCountProvider = AutoDisposeFutureProvider<int>.internal(
  inactiveCount,
  name: r'inactiveCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inactiveCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InactiveCountRef = AutoDisposeFutureProviderRef<int>;
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
