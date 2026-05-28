import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/cache/cache_keys.dart';
import '../../../../core/providers/cache_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../shared/models/paginated_response.dart';
import '../../data/products_remote_source.dart';
import '../../data/products_repository.dart';
import '../../domain/i_products_repository.dart';
import '../../domain/product_models.dart';

part 'products_provider.g.dart';

@riverpod
ProductsRemoteSource productsRemoteSource(Ref ref) =>
    ProductsRemoteSource(ref.read(dioProvider));

@riverpod
IProductsRepository productsRepository(Ref ref) =>
    ProductsRepository(ref.read(productsRemoteSourceProvider));

/// Cached first-page products (default sort, no filters).
/// Pages 2+ and filtered views fetch directly from the repository.
@Riverpod(keepAlive: true)
class ProductsNotifier extends _$ProductsNotifier {
  static const _ttl = Duration(minutes: 10);

  @override
  Future<PaginatedResponse<Product>> build() async {
    final cache = ref.read(cacheServiceProvider);

    final cached = cache.get<PaginatedResponse<Product>>(
      CacheKeys.productsPage1,
      fromJson: (j) =>
          PaginatedResponse.fromJson(j, Product.fromJson),
      maxAge: _ttl,
    );

    if (cached != null) {
      Future.microtask(_backgroundRefresh);
      return cached;
    }

    final stale = cache.getIgnoringTtl<PaginatedResponse<Product>>(
      CacheKeys.productsPage1,
      fromJson: (j) => PaginatedResponse.fromJson(j, Product.fromJson),
    );
    if (stale != null) {
      Future.microtask(_backgroundRefresh);
      return stale;
    }

    return _fetchAndCache();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchAndCache);
  }

  DateTime? get lastUpdated =>
      ref.read(cacheServiceProvider).getLastUpdated(CacheKeys.productsPage1);

  Future<void> _backgroundRefresh() async {
    try {
      final fresh = await _fetchAndCache();
      state = AsyncValue.data(fresh);
    } catch (_) {}
  }

  Future<PaginatedResponse<Product>> _fetchAndCache() async {
    final data = await ref
        .read(productsRepositoryProvider)
        .getProducts(page: 1, limit: 20);
    await ref.read(cacheServiceProvider).put(
          CacheKeys.productsPage1,
          data,
          toJson: (d) => d.toJson((p) => p.toJson()),
        );
    return data;
  }
}

@riverpod
Future<int> inactiveCount(Ref ref) async {
  final res = await ref
      .read(productsRepositoryProvider)
      .getProducts(status: 'inactive', limit: 1);
  return res.total;
}

@riverpod
Future<Product> productDetail(Ref ref, int id) =>
    ref.read(productsRepositoryProvider).getProduct(id);

/// Categories cached for 2 hours — rarely changes.
@Riverpod(keepAlive: true)
class CategoriesNotifier extends _$CategoriesNotifier {
  static const _ttl = Duration(hours: 2);

  @override
  Future<List<Category>> build() async {
    final cache = ref.read(cacheServiceProvider);

    final cached = cache.get<List<Category>>(
      CacheKeys.categories,
      fromJson: (j) => (j['items'] as List)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
      maxAge: _ttl,
    );

    if (cached != null) {
      Future.microtask(_backgroundRefresh);
      return cached;
    }

    return _fetchAndCache();
  }

  Future<void> _backgroundRefresh() async {
    try {
      final fresh = await _fetchAndCache();
      state = AsyncValue.data(fresh);
    } catch (_) {}
  }

  Future<List<Category>> _fetchAndCache() async {
    final data =
        await ref.read(productsRepositoryProvider).getCategories();
    await ref.read(cacheServiceProvider).put(
          CacheKeys.categories,
          data,
          toJson: (list) => {
            'items': list.map((c) => c.toJson()).toList(),
          },
        );
    return data;
  }
}

// Keep the old manual provider as an alias for backwards compat with existing
// widgets that already watch categoriesProvider.
final categoriesProvider = FutureProvider<List<Category>>(
    (ref) => ref.watch(categoriesNotifierProvider.future));
