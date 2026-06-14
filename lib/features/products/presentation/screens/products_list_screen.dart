import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/cache/cache_keys.dart';
import '../../../../core/providers/cache_providers.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/main_shell.dart';
import '../../../../shared/models/paginated_response.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/last_updated_chip.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../domain/product_models.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _sortOptions = [
  ('recent', 'Recently Updated'),
  ('newest', 'Newest First'),
  ('oldest', 'Oldest First'),
  ('price_asc', 'Price: Low → High'),
  ('price_desc', 'Price: High → Low'),
  ('stock_asc', 'Stock: Low → High'),
  ('stock_desc', 'Stock: High → Low'),
  ('name_asc', 'Name A → Z'),
];

const _stockOptions = [
  (null, 'All Stock'),
  ('in_stock', 'In Stock'),
  ('low_stock', 'Low Stock'),
  ('out_of_stock', 'Out of Stock'),
];

const _kScrollThreshold = 300.0; // px from bottom to trigger next page load

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ProductsListScreen extends ConsumerStatefulWidget {
  const ProductsListScreen({super.key});

  @override
  ConsumerState<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends ConsumerState<ProductsListScreen> {
  // -- Filter state --
  final _searchCtrl = TextEditingController();
  String _search = '';
  String? _status;
  int? _categoryId;
  String? _stockFilter;
  String _sortBy = 'recent';
  bool _discountOnly = false;
  double? _minPrice, _maxPrice;
  int? _minStock, _maxStock;

  // -- Pagination state --
  final List<Product> _products = [];
  int _page = 1;
  int _total = 0;
  bool _hasNextPage = false;
  bool _initialLoading = true;
  bool _loadingMore = false;
  String? _error;

  final _scrollCtrl = ScrollController();
  Timer? _debounce;

  bool get _isFiltered =>
      _search.isNotEmpty ||
      _status != null ||
      _categoryId != null ||
      _stockFilter != null ||
      _sortBy != 'recent' ||
      _discountOnly ||
      _minPrice != null ||
      _maxPrice != null ||
      _minStock != null ||
      _maxStock != null;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);

    // Show cached page-1 data immediately while fetching fresh data
    final cache = ref.read(cacheServiceProvider);
    final cached = cache.getIgnoringTtl<PaginatedResponse<Product>>(
      CacheKeys.productsPage1,
      fromJson: (j) => PaginatedResponse.fromJson(j, Product.fromJson),
    );
    if (cached != null) {
      _products.addAll(cached.data);
      _total = cached.total;
      _hasNextPage = cached.hasNextPage;
      _page = cached.page;
      _initialLoading = false;
    }

    _loadPage(1);
  }

  DateTime? get _lastUpdated =>
      ref.read(cacheServiceProvider).getLastUpdated(CacheKeys.productsPage1);

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<void> _loadPage(int page) async {
    if (page == 1) {
      setState(() {
        _initialLoading = true;
        _error = null;
        _products.clear();
        _hasNextPage = false;
        _total = 0;
      });
    } else {
      if (_loadingMore) return;
      setState(() => _loadingMore = true);
    }

    try {
      final isDraftFilter = _status == 'draft';
      final result = await ref.read(productsRepositoryProvider).getProducts(
            page: page,
            search: _search.isEmpty ? null : _search,
            status: isDraftFilter ? null : _status,
            isDraft: isDraftFilter ? true : null,
            categoryId: _categoryId,
            stockFilter: _stockFilter,
            sortBy: _sortBy,
            discountOnly: _discountOnly,
            minPrice: _minPrice,
            maxPrice: _maxPrice,
            minStock: _minStock,
            maxStock: _maxStock,
          );

      if (!mounted) return;
      setState(() {
        _products.addAll(result.data);
        _page = result.page;
        _total = result.total;
        _hasNextPage = result.hasNextPage;
        _initialLoading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _initialLoading = false;
        _loadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - _kScrollThreshold) {
      if (_hasNextPage && !_loadingMore && !_initialLoading) {
        _loadPage(_page + 1);
      }
    }
  }

  void _applyFilters() {
    _debounce?.cancel();
    _loadPage(1);
    // Also refresh inactive count
    ref.invalidate(inactiveCountProvider);
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _search = v.trim());
        _loadPage(1);
      }
    });
  }

  void _clearFilters() {
    _searchCtrl.clear();
    setState(() {
      _search = '';
      _status = null;
      _categoryId = null;
      _stockFilter = null;
      _sortBy = 'recent';
      _discountOnly = false;
      _minPrice = null;
      _maxPrice = null;
      _minStock = null;
      _maxStock = null;
    });
    _loadPage(1);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final inactiveAsync = ref.watch(inactiveCountProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Products'),
        actions: [
          LastUpdatedChip(
            lastUpdated: _lastUpdated,
            isRefreshing: _initialLoading && _products.isEmpty,
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: _minPrice != null ||
                  _maxPrice != null ||
                  _minStock != null ||
                  _maxStock != null,
              child: const Icon(Icons.tune),
            ),
            tooltip: 'Advanced Filters',
            onPressed: () => _showAdvancedFilters(context),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'View Drafts',
            onPressed: () async {
              await context.push(RouteNames.drafts);
              _loadPage(1);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Product',
            onPressed: () async {
              await context.push(RouteNames.addProduct);
              _loadPage(1);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OfflineBanner(),
          // Stats row
          _StatsRow(total: _total, inactiveAsync: inactiveAsync),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search name, brand, description…',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 12),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),

          // Quick-filter chips
          _QuickFilterRow(
            status: _status,
            categoryId: _categoryId,
            stockFilter: _stockFilter,
            sortBy: _sortBy,
            discountOnly: _discountOnly,
            isFiltered: _isFiltered,
            onStatusChanged: (v) {
              setState(() => _status = v);
              _applyFilters();
            },
            onCategoryChanged: (v) {
              setState(() => _categoryId = v);
              _applyFilters();
            },
            onStockChanged: (v) {
              setState(() => _stockFilter = v);
              _applyFilters();
            },
            onSortChanged: (v) {
              setState(() => _sortBy = v);
              _applyFilters();
            },
            onDiscountToggle: () {
              setState(() => _discountOnly = !_discountOnly);
              _applyFilters();
            },
            onClear: _clearFilters,
          ),

          const Divider(height: 1),

          // Products list
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_initialLoading && _products.isEmpty) {
      return const ShimmerList(count: 8, itemHeight: 80);
    }

    if (_error != null && _products.isEmpty) {
      return ErrorView(
        message: _error!,
        onRetry: () => _loadPage(1),
      );
    }

    if (_products.isEmpty) {
      return const Center(child: Text('No products match your filters.'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(cacheServiceProvider).invalidate(CacheKeys.productsPage1);
        return _loadPage(1);
      },
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        // +1 for the bottom loader / end-of-list indicator
        itemCount: _products.length + 1,
        itemBuilder: (_, i) {
          if (i < _products.length) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ProductCard(
                product: _products[i],
                onTap: () async {
                  await context.push(
                      RouteNames.productDetailPath(_products[i].id.toString()));
                  _loadPage(1);
                },
              ),
            );
          }
          // Bottom indicator
          if (_loadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          if (!_hasNextPage) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'All $_total products loaded',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Advanced filters bottom sheet
  // ---------------------------------------------------------------------------

  void _showAdvancedFilters(BuildContext context) {
    final minPriceCtrl =
        TextEditingController(text: _minPrice?.toString() ?? '');
    final maxPriceCtrl =
        TextEditingController(text: _maxPrice?.toString() ?? '');
    final minStockCtrl =
        TextEditingController(text: _minStock?.toString() ?? '');
    final maxStockCtrl =
        TextEditingController(text: _maxStock?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Advanced Filters',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Text('Price Range (INR)',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: _AdvancedTextField(
                        ctrl: minPriceCtrl, hint: 'Min Price')),
                const SizedBox(width: 12),
                Expanded(
                    child: _AdvancedTextField(
                        ctrl: maxPriceCtrl, hint: 'Max Price')),
              ],
            ),
            const SizedBox(height: 16),
            Text('Stock Range',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: _AdvancedTextField(
                        ctrl: minStockCtrl,
                        hint: 'Min Stock',
                        isInt: true)),
                const SizedBox(width: 12),
                Expanded(
                    child: _AdvancedTextField(
                        ctrl: maxStockCtrl,
                        hint: 'Max Stock',
                        isInt: true)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _minPrice = null;
                        _maxPrice = null;
                        _minStock = null;
                        _maxStock = null;
                      });
                      Navigator.pop(context);
                      _loadPage(1);
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _minPrice =
                            double.tryParse(minPriceCtrl.text.trim());
                        _maxPrice =
                            double.tryParse(maxPriceCtrl.text.trim());
                        _minStock = int.tryParse(minStockCtrl.text.trim());
                        _maxStock = int.tryParse(maxStockCtrl.text.trim());
                      });
                      Navigator.pop(context);
                      _loadPage(1);
                    },
                    child: const Text('Apply'),
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

