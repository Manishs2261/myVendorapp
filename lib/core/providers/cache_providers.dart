import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../cache/cache_service.dart';
import '../cache/offline_queue.dart';
import '../network/connectivity_service.dart';
import 'core_providers.dart';

// Pre-initialized via main.dart ProviderScope overrides — these defaults are
// fallbacks for tests.
final cacheServiceProvider = Provider<CacheService>((ref) {
  throw StateError('CacheService must be initialized before app start');
});

final offlineQueueProvider = Provider<OfflineQueueService>((ref) {
  throw StateError('OfflineQueueService must be initialized before app start');
});

final connectivityServiceProvider = Provider<ConnectivityService>(
  (_) => ConnectivityService(),
);

// Tracks current online/offline state. Triggers queue flush on reconnect.
final connectivityNotifierProvider =
    AsyncNotifierProvider<ConnectivityNotifier, bool>(
  ConnectivityNotifier.new,
);

class ConnectivityNotifier extends AsyncNotifier<bool> {
  StreamSubscription<bool>? _sub;

  @override
  Future<bool> build() async {
    final svc = ref.read(connectivityServiceProvider);
    final initial = await svc.isOnline;

    _sub?.cancel();
    _sub = svc.onStatusChanged.listen((online) async {
      final wasOffline = state.valueOrNull == false;
      state = AsyncValue.data(online);
      if (online && wasOffline) {
        _flushQueue();
      }
    });

    ref.onDispose(() => _sub?.cancel());
    return initial;
  }

  Future<void> _flushQueue() async {
    final queue = ref.read(offlineQueueProvider);
    if (!queue.hasPending) return;
    final dio = ref.read(dioProvider);
    await queue.processAll(dio);
  }
}
