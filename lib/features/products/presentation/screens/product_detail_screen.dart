import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../data/products_repository.dart';
import '../../domain/product_models.dart';
import '../providers/products_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const ProductDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _currentImage = 0;
  bool _deleting = false;

  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Delete "${product.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      final repo = ref.read(productsRepositoryProvider) as ProductsRepository;
      await repo.deleteProduct(product.id);
      if (!mounted) return;
      ref.invalidate(productsNotifierProvider);
      ref.invalidate(dashboardNotifierProvider);
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(isDarkModeProvider);
    final productAsync =
        ref.watch(productDetailProvider(int.parse(widget.id)));

    return Scaffold(
      body: productAsync.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: ErrorView(message: e.toString()),
        ),
        data: (product) => _ProductView(
          product: product,
          currentImage: _currentImage,
          deleting: _deleting,
          onImageChanged: (i) => setState(() => _currentImage = i),
          onDelete: () => _confirmDelete(product),
        ),
      ),
    );
  }
}

class _ProductView extends StatelessWidget {
  final Product product;
  final int currentImage;
  final bool deleting;
  final ValueChanged<int> onImageChanged;
  final VoidCallback onDelete;

  const _ProductView({
    required this.product,
    required this.currentImage,
    required this.deleting,
    required this.onImageChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => context.push(
              RouteNames.editProductPath(product.id.toString()),
              extra: product,
            ),
          ),
          deleting
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Delete',
                  onPressed: onDelete,
                ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _ImageGallery(product: product, currentImage: currentImage, onImageChanged: onImageChanged)),
          SliverToBoxAdapter(child: _DetailBody(product: product)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image gallery
// ---------------------------------------------------------------------------

class _ImageGallery extends StatefulWidget {
  final Product product;
  final int currentImage;
  final ValueChanged<int> onImageChanged;

  const _ImageGallery({
    required this.product,
    required this.currentImage,
    required this.onImageChanged,
  });

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentImage);
  }

