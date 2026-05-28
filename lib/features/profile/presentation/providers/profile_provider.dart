import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/cache/cache_keys.dart';
import '../../../../core/providers/cache_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/profile_remote_source.dart';
import '../../data/profile_repository.dart';
import '../../domain/i_profile_repository.dart';
import '../../domain/profile_models.dart';

part 'profile_provider.g.dart';

@riverpod
ProfileRemoteSource profileRemoteSource(Ref ref) =>
    ProfileRemoteSource(ref.read(dioProvider));

@riverpod
IProfileRepository profileRepository(Ref ref) =>
    ProfileRepository(ref.read(profileRemoteSourceProvider));

@Riverpod(keepAlive: true)
class ProfileNotifier extends _$ProfileNotifier {
  static const _ttl = Duration(minutes: 30);

  @override
  Future<VendorProfile> build() async {
    final cache = ref.read(cacheServiceProvider);

    final cached = cache.get<VendorProfile>(
      CacheKeys.profile,
      fromJson: VendorProfile.fromJson,
      maxAge: _ttl,
    );
    if (cached != null) {
      Future.microtask(_backgroundRefresh);
      return cached;
    }

    final stale = cache.getIgnoringTtl<VendorProfile>(
      CacheKeys.profile,
      fromJson: VendorProfile.fromJson,
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

  Future<void> _backgroundRefresh() async {
    try {
      final fresh = await _fetchAndCache();
      state = AsyncValue.data(fresh);
    } catch (_) {}
  }

  Future<VendorProfile> _fetchAndCache() async {
    final data = await ref.read(profileRepositoryProvider).getProfile();
    await ref.read(cacheServiceProvider).put(
          CacheKeys.profile,
          data,
          toJson: (d) => d.toJson(),
        );
    return data;
  }

  Future<void> save(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updated =
          await ref.read(profileRepositoryProvider).updateProfile(data);
      await ref.read(cacheServiceProvider).put(
            CacheKeys.profile,
            updated,
            toJson: (d) => d.toJson(),
          );
      return updated;
    });
  }

  DateTime? get lastUpdated =>
      ref.read(cacheServiceProvider).getLastUpdated(CacheKeys.profile);
}
