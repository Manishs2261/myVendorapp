// Models matching the backend analytics v2 endpoints
// Overview: GET /vendor/analytics/v2/overview
// Products: GET /vendor/analytics/v2/products
// Search:   GET /vendor/analytics/v2/search
// Actions:  GET /vendor/analytics/v2/actions
// Traffic:  GET /vendor/analytics/v2/charts/daily-traffic
// Insights: GET /vendor/analytics/v2/insights
// Sponsor:  GET /sponsorships/vendor/status

class SponsoredInfo {
  final bool active;
  final int views;
  final int clicks;
  final double ctr;
  final int daysLeft;

  const SponsoredInfo({
    required this.active,
    required this.views,
    required this.clicks,
    required this.ctr,
    required this.daysLeft,
  });

  factory SponsoredInfo.fromSponsorshipList(List<dynamic> items) {
    final active = items.where((s) {
      final status = s['status'] as String? ?? '';
      return status == 'active' || status == 'approved';
    }).toList();
    if (active.isEmpty) {
      return const SponsoredInfo(
          active: false, views: 0, clicks: 0, ctr: 0.0, daysLeft: 0);
    }
    final s = active.first;
    final views = s['view_count'] as int? ?? 0;
    final clicks = s['click_count'] as int? ?? 0;
    final ctr =
        views > 0 ? double.parse((clicks / views * 100).toStringAsFixed(1)) : 0.0;
    int daysLeft = 0;
    final endDateStr = s['end_date'] as String?;
    if (endDateStr != null) {
      try {
        final end = DateTime.parse(endDateStr);
        daysLeft = end.difference(DateTime.now()).inDays.clamp(0, 9999);
      } catch (_) {}
    }
    return SponsoredInfo(
      active: true,
      views: views,
      clicks: clicks,
      ctr: ctr,
      daysLeft: daysLeft,
    );
  }

  factory SponsoredInfo.fromJson(Map<String, dynamic> j) => SponsoredInfo(
        active: j['active'] as bool? ?? false,
        views: j['views'] as int? ?? 0,
        clicks: j['clicks'] as int? ?? 0,
        ctr: (j['ctr'] as num?)?.toDouble() ?? 0.0,
        daysLeft: j['days_left'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'active': active,
        'views': views,
        'clicks': clicks,
        'ctr': ctr,
        'days_left': daysLeft,
      };
}

class ShopMetrics {
  final int productViews;
  final int impressions;
  final double ctr;
  final int callClicks;
  final int whatsappClicks;
  final int directions;
  final int inquiries;
  final String period;
  final String dateStart;
  final String dateEnd;

  const ShopMetrics({
    required this.productViews,
    required this.impressions,
    required this.ctr,
    required this.callClicks,
    required this.whatsappClicks,
    required this.directions,
    required this.inquiries,
    required this.period,
    required this.dateStart,
    required this.dateEnd,
  });

  factory ShopMetrics.fromJson(Map<String, dynamic> j) => ShopMetrics(
        productViews: j['total_views'] as int? ?? 0,
        impressions: j['total_impressions'] as int? ?? 0,
        ctr: (j['ctr_percentage'] as num?)?.toDouble() ?? 0.0,
        callClicks: j['total_call_clicks'] as int? ?? 0,
        whatsappClicks: j['total_whatsapp_clicks'] as int? ?? 0,
        directions: j['total_direction_clicks'] as int? ?? 0,
        inquiries: j['total_inquiries'] as int? ?? 0,
        period: j['period'] as String? ?? '30d',
        dateStart: j['start_date'] as String? ?? '',
        dateEnd: j['end_date'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'total_views': productViews,
        'total_impressions': impressions,
        'ctr_percentage': ctr,
        'total_call_clicks': callClicks,
        'total_whatsapp_clicks': whatsappClicks,
        'total_direction_clicks': directions,
        'total_inquiries': inquiries,
        'period': period,
        'start_date': dateStart,
        'end_date': dateEnd,
      };
}

class DailyTrafficPoint {
  final String date;
  final int views;
  final int actions;
  final int searches;

  const DailyTrafficPoint({
    required this.date,
    required this.views,
    required this.actions,
    required this.searches,
  });

  factory DailyTrafficPoint.fromJson(Map<String, dynamic> j) =>
      DailyTrafficPoint(
        date: j['date'] as String? ?? '',
        views: j['views'] as int? ?? 0,
        actions: j['actions'] as int? ?? 0,
        searches: j['searches'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'views': views,
        'actions': actions,
        'searches': searches,
      };
}

class ProductPerformanceItem {
  final int id;
  final String name;
  final String? image;
  final int views;
  final int impressions;
  final double ctr;
  final int callClicks;
  final int whatsappClicks;
  final int directions;
  final String? lastSeen;

  const ProductPerformanceItem({
    required this.id,
    required this.name,
    this.image,
    required this.views,
    required this.impressions,
    required this.ctr,
    required this.callClicks,
    required this.whatsappClicks,
    required this.directions,
    this.lastSeen,
  });

  factory ProductPerformanceItem.fromJson(Map<String, dynamic> j) =>
      ProductPerformanceItem(
        id: j['product_id'] as int? ?? 0,
        name: j['name'] as String? ?? '',
        image: j['image'] as String?,
        views: j['views'] as int? ?? 0,
        impressions: j['impressions'] as int? ?? 0,
        ctr: (j['ctr'] as num?)?.toDouble() ?? 0.0,
        callClicks: j['call_clicks'] as int? ?? 0,
        whatsappClicks: j['whatsapp_clicks'] as int? ?? 0,
        directions: j['direction_clicks'] as int? ?? 0,
        lastSeen: j['last_viewed_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'product_id': id,
        'name': name,
        if (image != null) 'image': image,
        'views': views,
        'impressions': impressions,
        'ctr': ctr,
        'call_clicks': callClicks,
        'whatsapp_clicks': whatsappClicks,
        'direction_clicks': directions,
        if (lastSeen != null) 'last_viewed_at': lastSeen,
      };
}

class CustomerActions {
  final int callClicks;
  final int directions;
  final int productClicks;
  final int total;