  @override
  void didUpdateWidget(covariant _ImageGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentImage != widget.currentImage) {
      if (_pageController.hasClients) {
        final currentPage = _pageController.page?.round() ?? 0;
        if (currentPage != widget.currentImage) {
          _pageController.animateToPage(
            widget.currentImage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openFullScreen(BuildContext context, int initialIndex) async {
    final images = widget.product.imageUrls;
    final heroPrefix = 'product_image_${widget.product.id}';
    
    final newIndex = await Navigator.push<int>(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) => _FullScreenImageGallery(
          imageUrls: images,
          initialIndex: initialIndex,
          heroTagPrefix: heroPrefix,
        ),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
    
    if (newIndex != null && mounted) {
      widget.onImageChanged(newIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.product.imageUrls;

    if (images.isEmpty) {
      return Container(
        height: 240,
        color: AppColors.surface,
        child: Center(
          child: Icon(Icons.camera_alt_outlined,
              size: 48, color: AppColors.textMuted),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: widget.onImageChanged,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _openFullScreen(context, i),
                      child: Hero(
                        tag: 'product_image_${widget.product.id}_$i',
                        child: CachedNetworkImage(
                          imageUrl: images[i],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => _shimmerLoading(),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.surface,
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            color: Colors.black.withValues(alpha: 0.5),
                            child: Text(
                              '${widget.currentImage + 1}/${images.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: widget.currentImage == i ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.currentImage == i
                      ? AppColors.primary
                      : AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => widget.onImageChanged(i),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.currentImage == i
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: CachedNetworkImage(
                        imageUrl: images[i],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _shimmerLoading(),
                        errorWidget: (context, url, error) => Container(color: AppColors.surface),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _shimmerLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.surface2,
      highlightColor: AppColors.surface3,
      child: Container(
        color: Colors.white,
      ),
    );
  }
}

class _FullScreenImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String heroTagPrefix;

  const _FullScreenImageGallery({
    required this.imageUrls,
    required this.initialIndex,
    required this.heroTagPrefix,
  });

  @override
  State<_FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<_FullScreenImageGallery> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(widget.imageUrls[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 3.0,
                heroAttributes: PhotoViewHeroAttributes(
                  tag: '${widget.heroTagPrefix}_$index',
                ),
              );
            },
            itemCount: widget.imageUrls.length,
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context, _currentIndex),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail body
// ---------------------------------------------------------------------------

class _DetailBody extends StatelessWidget {
  final Product product;
  const _DetailBody({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(product.name,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: product.status.name),
            ],
          ),

          // Category
          if (product.category != null) ...[
            const SizedBox(height: 4),
            Text(product.category!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.primary)),
          ],

          const SizedBox(height: 14),

          // Price block
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                AppFormatters.currency(product.price),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (product.originalPrice != null &&
                  product.originalPrice! > product.price) ...[
                const SizedBox(width: 10),
                Text(
                  AppFormatters.currency(product.originalPrice!),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                if (product.discountPercentage != null) ...[
                  const SizedBox(width: 8),
                  _AmberChip('-${product.discountPercentage}% off'),
                ],
              ],
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              _StatCol(
                icon: Icons.inventory_2_outlined,
                value: '${product.stock}',
                label: 'STOCK',
              ),
              _StatCol(
                icon: Icons.visibility_outlined,
                value: '${product.viewCount}',
                label: 'CLICKS',
              ),
              _StatCol(
                icon: Icons.search,
                value: '0',
                label: 'SEARCHES',
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // Brand
          if (product.brand != null && product.brand!.isNotEmpty) ...[
            _SectionLabel('BRAND'),
            const SizedBox(height: 4),
            Text(product.brand!, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
          ],

          // Description
          if (product.description.isNotEmpty) ...[
            _SectionLabel('DESCRIPTION'),
            const SizedBox(height: 4),
            Text(product.description,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 16),
          ],

          // Tags
          if (product.tags.isNotEmpty) ...[
            _SectionLabel('TAGS'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: product.tags
                  .map((t) => Chip(
                        label: Text(t,
                            style: const TextStyle(fontSize: 12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Specifications
          if (product.specifications.isNotEmpty) ...[
            _SectionLabel('SPECIFICATIONS'),
            const SizedBox(height: 8),
            _SpecsTable(specs: product.specifications),
            const SizedBox(height: 16),
          ],

          // Color variations
          if (product.colorVariations.isNotEmpty) ...[
            _SectionLabel('COLORS'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: product.colorVariations
                  .map((hex) => _ColorDot(hex: hex))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Timestamps
          const Divider(),
          const SizedBox(height: 8),
          _Timestamps(product: product),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
      );
}

class _StatCol extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCol(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: AppColors.textMuted, letterSpacing: 0.6)),
        ],
      ),
    );
  }
}

class _AmberChip extends StatelessWidget {
  final String label;
  const _AmberChip(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: Colors.amber,
                fontWeight: FontWeight.w600)),
      );
}

class _SpecsTable extends StatelessWidget {
  final Map<String, String> specs;
  const _SpecsTable({required this.specs});

  @override
  Widget build(BuildContext context) {
    final entries = specs.entries.toList();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: List.generate(entries.length, (i) {
          final e = entries[i];
          return Container(
            decoration: BoxDecoration(
              border: i < entries.length - 1
                  ? Border(
                      bottom: BorderSide(color: AppColors.border))
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Text(e.key,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textMuted)),
                  ),
                ),
                Container(width: 1, height: 36, color: AppColors.border),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Text(e.value,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final String hex;
  const _ColorDot({required this.hex});

  @override
  Widget build(BuildContext context) {
    final color = _parseHex(hex);
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 2),
      ),
    );
  }

  Color _parseHex(String hex) {
    final clean = hex.replaceAll('#', '').padLeft(6, '0');
    final value = int.tryParse('FF$clean', radix: 16);
    return value != null ? Color(value) : AppColors.textMuted;
  }
}

class _Timestamps extends StatelessWidget {
  final Product product;
  const _Timestamps({required this.product});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: AppColors.textMuted);

    final parts = <String>[];
    if (product.createdAt != null) {
      parts.add('Created: ${AppFormatters.dateTime(product.createdAt!)}');
    }
    if (product.updatedAt != null) {
      parts.add('Updated: ${AppFormatters.dateTime(product.updatedAt!)}');
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(parts.join('   •   '), style: style);
  }
}
