import 'package:dio/dio.dart';
import '../domain/shop_analytics_models.dart';

class ShopAnalyticsRemoteSource {
  final Dio _dio;
  ShopAnalyticsRemoteSource(this._dio);

  Future<ShopAnalytics> getShopAnalytics(String period) async {
    final params = {'period': period};

    final results = await Future.wait([
      _safeMap('/vendor/analytics/v2/overview', queryParameters: params),
      _safeMap('/vendor/analytics/v2/products',
          queryParameters: {...params, 'limit': 50}),
      _safeMap('/vendor/analytics/v2/search-keywords', queryParameters: params),
      _safeMap('/vendor/analytics/v2/actions', queryParameters: params),
      _safeMap('/vendor/analytics/v2/charts/daily-traffic',
          queryParameters: params),
      _safeMap('/vendor/analytics/v2/insights'),
      _safeList('/sponsorships/vendor/status'),
    ]);

    final overview = results[0] as Map<String, dynamic>;
    final products = results[1] as Map<String, dynamic>;
    final search = results[2] as Map<String, dynamic>;
    final actions = results[3] as Map<String, dynamic>;
    final traffic = results[4] as Map<String, dynamic>;
    final insights = results[5] as Map<String, dynamic>;
    final sponsorList = results[6] as List<dynamic>;

    return ShopAnalytics(
      metrics: ShopMetrics.fromJson(overview),
      sponsored: SponsoredInfo.fromSponsorshipList(sponsorList),
      dailyTraffic: (traffic['series'] as List<dynamic>? ?? [])
          .map((e) => DailyTrafficPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      productPerformance: (products['items'] as List<dynamic>? ?? [])
          .map((e) =>
              ProductPerformanceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      customerActions: CustomerActions.fromActionsResponse(actions),
      searchKeywords: SearchKeywords.fromJson(search),
      insights: (insights['items'] as List<dynamic>? ?? [])
          .map((e) => ShopInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Map<String, dynamic>> _safeMap(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final r = await _dio.get(path, queryParameters: queryParameters);
      return r.data as Map<String, dynamic>? ?? {};
    } catch (_) {
      return {};
    }
  }

  Future<List<dynamic>> _safeList(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final r = await _dio.get(path, queryParameters: queryParameters);
      return r.data as List<dynamic>? ?? [];
    } catch (_) {
      return [];
    }
  }
}
