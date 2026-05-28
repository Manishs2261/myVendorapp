import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/cache/cache_keys.dart';
import '../../../../core/providers/cache_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../shared/models/paginated_response.dart';
import '../../data/orders_remote_source.dart';
import '../../data/orders_repository.dart';
import '../../domain/i_orders_repository.dart';
import '../../domain/order_models.dart';

part 'orders_provider.g.dart';

@riverpod
OrdersRemoteSource ordersRemoteSource(Ref ref) =>
    OrdersRemoteSource(ref.read(dioProvider));

@riverpod
IOrdersRepository ordersRepository(Ref ref) =>
    OrdersRepository(ref.read(ordersRemoteSourceProvider));

/// Cached page-1 orders (no status filter). Pages 2+ and filtered views fetch
/// directly from the repository.
@Riverpod(keepAlive: true)
class OrdersNotifier extends _$OrdersNotifier {
  static const _ttl = Duration(minutes: 5);

  @override
  Future<PaginatedResponse<Order>> build() async {
    final cache = ref.read(cacheServiceProvider);

    final cached = cache.get<PaginatedResponse<Order>>(
      CacheKeys.ordersPage1,
      fromJson: (j) => PaginatedResponse.fromJson(j, Order.fromJson),
      maxAge: _ttl,
    );

    if (cached != null) {
      Future.microtask(_backgroundRefresh);
      return cached;
    }

    final stale = cache.getIgnoringTtl<PaginatedResponse<Order>>(
      CacheKeys.ordersPage1,
      fromJson: (j) => PaginatedResponse.fromJson(j, Order.fromJson),
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
      ref.read(cacheServiceProvider).getLastUpdated(CacheKeys.ordersPage1);

  Future<void> _backgroundRefresh() async {
    try {
      final fresh = await _fetchAndCache();
      state = AsyncValue.data(fresh);
    } catch (_) {}
  }

  Future<PaginatedResponse<Order>> _fetchAndCache() async {
    final data =
        await ref.read(ordersRepositoryProvider).getOrders(page: 1);
    await ref.read(cacheServiceProvider).put(
          CacheKeys.ordersPage1,
          data,
          toJson: (d) => d.toJson((o) => o.toJson()),
        );
    return data;
  }
}

@riverpod
Future<Order> orderDetail(Ref ref, int id) =>
    ref.read(ordersRepositoryProvider).getOrder(id);
