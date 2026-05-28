import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/cache/cache_keys.dart';
import '../../../../core/providers/cache_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/shop_analytics_remote_source.dart';
import '../../domain/shop_analytics_models.dart';

part 'shop_analytics_provider.g.dart';

final shopAnalyticsPeriodProvider = StateProvider<String>((ref) => '30d');

@riverpod
ShopAnalyticsRemoteSource shopAnalyticsRemoteSource(Ref ref) =>
    ShopAnalyticsRemoteSource(ref.read(dioProvider));

@Riverpod(keepAlive: true)
class ShopAnalyticsNotifier extends _$ShopAnalyticsNotifier {
  @override
  Future<ShopAnalytics> build() async {
    final period = ref.watch(shopAnalyticsPeriodProvider);
    final cache = ref.read(cacheServiceProvider);
    final cacheKey = CacheKeys.analytics(period);

    // Try fresh cache first
    final cached = cache.get<ShopAnalytics>(
      cacheKey,
      fromJson: ShopAnalytics.fromJson,
      maxAge: const Duration(minutes: 5),
    );

    if (cached != null) {
      Future.microtask(() => _backgroundRefresh(period));
      return cached;
    }

    // No fresh cache — try stale fallback while fetching
    final stale = cache.getIgnoringTtl<ShopAnalytics>(
      cacheKey,
      fromJson: ShopAnalytics.fromJson,
    );
    if (stale != null) {
      Future.microtask(() => _backgroundRefresh(period));
      return stale;
    }

    return _fetchAndCache(period);
  }

  Future<void> refresh() async {
    final period = ref.read(shopAnalyticsPeriodProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAndCache(period));
  }

  DateTime? get lastUpdated {
    final period = ref.read(shopAnalyticsPeriodProvider);
    return ref.read(cacheServiceProvider).getLastUpdated(CacheKeys.analytics(period));
  }

  Future<void> _backgroundRefresh(String period) async {
    try {
      final fresh = await _fetchAndCache(period);
      if (ref.read(shopAnalyticsPeriodProvider) == period) {
        state = AsyncValue.data(fresh);
      }
    } catch (_) {}
  }

  Future<ShopAnalytics> _fetchAndCache(String period) async {
    final source = ref.read(shopAnalyticsRemoteSourceProvider);
    final data = await source.getShopAnalytics(period);
    await ref.read(cacheServiceProvider).put(
          CacheKeys.analytics(period),
          data,
          toJson: (d) => d.toJson(),
        );
    return data;
  }
}
