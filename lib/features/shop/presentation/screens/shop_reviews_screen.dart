import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/main_shell.dart';
import '../../domain/shop_review_models.dart';
import '../providers/shop_provider.dart';

class ShopReviewsScreen extends ConsumerStatefulWidget {
  const ShopReviewsScreen({super.key});

  @override
  ConsumerState<ShopReviewsScreen> createState() => _ShopReviewsScreenState();
}

class _ShopReviewsScreenState extends ConsumerState<ShopReviewsScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  ShopReviewStats? _stats;
  bool _loadingStats = false;

  List<ShopReview> _reviews = [];
  int _total = 0;
  int _page = 1;
  int _pages = 1;
  bool _loadingReviews = false;
  String? _reviewError;

  int? _ratingFilter;
  String _sort = 'latest';

  @override
  void initState() {
    super.initState();
    _loadAll();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _resetAndLoad();
    });
  }

  void _resetAndLoad() {
    setState(() => _page = 1);
    _loadReviews();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadStats(), _loadReviews()]);
  }

  Future<void> _loadStats() async {
    setState(() => _loadingStats = true);
    try {
      final data = await ref.read(shopRemoteSourceProvider).getReviewStats();
      if (mounted) setState(() => _stats = ShopReviewStats.fromJson(data));
    } catch (_) {
      // stats are supplementary; silently ignore
    } finally {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  Future<void> _loadReviews() async {
    setState(() {
      _loadingReviews = true;
      _reviewError = null;
    });
    try {
      final data = await ref.read(shopRemoteSourceProvider).getShopReviews(
            page: _page,
            search: _searchCtrl.text.trim(),
            rating: _ratingFilter,
            sort: _sort,
          );
      final result = ShopReviewsPage.fromJson(data);
      if (mounted) {
        setState(() {
          _reviews = result.items;
          _total = result.total;
          _pages = result.pages;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _reviewError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingReviews = false);
    }
  }

  void _setRating(int? rating) {
    setState(() {
      _ratingFilter = rating;
      _page = 1;
    });
    _loadReviews();
  }

  void _setSort(String sort) {
    setState(() {
      _sort = sort;
      _page = 1;
    });
    _loadReviews();
  }

  void _goToPage(int page) {
    setState(() => _page = page);
    _loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Shop Reviews'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _loadAll,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _StatsCard(stats: _stats, loading: _loadingStats),
            const SizedBox(height: 16),
            _FilterRow(
              searchCtrl: _searchCtrl,
              ratingFilter: _ratingFilter,
              sort: _sort,
              onRatingChanged: _setRating,
              onSortChanged: _setSort,
            ),
            const SizedBox(height: 12),
            if (_reviewError != null)
              _ErrorBanner(message: _reviewError!, onRetry: _loadReviews)
            else ...[
              Text(
                '$_total total customer reviews',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              if (_loadingReviews)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_reviews.isEmpty)
                const _EmptyState()
              else
                ..._reviews.map((r) => _ReviewCard(review: r)),
              if (_pages > 1) ...[
                const SizedBox(height: 16),
                _PaginationRow(
                  page: _page,
                  pages: _pages,
                  total: _total,
                  onPrev: _page > 1 ? () => _goToPage(_page - 1) : null,
                  onNext: _page < _pages ? () => _goToPage(_page + 1) : null,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Stats Card ───────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final ShopReviewStats? stats;
  final bool loading;

  const _StatsCard({required this.stats, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: loading && stats == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            )
          : stats == null
              ? const SizedBox.shrink()
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _AverageRatingPanel(stats: stats!),
                    const SizedBox(width: 20),
                    const VerticalDivider(color: AppColors.border, width: 1),
                    const SizedBox(width: 20),
                    Expanded(child: _RatingBarsPanel(stats: stats!)),
                  ],
                ),
    );
  }
}

class _AverageRatingPanel extends StatelessWidget {
  final ShopReviewStats stats;
  const _AverageRatingPanel({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          stats.averageRating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        _StarRow(rating: stats.averageRating, size: 16),
        const SizedBox(height: 4),
        Text(
          '${stats.totalReviews} reviews',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _RatingBarsPanel extends StatelessWidget {
  final ShopReviewStats stats;
  const _RatingBarsPanel({required this.stats});

  @override
  Widget build(BuildContext context) {
    final bars = [
      (5, stats.fiveStar),
      (4, stats.fourStar),
      (3, stats.threeStar),
      (2, stats.twoStar),
      (1, stats.oneStar),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: bars
          .map((b) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: _RatingBar(star: b.$1, count: b.$2, total: stats.totalReviews),
              ))
          .toList(),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final int star;
  final int count;
  final int total;

  const _RatingBar({required this.star, required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        Text(
          '$star',
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        const SizedBox(width: 2),
        const Icon(Icons.star, size: 11, color: AppColors.warning),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 20,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

// ─── Filters ──────────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final TextEditingController searchCtrl;
  final int? ratingFilter;
  final String sort;
  final ValueChanged<int?> onRatingChanged;
  final ValueChanged<String> onSortChanged;

  const _FilterRow({
    required this.searchCtrl,
    required this.ratingFilter,
    required this.sort,
    required this.onRatingChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: searchCtrl,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search reviewer name...',
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
            suffixIcon: searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                    onPressed: () => searchCtrl.clear(),
                  )
                : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _DropdownChip<int?>(
                label: ratingFilter == null ? 'All Ratings' : '$ratingFilter Stars',
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Ratings')),
                  DropdownMenuItem(value: 5, child: Text('5 Stars')),
                  DropdownMenuItem(value: 4, child: Text('4 Stars')),
                  DropdownMenuItem(value: 3, child: Text('3 Stars')),
                  DropdownMenuItem(value: 2, child: Text('2 Stars')),
                  DropdownMenuItem(value: 1, child: Text('1 Star')),
                ],
                value: ratingFilter,
                onChanged: onRatingChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DropdownChip<String>(
                label: _sortLabel(sort),
                items: const [
                  DropdownMenuItem(value: 'latest', child: Text('Latest First')),
                  DropdownMenuItem(value: 'highest', child: Text('Highest Rating')),
                  DropdownMenuItem(value: 'lowest', child: Text('Lowest Rating')),
                ],
                value: sort,
                onChanged: (v) => onSortChanged(v ?? 'latest'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _sortLabel(String sort) {
    switch (sort) {
      case 'highest':
        return 'Highest Rating';
      case 'lowest':
        return 'Lowest Rating';
      default:
        return 'Latest First';
    }
  }
}

class _DropdownChip<T> extends StatelessWidget {
  final String label;
  final List<DropdownMenuItem<T>> items;
  final T value;
  final ValueChanged<T?> onChanged;

  const _DropdownChip({
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: AppColors.surface2,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
        icon: const Icon(Icons.expand_more, color: AppColors.textMuted, size: 18),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}

// ─── Review Card ──────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final ShopReview review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(name: review.reviewerName, avatarUrl: review.reviewerAvatar),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _StarRow(rating: review.rating.toDouble(), size: 12),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                        if (review.updatedAt != null) ...[
                          const SizedBox(width: 6),
                          const Text(
                            'edited',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              _HelpfulBadge(count: review.helpfulCount),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    review.images[i],
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 64,
                      height: 64,
                      color: AppColors.surface3,
                      child: const Icon(Icons.broken_image_outlined,
                          color: AppColors.textMuted, size: 24),
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (review.reportCount > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flag_outlined, size: 12, color: AppColors.error),
                  const SizedBox(width: 4),
                  Text(
                    '${review.reportCount} report${review.reportCount > 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 11, color: AppColors.error),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;

  const _Avatar({required this.name, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : '?';

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(avatarUrl!),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.primaryDark,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final double rating;
  final double size;

  const _StarRow({required this.rating, required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && (rating - i) >= 0.5;
        return Icon(
          half ? Icons.star_half : (filled ? Icons.star : Icons.star_border),
          size: size,
          color: AppColors.warning,
        );
      }),
    );
  }
}

class _HelpfulBadge extends StatelessWidget {
  final int count;
  const _HelpfulBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.thumb_up_outlined, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 3),
        Text(
          '$count',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _PaginationRow extends StatelessWidget {
  final int page;
  final int pages;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _PaginationRow({
    required this.page,
    required this.pages,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final start = (page - 1) * 20 + 1;
    final end = (page * 20).clamp(0, total);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left),
          color: onPrev != null ? AppColors.textPrimary : AppColors.textDim,
        ),
        Text(
          '$start–$end of $total',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          color: onNext != null ? AppColors.textPrimary : AppColors.textDim,
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.star_border_outlined, size: 48, color: AppColors.textDim),
            SizedBox(height: 12),
            Text(
              'No shop reviews yet',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
