import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/status_badge.dart';
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

  @override
  Widget build(BuildContext context) {
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
          onImageChanged: (i) => setState(() => _currentImage = i),
        ),
      ),
    );
  }
}

class _ProductView extends StatelessWidget {
  final Product product;
  final int currentImage;
  final ValueChanged<int> onImageChanged;

  const _ProductView({
    required this.product,
    required this.currentImage,
    required this.onImageChanged,
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

class _ImageGallery extends StatelessWidget {
  final Product product;
  final int currentImage;
  final ValueChanged<int> onImageChanged;

  const _ImageGallery({
    required this.product,
    required this.currentImage,
    required this.onImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final images = product.imageUrls;

    if (images.isEmpty) {
      return Container(
        height: 240,
        color: AppColors.surface,
        child: const Center(
          child: Icon(Icons.camera_alt_outlined,
              size: 48, color: AppColors.textMuted),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: onImageChanged,
            itemBuilder: (_, i) => Image.network(
              images[i],
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.surface,
                child: const Icon(Icons.broken_image_outlined,
                    size: 48, color: AppColors.textMuted),
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
                width: currentImage == i ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: currentImage == i
                      ? AppColors.primary
                      : AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => onImageChanged(i),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Image.network(
                      images[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(color: AppColors.surface),
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
                  ? const Border(
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
