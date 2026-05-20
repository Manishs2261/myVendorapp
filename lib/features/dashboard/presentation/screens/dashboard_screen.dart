import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/shop_analytics_models.dart';
import '../providers/shop_analytics_provider.dart';

// ─── Main Screen ──────────────────────────────────────────────────────────────

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(shopAnalyticsProvider);
    final period = ref.watch(shopAnalyticsPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => ref.invalidate(shopAnalyticsProvider),
          ),
        ],
      ),
      body: analyticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(shopAnalyticsProvider),
        ),
        data: (analytics) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(shopAnalyticsProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // Sponsored banner
              if (analytics.sponsored != null) ...[
                _SponsoredBanner(info: analytics.sponsored!),
                const SizedBox(height: 16),
              ],

              // Analytics header + period picker
              _AnalyticsHeader(
                metrics: analytics.metrics,
                period: period,
                onPeriodChanged: (p) =>
                    ref.read(shopAnalyticsPeriodProvider.notifier).state = p,
              ),
              const SizedBox(height: 12),

              // 7 metric cards
              _MetricsGrid(metrics: analytics.metrics),
              const SizedBox(height: 16),

              // Daily Traffic
              _DailyTrafficCard(points: analytics.dailyTraffic),
              const SizedBox(height: 16),

              // Product Performance
              _ProductPerformanceCard(products: analytics.productPerformance),
              const SizedBox(height: 16),

              // Bottom row: Customer Actions + Search Keywords
              _CustomerActionsCard(actions: analytics.customerActions),
              const SizedBox(height: 16),

              _SearchKeywordsCard(keywords: analytics.searchKeywords),
              const SizedBox(height: 16),

              // Smart Insights
              _SmartInsightsCard(insights: analytics.insights),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sponsored Banner ─────────────────────────────────────────────────────────

class _SponsoredBanner extends StatelessWidget {
  final SponsoredInfo info;
  const _SponsoredBanner({required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              const SizedBox(width: 6),
              Text(
                'Sponsored — Active',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'View details →',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SponsorStat(label: 'Views', value: '${info.views}'),
              _SponsorStat(label: 'Clicks', value: '${info.clicks}'),
              _SponsorStat(label: 'CTR', value: '${info.ctr}%'),
              _SponsorStat(label: 'Days Left', value: '${info.daysLeft}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SponsorStat extends StatelessWidget {
  final String label;
  final String value;
  const _SponsorStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

// ─── Analytics Header ─────────────────────────────────────────────────────────

class _AnalyticsHeader extends StatelessWidget {
  final ShopMetrics metrics;
  final String period;
  final void Function(String) onPeriodChanged;

  const _AnalyticsHeader({
    required this.metrics,
    required this.period,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const periods = [
      ('today', 'Today'),
      ('7d', '7 Days'),
      ('30d', '30 Days'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Analytics Dashboard',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          '${metrics.dateStart} → ${metrics.dateEnd}',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 10),
        Row(
          children: periods.map((p) {
            final selected = period == p.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onPeriodChanged(p.$1),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    p.$2,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: selected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Metrics Grid ─────────────────────────────────────────────────────────────

class _MetricsGrid extends StatelessWidget {
  final ShopMetrics metrics;
  const _MetricsGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MetricData(
        icon: Icons.visibility_outlined,
        label: 'Product Views',
        value: '${metrics.productViews}',
        iconColor: Colors.indigo,
      ),
      _MetricData(
        icon: Icons.bar_chart_rounded,
        label: 'Impressions',
        value: '${metrics.impressions}',
        iconColor: Colors.teal,
      ),
      _MetricData(
        icon: Icons.ads_click_rounded,
        label: 'CTR',
        value: '${metrics.ctr}%',
        iconColor: Colors.orange,
      ),
      _MetricData(
        icon: Icons.phone_outlined,
        label: 'Call Clicks',
        value: '${metrics.callClicks}',
        iconColor: Colors.green,
      ),
      _MetricData(
        icon: Icons.chat_outlined,
        label: 'WhatsApp',
        value: '${metrics.whatsappClicks}',
        iconColor: Colors.green[700]!,
      ),
      _MetricData(
        icon: Icons.directions_outlined,
        label: 'Directions',
        value: '${metrics.directions}',
        iconColor: Colors.blue,
      ),
      _MetricData(
        icon: Icons.inbox_outlined,
        label: 'Inquiries',
        value: '${metrics.inquiries}',
        iconColor: Colors.purple,
      ),
    ];

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) => _MetricCard(data: cards[i]),
      ),
    );
  }
}

class _MetricData {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  const _MetricData({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricData data;
  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(data.icon, color: data.iconColor, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.value,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              Text(data.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Daily Traffic Card ───────────────────────────────────────────────────────

class _DailyTrafficCard extends StatelessWidget {
  final List<DailyTrafficPoint> points;
  const _DailyTrafficCard({required this.points});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Traffic',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('Views, customer actions, and searches per day',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            if (points.isEmpty)
              SizedBox(
                height: 120,
                child: Center(
                  child: Text('No traffic data yet',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ),
              )
            else
              SizedBox(
                height: 140,
                child: CustomPaint(
                  painter: _LineChartPainter(
                    points: points,
                    viewsColor: theme.colorScheme.primary,
                    actionsColor: Colors.green,
                    searchesColor: Colors.orange,
                  ),
                  size: Size.infinite,
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                _Legend(color: theme.colorScheme.primary, label: 'Views'),
                const SizedBox(width: 16),
                const _Legend(color: Colors.green, label: 'Actions'),
                const SizedBox(width: 16),
                const _Legend(color: Colors.orange, label: 'Searches'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<DailyTrafficPoint> points;
  final Color viewsColor;
  final Color actionsColor;
  final Color searchesColor;

  const _LineChartPainter({
    required this.points,
    required this.viewsColor,
    required this.actionsColor,
    required this.searchesColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final maxVal = points
        .expand((p) => [p.views, p.actions, p.searches])
        .fold(1, math.max)
        .toDouble();

    final step = size.width / (points.length - 1).clamp(1, double.infinity);

    void drawLine(List<int> values, Color color) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      for (var i = 0; i < values.length; i++) {
        final x = i * step;
        final y = size.height - (values[i] / maxVal * size.height);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          final prevX = (i - 1) * step;
          final prevY = size.height - (values[i - 1] / maxVal * size.height);
          final cpX = (prevX + x) / 2;
          path.cubicTo(cpX, prevY, cpX, y, x, y);
        }
      }
      canvas.drawPath(path, paint);

      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      for (var i = 0; i < values.length; i++) {
        final x = i * step;
        final y = size.height - (values[i] / maxVal * size.height);
        canvas.drawCircle(Offset(x, y), 3, dotPaint);
      }
    }

    drawLine(points.map((p) => p.views).toList(), viewsColor);
    drawLine(points.map((p) => p.actions).toList(), actionsColor);
    drawLine(points.map((p) => p.searches).toList(), searchesColor);
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => old.points != points;
}

// ─── Product Performance ──────────────────────────────────────────────────────

class _ProductPerformanceCard extends StatefulWidget {
  final List<ProductPerformanceItem> products;
  const _ProductPerformanceCard({required this.products});

  @override
  State<_ProductPerformanceCard> createState() =>
      _ProductPerformanceCardState();
}

class _ProductPerformanceCardState extends State<_ProductPerformanceCard> {
  int _page = 0;
  static const _pageSize = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.products.length;
    final start = _page * _pageSize;
    final end = (start + _pageSize).clamp(0, total);
    final pageItems = widget.products.sublist(start, end);
    final totalPages = (total / _pageSize).ceil();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product Performance',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('Views, CTR, and customer actions per product',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 12),

            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Expanded(flex: 4, child: SizedBox()),
                  _ColHeader('VIEWS'),
                  _ColHeader('CTR'),
                  _ColHeader('📞'),
                  _ColHeader('💬'),
                  _ColHeader('↗'),
                  _ColHeader('LAST SEEN'),
                ],
              ),
            ),
            const Divider(height: 1),

            if (widget.products.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No products yet',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ),
              )
            else
              ...pageItems.map((p) => _ProductRow(product: p)),

            if (totalPages > 1) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed:
                        _page > 0 ? () => setState(() => _page--) : null,
                    child: const Text('← Prev'),
                  ),
                  Text('Page ${_page + 1}',
                      style: theme.textTheme.bodySmall),
                  TextButton(
                    onPressed: _page < totalPages - 1
                        ? () => setState(() => _page++)
                        : null,
                    child: const Text('Next →'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String text;
  const _ColHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 9,
            ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final ProductPerformanceItem product;
  const _ProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Product image + name
          Expanded(
            flex: 4,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: product.image != null
                      ? Image.network(
                          product.image!,
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              _ProductThumb(),
                        )
                      : _ProductThumb(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    product.name,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          _DataCell('${product.views}'),
          // CTR badge
          Expanded(
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${product.ctr}%',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: Colors.red[700], fontSize: 9),
                ),
              ),
            ),
          ),
          _DataCell('${product.callClicks}'),
          _DataCell('${product.whatsappClicks}'),
          _DataCell('${product.directions}'),
          Expanded(
            child: Text(
              product.lastSeen ?? '—',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(Icons.inventory_2_outlined,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  const _DataCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

// ─── Customer Actions ─────────────────────────────────────────────────────────

class _CustomerActionsCard extends StatelessWidget {
  final CustomerActions actions;
  const _CustomerActionsCard({required this.actions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = actions.total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer Actions',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('How customers interact with your shop',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            if (total == 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text('No customer actions yet',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ),
              )
            else
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: _PieChartPainter(
                        values: [
                          actions.callClicks.toDouble(),
                          actions.directions.toDouble(),
                          actions.productClicks.toDouble(),
                        ],
                        colors: [Colors.indigo, Colors.cyan, Colors.green],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PieLegendRow(
                          color: Colors.indigo,
                          label: 'Call Clicks',
                          value: actions.callClicks,
                          total: total,
                        ),
                        const SizedBox(height: 8),
                        _PieLegendRow(
                          color: Colors.cyan,
                          label: 'Directions',
                          value: actions.directions,
                          total: total,
                        ),
                        const SizedBox(height: 8),
                        _PieLegendRow(
                          color: Colors.green,
                          label: 'Product Clicks',
                          value: actions.productClicks,
                          total: total,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _PieLegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  final int total;
  const _PieLegendRow({
    required this.color,
    required this.label,
    required this.value,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (value / total * 100).toStringAsFixed(1) : '0.0';
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
            child: Text(label, style: theme.textTheme.bodySmall)),
        Text(
          '$value  $pct%',
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  const _PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;
    var startAngle = -math.pi / 2;

    for (var i = 0; i < values.length; i++) {
      if (values[i] == 0) continue;
      final sweep = values[i] / total * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_PieChartPainter old) => old.values != values;
}

// ─── Search Keywords ──────────────────────────────────────────────────────────

class _SearchKeywordsCard extends StatelessWidget {
  final SearchKeywords keywords;
  const _SearchKeywordsCard({required this.keywords});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Search Keywords',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(
                  '${keywords.totalSearches} total searches this period',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top keywords
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.search,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text('Top Keywords',
                              style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (keywords.topKeywords.isEmpty)
                        Text('No searches yet',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant))
                      else
                        ...keywords.topKeywords.map((kw) {
                          final maxCount = keywords.topKeywords.first.count;
                          final pct = maxCount > 0 ? kw.count / maxCount : 0.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(kw.query,
                                            style:
                                                theme.textTheme.bodySmall)),
                                    Text('${kw.count}',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant)),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    minHeight: 6,
                                    backgroundColor: theme
                                        .colorScheme.surfaceContainerHighest,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // No result searches
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              size: 14, color: Colors.orange),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text('No-Result Searches (High Demand)',
                                style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (keywords.noResultSearches.isEmpty)
                        Text('None yet',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant))
                      else
                        ...keywords.noResultSearches.map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.orange.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: Colors.orange
                                          .withValues(alpha: 0.25)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(s.query,
                                            style:
                                                theme.textTheme.bodySmall)),
                                    Text('${s.count}x · 0 results',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                                color: Colors.orange[700],
                                                fontSize: 9)),
                                  ],
                                ),
                              ),
                            )),

                      if (keywords.noResultSearches.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '💡 These are products customers want but can\'t find. Consider adding them!',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Smart Insights ───────────────────────────────────────────────────────────

class _SmartInsightsCard extends StatelessWidget {
  final List<ShopInsight> insights;
  const _SmartInsightsCard({required this.insights});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Smart Insights',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('Auto-generated based on your shop\'s performance trends',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            if (insights.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          size: 32, color: Colors.amber),
                      const SizedBox(height: 8),
                      Text(
                        'No insights yet. Insights are generated nightly after your shop accumulates activity.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...insights.map(
                (insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (insight.title.isNotEmpty)
                                Text(insight.title,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(fontWeight: FontWeight.w600)),
                              Text(insight.message,
                                  style: theme.textTheme.bodySmall),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