// ---------------------------------------------------------------------------
// Stats row
// ---------------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  final int total;
  final AsyncValue<int> inactiveAsync;

  const _StatsRow({required this.total, required this.inactiveAsync});

  @override
  Widget build(BuildContext context) {
    final inactive = inactiveAsync.whenOrNull(data: (c) => c);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: [
          _StatChip(label: '$total total', color: AppColors.primary),
          const SizedBox(width: 8),
          _StatChip(
            label: inactive != null ? '$inactive inactive' : '— inactive',
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

// ---------------------------------------------------------------------------
// Quick-filter chips row
// ---------------------------------------------------------------------------

class _QuickFilterRow extends ConsumerWidget {
  final String? status;
  final int? categoryId;
  final String? stockFilter;
  final String sortBy;
  final bool discountOnly;
  final bool isFiltered;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<int?> onCategoryChanged;
  final ValueChanged<String?> onStockChanged;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onDiscountToggle;
  final VoidCallback onClear;

  const _QuickFilterRow({
    required this.status,
    required this.categoryId,
    required this.stockFilter,
    required this.sortBy,
    required this.discountOnly,
    required this.isFiltered,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.onStockChanged,
    required this.onSortChanged,
    required this.onDiscountToggle,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    final categoryLabel = categories.whenOrNull(
          data: (cats) => categoryId != null
              ? cats
                  .firstWhere((c) => c.id == categoryId,
                      orElse: () => Category(id: 0, name: 'Category'))
                  .name
              : null,
        ) ??
        (categoryId != null ? 'Category' : null);

    final sortLabel = _sortOptions
        .firstWhere((o) => o.$1 == sortBy,
            orElse: () => _sortOptions.first)
        .$2;

    final stockLabel = _stockOptions
        .firstWhere((o) => o.$1 == stockFilter,
            orElse: () => _stockOptions.first)
        .$2;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _DropdownChip<String?>(
            label: status == null
                ? 'All Status'
                : status == 'active'
                    ? 'Active'
                    : status == 'draft'
                        ? 'Draft'
                        : 'Inactive',
            isActive: status != null,
            items: const [
              DropdownMenuItem(value: null, child: Text('All Status')),
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
              DropdownMenuItem(value: 'draft', child: Text('Draft')),
            ],
            value: status,
            onChanged: onStatusChanged,
          ),
          const SizedBox(width: 8),
          _DropdownChip<int?>(
            label: categoryLabel ?? 'All Categories',
            isActive: categoryId != null,
            items: [
              const DropdownMenuItem(
                  value: null, child: Text('All Categories')),
              ...categories.whenOrNull(
                    data: (cats) => cats
                        .map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ))
                        .toList(),
                  ) ??
                  [],
            ],
            value: categoryId,
            onChanged: onCategoryChanged,
          ),
          const SizedBox(width: 8),
          _DropdownChip<String?>(
            label: stockLabel,
            isActive: stockFilter != null,
            items: _stockOptions
                .map((o) =>
                    DropdownMenuItem(value: o.$1, child: Text(o.$2)))
                .toList(),
            value: stockFilter,
            onChanged: onStockChanged,
          ),
          const SizedBox(width: 8),
          _DropdownChip<String>(
            label: sortLabel,
            isActive: sortBy != 'recent',
            items: _sortOptions
                .map((o) =>
                    DropdownMenuItem(value: o.$1, child: Text(o.$2)))
                .toList(),
            value: sortBy,
            onChanged: (v) {
              if (v != null) onSortChanged(v);
            },
          ),
          const SizedBox(width: 8),
          _ToggleChip(
            label: 'Discount Only',
            active: discountOnly,
            onTap: onDiscountToggle,
          ),
          if (isFiltered) ...[
            const SizedBox(width: 8),
            ActionChip(
              label: const Text('× Clear'),
              onPressed: onClear,
              backgroundColor: AppColors.errorBg,
              side: const BorderSide(color: AppColors.error, width: 0.5),
              labelStyle:
                  const TextStyle(color: AppColors.error, fontSize: 12),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chip helpers
// ---------------------------------------------------------------------------

class _DropdownChip<T> extends StatelessWidget {
  final String label;
  final bool isActive;
  final List<DropdownMenuItem<T>> items;
  final T value;
  final ValueChanged<T?> onChanged;

  const _DropdownChip({
    required this.label,
    required this.isActive,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textMuted;
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isDense: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 16, color: color),
          style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal),
          dropdownColor: AppColors.surface2,
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleChip(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.check_box : Icons.check_box_outline_blank,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdvancedTextField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final bool isInt;

  const _AdvancedTextField(
      {required this.ctrl, required this.hint, this.isInt = false});

  @override
  Widget build(BuildContext context) => TextField(
        controller: ctrl,
        keyboardType: isInt
            ? TextInputType.number
            : const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          filled: true,
          fillColor: AppColors.surface2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      );
}
