import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../shop/domain/shop_review_models.dart';
import '../../../shop/presentation/providers/shop_provider.dart';
import '../../domain/dashboard_models.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(dashboardOverviewProvider);
    final profileAsync = ref.watch(profileNotifierProvider);
    final shopAsync = ref.watch(shopNotifierProvider);
    final reviewsAsync = ref.watch(shopReviewStatsProvider);

    final vendorName = profileAsync.valueOrNull?.businessName ?? 'Vendor';
    final firstName = vendorName.split(' ').first;
    final shopStatus = shopAsync.valueOrNull?.status;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              ref.invalidate(dashboardOverviewProvider);
              ref.invalidate(profileNotifierProvider);
              ref.invalidate(shopNotifierProvider);
              ref.invalidate(shopReviewStatsProvider);
            },
          ),
        ],
      ),
      body: overviewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(dashboardOverviewProvider),
        ),
        data: (overview) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardOverviewProvider);
            ref.invalidate(profileNotifierProvider);
            ref.invalidate(shopNotifierProvider);
            ref.invalidate(shopReviewStatsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _GreetingHeader(firstName: firstName),
              const SizedBox(height: 16),
              if (shopStatus != null && shopStatus != 'approved')
                _ApprovalBanner(status: shopStatus),
              _CompletionCard(
                overview: overview,
                profile: profileAsync.valueOrNull,
                shop: shopAsync.valueOrNull,
                onTap: () => context.go(RouteNames.shop),
              ),
              const SizedBox(height: 20),
              _StatsGrid(overview: overview),
              const SizedBox(height: 20),
              if (overview.recentProducts.isNotEmpty) ...[
                _ProductViewsChart(products: overview.recentProducts),
                const SizedBox(height: 16),
              ],
              _QuickActions(),
              const SizedBox(height: 20),
              if (overview.recentProducts.isNotEmpty)
                _RecentProductsList(
                  products: overview.recentProducts,
                  onProductTap: (id) => context.push('/products/$id'),
                  onViewAll: () => context.go(RouteNames.products),
                ),
              const SizedBox(height: 20),
              _ReviewsWidget(reviewsAsync: reviewsAsync),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Greeting ─────────────────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  final String firstName;
  const _GreetingHeader({required this.firstName});

  String get _timeGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_timeGreeting, $firstName',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          "Here's what's happening with your shop today.",
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─── Approval Banner ──────────────────────────────────────────────────────────

class _ApprovalBanner extends StatelessWidget {
  final String status;
  const _ApprovalBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = status == 'rejected'
        ? theme.colorScheme.error
        : status == 'suspended'
            ? Colors.orange
            : theme.colorScheme.tertiary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vendor Approval Pending',
                  style: theme.textTheme.labelLarge?.copyWith(color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  'You can continue managing your shop. Approval-based actions may be limited until your account is approved.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Completion Card ──────────────────────────────────────────────────────────

class _CompletionCard extends StatelessWidget {
  final DashboardOverview overview;
  final dynamic profile;
  final dynamic shop;
  final VoidCallback onTap;

  const _CompletionCard({
    required this.overview,
    required this.profile,
    required this.shop,
    required this.onTap,
  });

  List<({String label, bool done})> _buildSteps() {
    return [
      (label: 'Business name added', done: profile?.businessName?.isNotEmpty == true),
      (label: 'Business email added', done: profile?.email?.isNotEmpty == true),
      (label: 'Business phone added', done: profile?.phone?.isNotEmpty == true),
      (label: 'GST or PAN added', done: profile?.gstNumber != null),
      (label: 'Shop name added', done: shop?.shopName?.isNotEmpty == true),
      (label: 'Shop logo added', done: shop?.logoUrl != null),
      (label: 'Shop address added', done: shop?.address != null),
      (label: 'Email verified', done: profile?.isEmailVerified == true),
      (label: 'Phone verified', done: profile?.isPhoneVerified == true),
      (label: '5+ products added', done: overview.totalProducts >= 5),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = _buildSteps();
    final doneCount = steps.where((s) => s.done).length;
    final score = (doneCount / steps.length * 100).round();
    final isComplete = score == 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _RingProgress(score: score),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isComplete ? 'Shop Profile Complete' : 'Shop Profile Incomplete',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete your profile to rank higher in search results',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (!isComplete)
                        FilledButton.tonal(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          child: const Text('Complete Profile'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: steps.map((s) => _StepChip(label: s.label, done: s.done)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingProgress extends StatelessWidget {
  final int score;
  const _RingProgress({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 72,
      height: 72,
      child: CustomPaint(
        painter: _RingPainter(score: score, color: color),
        child: Center(
          child: Text(
            '$score%',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final int score;
  final Color color;
  const _RingPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 6;
    final strokeWidth = 6.0;

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), radius, bgPaint);

    final sweepAngle = 2 * math.pi * score / 100;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.score != score;
}

class _StepChip extends StatelessWidget {
  final String label;
  final bool done;
  const _StepChip({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = done ? Colors.green : theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 13,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: color)),
      ],
    );
  }
}

// ─── Stats Grid ───────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final DashboardOverview overview;
  const _StatsGrid({required this.overview});

  @override
  Widget build(BuildContext context) {
    final activePercent = overview.totalProducts > 0
        ? '${(overview.activeProducts / overview.totalProducts * 100).round()}% of total'
        : '0% of total';

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: [
        StatCard(
          label: 'Total Products',
          value: overview.totalProducts.toString(),
          icon: Icons.inventory_2_outlined,
          trend: '${overview.recentProducts.length} recent items',
        ),
        StatCard(
          label: 'Active Products',
          value: overview.activeProducts.toString(),
          icon: Icons.check_circle_outline,
          iconColor: Colors.green,
          trend: activePercent,
        ),
        StatCard(
          label: 'Need Attention',
          value: overview.inactiveProducts.toString(),
          icon: Icons.warning_amber_outlined,
          iconColor: Colors.orange,
          trend: 'Inactive / pending',
        ),
        StatCard(
          label: 'Total Views',
          value: AppFormatters.compact(overview.totalViews),
          icon: Icons.visibility_outlined,
          iconColor: Colors.cyan,
          trend: '${overview.pendingOrders} pending orders',
        ),
        StatCard(
          label: 'Revenue',
          value: AppFormatters.currency(overview.totalRevenue),
          icon: Icons.currency_rupee,
          iconColor: Colors.purple,
          trend: '${overview.totalOrders} total orders',
        ),
      ],
    );
  }
}

// ─── Product Views Chart ──────────────────────────────────────────────────────

class _ProductViewsChart extends StatelessWidget {
  final List<RecentProduct> products;
  const _ProductViewsChart({required this.products});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxClicks = products.map((p) => p.clickCount).fold(0, math.max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Product Views', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              'Latest products and their current click counts',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: CustomPaint(
                painter: _SparklinePainter(
                  products: products,
                  maxClicks: maxClicks,
                  color: theme.colorScheme.primary,
                ),
                size: Size.infinite,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: products
                  .map(
                    (p) => Expanded(
                      child: Text(
                        p.name.length > 6 ? '${p.name.substring(0, 6)}..' : p.name,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 9,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<RecentProduct> products;
  final int maxClicks;
  final Color color;

  const _SparklinePainter({
    required this.products,
    required this.maxClicks,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (products.isEmpty) return;

    final effectiveMax = maxClicks == 0 ? 1 : maxClicks;
    final step = size.width / (products.length - 1).clamp(1, double.infinity);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < products.length; i++) {
      final x = i * step;
      final y = size.height - (products[i].clickCount / effectiveMax * size.height);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * step;
        final prevY = size.height - (products[i - 1].clickCount / effectiveMax * size.height);
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
        fillPath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    final lastX = (products.length - 1) * step;
    fillPath.lineTo(lastX, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // draw dots
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (var i = 0; i < products.length; i++) {
      final x = i * step;
      final y = size.height - (products[i].clickCount / effectiveMax * size.height);
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.products != products || old.maxClicks != maxClicks;
}

// ─── Quick Actions ────────────────────────────────────────────────────────────

class _QuickActions extends ConsumerWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final actions = [
      (icon: Icons.add_box_outlined, label: 'Add New Product', route: RouteNames.products),
      (icon: Icons.store_outlined, label: 'Edit Shop Profile', route: RouteNames.shop),
      (icon: Icons.shopping_bag_outlined, label: 'View Orders', route: RouteNames.orders),
      (icon: Icons.person_outline, label: 'My Profile', route: RouteNames.profile),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Actions', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...actions.map(
              (a) => InkWell(
                onTap: () => context.go(a.route),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    children: [
                      Icon(a.icon, size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(a.label, style: theme.textTheme.bodyMedium),
                      const Spacer(),
                      Icon(Icons.chevron_right, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Products List ─────────────────────────────────────────────────────

class _RecentProductsList extends StatelessWidget {
  final List<RecentProduct> products;
  final void Function(int id) onProductTap;
  final VoidCallback onViewAll;

  const _RecentProductsList({
    required this.products,
    required this.onProductTap,
    required this.onViewAll,
  });

  Color _statusColor(String status, BuildContext context) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      case 'rejected':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

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
                Text('Recent Products', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton(onPressed: onViewAll, child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 8),
            ...products.take(5).map(
              (p) => InkWell(
                onTap: () => onProductTap(p.id),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: p.imageUrls.isNotEmpty
                            ? Image.network(
                                p.imageUrls.first,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _ProductPlaceholder(),
                              )
                            : _ProductPlaceholder(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: theme.textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (p.categoryName != null)
                              Text(
                                p.categoryName!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppFormatters.currency(p.price),
                            style: theme.textTheme.labelMedium,
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _statusColor(p.status, context).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              p.status,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _statusColor(p.status, context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          Icon(Icons.visibility_outlined, size: 12, color: theme.colorScheme.onSurfaceVariant),
                          Text(
                            '${p.clickCount}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(Icons.inventory_2_outlined, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

// ─── Reviews Widget ───────────────────────────────────────────────────────────

class _ReviewsWidget extends StatelessWidget {
  final AsyncValue<ShopReviewStats> reviewsAsync;
  const _ReviewsWidget({required this.reviewsAsync});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shop Reviews', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              'Customer ratings for your shop',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            reviewsAsync.when(
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              )),
              error: (_, _) => Text(
                'Could not load reviews',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              data: (stats) => stats.totalReviews == 0
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No shop reviews yet',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    )
                  : _ReviewsContent(stats: stats),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewsContent extends StatelessWidget {
  final ShopReviewStats stats;
  const _ReviewsContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(
              stats.averageRating.toStringAsFixed(1),
              style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            _StarRow(rating: stats.averageRating.round(), size: 14),
            const SizedBox(height: 4),
            Text(
              '${stats.totalReviews} reviews',
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(width: 20),
        if (stats.recentReviews.isNotEmpty)
          Expanded(
            child: Column(
              children: stats.recentReviews
                  .take(3)
                  .map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StarRow(rating: r.rating, size: 10),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              r.comment ?? 'No comment',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontStyle: r.comment == null ? FontStyle.italic : FontStyle.normal,
                                color: r.comment == null ? theme.colorScheme.onSurfaceVariant : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            r.reviewerName,
                            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _StarRow extends StatelessWidget {
  final int rating;
  final double size;
  const _StarRow({required this.rating, required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: i < rating ? Colors.amber : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}
