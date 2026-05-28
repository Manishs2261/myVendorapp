import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static const _boxName = 'app_cache';
  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> put<T>(
    String key,
    T value, {
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    await _box.put(key, {
      'data': toJson(value),
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Returns cached value if it exists and is within [maxAge]. Returns null if
  /// missing or expired.
  T? get<T>(
    String key, {
    required T Function(Map<String, dynamic>) fromJson,
    Duration maxAge = const Duration(minutes: 10),
  }) {
    final entry = _box.get(key) as Map?;
    if (entry == null) return null;
    final cachedAt =
        DateTime.fromMillisecondsSinceEpoch(entry['cachedAt'] as int);
    if (DateTime.now().difference(cachedAt) > maxAge) return null;
    return _parse(entry, fromJson);
  }

  /// Returns cached value regardless of TTL — used as offline fallback.
  T? getIgnoringTtl<T>(
    String key, {
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    final entry = _box.get(key) as Map?;
    if (entry == null) return null;
    return _parse(entry, fromJson);
  }

  DateTime? getLastUpdated(String key) {
    final entry = _box.get(key) as Map?;
    if (entry == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(entry['cachedAt'] as int);
  }

  Future<void> invalidate(String key) => _box.delete(key);

  Future<void> clear() => _box.clear();

  T? _parse<T>(Map entry, T Function(Map<String, dynamic>) fromJson) {
    try {
      final data = entry['data'];
      if (data == null) return null;
      return fromJson(Map<String, dynamic>.from(data as Map));
    } catch (_) {
      return null;
    }
  }
}