  const CustomerActions({
    required this.callClicks,
    required this.directions,
    required this.productClicks,
    required this.total,
  });

  factory CustomerActions.fromActionsResponse(Map<String, dynamic> j) {
    final breakdown = j['breakdown'] as List<dynamic>? ?? [];
    final total = j['total_actions'] as int? ?? 0;
    int calls = 0, dirs = 0, clicks = 0;
    for (final b in breakdown) {
      final t = b['action_type'] as String? ?? '';
      final c = b['count'] as int? ?? 0;
      if (t == 'call_click') calls = c;
      else if (t == 'direction_click') dirs = c;
      else if (t == 'product_click') clicks = c;
    }
    return CustomerActions(
      callClicks: calls,
      directions: dirs,
      productClicks: clicks,
      total: total,
    );
  }

  factory CustomerActions.fromJson(Map<String, dynamic> j) => CustomerActions(
        callClicks: j['call_clicks'] as int? ?? 0,
        directions: j['direction_clicks'] as int? ?? 0,
        productClicks: j['product_clicks'] as int? ?? 0,
        total: j['total'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'call_clicks': callClicks,
        'direction_clicks': directions,
        'product_clicks': productClicks,
        'total': total,
      };
}

class SearchKeywordItem {
  final String query;
  final int count;
  final double resultCountAvg;
  final bool isNoResult;

  const SearchKeywordItem({
    required this.query,
    required this.count,
    required this.resultCountAvg,
    required this.isNoResult,
  });

  factory SearchKeywordItem.fromJson(Map<String, dynamic> j) =>
      SearchKeywordItem(
        query: j['keyword'] as String? ?? '',
        count: j['count'] as int? ?? 0,
        resultCountAvg: (j['result_count_avg'] as num?)?.toDouble() ?? 0.0,
        isNoResult: j['is_no_result'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'keyword': query,
        'count': count,
        'result_count_avg': resultCountAvg,
        'is_no_result': isNoResult,
      };
}

class SearchKeywords {
  final List<SearchKeywordItem> topKeywords;
  final List<SearchKeywordItem> noResultSearches;
  final int totalSearches;

  const SearchKeywords({
    required this.topKeywords,
    required this.noResultSearches,
    required this.totalSearches,
  });

  factory SearchKeywords.fromJson(Map<String, dynamic> j) => SearchKeywords(
        topKeywords: (j['top_keywords'] as List<dynamic>? ?? [])
            .map((e) => SearchKeywordItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        noResultSearches: (j['no_result_keywords'] as List<dynamic>? ?? [])
            .map((e) => SearchKeywordItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalSearches: j['total_searches'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'top_keywords': topKeywords.map((k) => k.toJson()).toList(),
        'no_result_keywords': noResultSearches.map((k) => k.toJson()).toList(),
        'total_searches': totalSearches,
      };
}

class ShopInsight {
  final int id;
  final String title;
  final String message;
  final bool isRead;

  const ShopInsight({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
  });

  factory ShopInsight.fromJson(Map<String, dynamic> j) => ShopInsight(
        id: j['id'] as int? ?? 0,
        title: j['title'] as String? ?? '',
        message: j['message'] as String? ?? '',
        isRead: j['is_read'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'is_read': isRead,
      };
}

class ShopAnalytics {
  final ShopMetrics metrics;
  final SponsoredInfo? sponsored;
  final List<DailyTrafficPoint> dailyTraffic;
  final List<ProductPerformanceItem> productPerformance;
  final CustomerActions customerActions;
  final SearchKeywords searchKeywords;
  final List<ShopInsight> insights;

  const ShopAnalytics({
    required this.metrics,
    this.sponsored,
    required this.dailyTraffic,
    required this.productPerformance,
    required this.customerActions,
    required this.searchKeywords,
    required this.insights,
  });

  factory ShopAnalytics.fromJson(Map<String, dynamic> j) => ShopAnalytics(
        metrics: ShopMetrics.fromJson(j['metrics'] as Map<String, dynamic>),
        sponsored: j['sponsored'] != null
            ? SponsoredInfo.fromJson(
                Map<String, dynamic>.from(j['sponsored'] as Map))
            : null,
        dailyTraffic: (j['daily_traffic'] as List? ?? [])
            .map((e) =>
                DailyTrafficPoint.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        productPerformance: (j['product_performance'] as List? ?? [])
            .map((e) => ProductPerformanceItem.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList(),
        customerActions: CustomerActions.fromJson(
            Map<String, dynamic>.from(j['customer_actions'] as Map)),
        searchKeywords: SearchKeywords.fromJson(
            Map<String, dynamic>.from(j['search_keywords'] as Map)),
        insights: (j['insights'] as List? ?? [])
            .map((e) =>
                ShopInsight.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'metrics': metrics.toJson(),
        'sponsored': sponsored?.toJson(),
        'daily_traffic': dailyTraffic.map((t) => t.toJson()).toList(),
        'product_performance': productPerformance.map((p) => p.toJson()).toList(),
        'customer_actions': customerActions.toJson(),
        'search_keywords': searchKeywords.toJson(),
        'insights': insights.map((i) => i.toJson()).toList(),
      };
}
