import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/shop_analytics_remote_source.dart';
import '../../domain/shop_analytics_models.dart';

final shopAnalyticsPeriodProvider = StateProvider<String>((ref) => '30d');

final shopAnalyticsRemoteSourceProvider =
    Provider<ShopAnalyticsRemoteSource>((ref) {
  return ShopAnalyticsRemoteSource(ref.read(dioProvider));
});

final shopAnalyticsProvider =
    FutureProvider.autoDispose<ShopAnalytics>((ref) async {
  final period = ref.watch(shopAnalyticsPeriodProvider);
  final source = ref.read(shopAnalyticsRemoteSourceProvider);
  return source.getShopAnalytics(period);
});
