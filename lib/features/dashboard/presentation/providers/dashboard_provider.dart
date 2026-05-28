import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/cache/cache_keys.dart';
import '../../../../core/providers/cache_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/dashboard_remote_source.dart';
import '../../data/dashboard_repository.dart';
import '../../domain/dashboard_models.dart';
import '../../domain/i_dashboard_repository.dart';

part 'dashboard_provider.g.dart';

@riverpod
DashboardRemoteSource dashboardRemoteSource(Ref ref) =>
    DashboardRemoteSource(ref.read(dioProvider));

@riverpod
IDashboardRepository dashboardRepository(Ref ref) =>
    DashboardRepository(ref.read(dashboardRemoteSourceProvider));

@Riverpod(keepAlive: true)
class DashboardNotifier extends _$DashboardNotifier {
  static const _ttl = Duration(minutes: 5);

  @override
  Future<DashboardOverview> build() async {
    final cache = ref.read(cacheServiceProvider);

    final cached = cache.get<DashboardOverview>(
      CacheKeys.dashboard,
      fromJson: DashboardOverview.fromJson,
      maxAge: _ttl,
    );

    if (cached != null) {
      Future.microtask(_backgroundRefresh);
      return cached;
    }

    final stale = cache.getIgnoringTtl<DashboardOverview>(
      CacheKeys.dashboard,
      fromJson: DashboardOverview.fromJson,
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
      ref.read(cacheServiceProvider).getLastUpdated(CacheKeys.dashboard);

  Future<void> _backgroundRefresh() async {
    try {
      final fresh = await _fetchAndCache();
      state = AsyncValue.data(fresh);
    } catch (_) {}
  }

  Future<DashboardOverview> _fetchAndCache() async {
    final data = await ref.read(dashboardRepositoryProvider).getOverview();
    await ref.read(cacheServiceProvider).put(
          CacheKeys.dashboard,
          data,
          toJson: (d) => d.toJson(),
        );
    return data;
  }
}
