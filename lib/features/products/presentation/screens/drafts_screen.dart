import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/products_repository.dart';
import '../../domain/product_models.dart';
import '../providers/products_provider.dart';

class DraftsScreen extends ConsumerStatefulWidget {
  const DraftsScreen({super.key});

  @override
  ConsumerState<DraftsScreen> createState() => _DraftsScreenState();
}

class _DraftsScreenState extends ConsumerState<DraftsScreen> {
  List<Product> _drafts = [];
  bool _loading = false;
  String? _error;
  int? _deletingId;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    setState(() { _loading = true; _error = null; });
    try {
      final repo = ref.read(productsRepositoryProvider) as ProductsRepository;
      final result = await repo.getProducts(isDraft: true, limit: 100);
      if (mounted) setState(() => _drafts = result.data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _publish(Product draft) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Publish Product'),
        content: Text('Publish "${draft.name}" to your store?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Publish')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final repo = ref.read(productsRepositoryProvider) as ProductsRepository;
      await repo.publishDraft(draft.id);
      ref.invalidate(productsNotifierProvider);
      if (mounted) {
        setState(() => _drafts.removeWhere((d) => d.id == draft.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product published!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish: $e')),
        );
      }
    }
  }

  Future<void> _delete(Product draft) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Draft'),
        content: Text('Delete "${draft.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deletingId = draft.id);
    try {
      final repo = ref.read(productsRepositoryProvider) as ProductsRepository;
      await repo.deleteProduct(draft.id);
      if (mounted) {
        setState(() {
          _drafts.removeWhere((d) => d.id == draft.id);
          _deletingId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Draft deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _deletingId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  int _completionPct(Product p) {
    int score = 0;
    if (p.name.isNotEmpty) score += 20;
    if (p.price > 0) score += 20;
    if (p.categoryId != null) score += 20;
    if (p.description.isNotEmpty) score += 15;
    if (p.imageUrls.isNotEmpty) score += 15;
    if (p.brand != null && p.brand!.isNotEmpty) score += 5;
    if (p.tags.isNotEmpty) score += 5;
    return score;
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Not saved';
    return DateFormat('MMM d, h:mm a').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drafts (${_drafts.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDrafts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.addProduct),
        icon: const Icon(Icons.add),
        label: const Text('New Product'),
        shape: const StadiumBorder(),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: _loadDrafts, child: const Text('Retry')),
                    ],
                  ),
                )
              : _drafts.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _loadDrafts,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _drafts.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _DraftCard(
                          draft: _drafts[i],
                          completionPct: _completionPct(_drafts[i]),
                          lastSaved: _formatDate(_drafts[i].draftSavedAt),
                          isDeleting: _deletingId == _drafts[i].id,
                          onEdit: () => context.push(
                            RouteNames.editProductPath(_drafts[i].id.toString()),
                            extra: _drafts[i],
                          ),
                          onPublish: () => _publish(_drafts[i]),
                          onDelete: () => _delete(_drafts[i]),
                        ),
                      ),
                    ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit_note, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text('No drafts yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text(
            'Start a product and tap "Save as Draft"\nto come back to it later.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push(RouteNames.addProduct),
            icon: const Icon(Icons.add),
            label: const Text('Create Product'),
          ),
        ],
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  final Product draft;
  final int completionPct;
  final String lastSaved;
  final bool isDeleting;
  final VoidCallback onEdit;
  final VoidCallback onPublish;
  final VoidCallback onDelete;

  const _DraftCard({
    required this.draft,
    required this.completionPct,
    required this.lastSaved,
    required this.isDeleting,
    required this.onEdit,
    required this.onPublish,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = completionPct >= 80
        ? Colors.green
        : completionPct >= 40
            ? Colors.orange
            : AppColors.secondary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: draft.imageUrls.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: draft.imageUrls.first,
                            fit: BoxFit.cover,
                            errorWidget: (ctx, url, err) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        draft.name.isNotEmpty ? draft.name : 'Untitled',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        draft.category ?? 'No category',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Last saved: $lastSaved',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Completion bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: completionPct / 100,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(progressColor),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$completionPct%',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Action buttons
            Row(
              children: [
                OutlinedButton(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onPublish,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Publish'),
                ),
                const Spacer(),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: isDeleting
                      ? const Padding(
                          padding: EdgeInsets.all(6),
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                        )
                      : IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.surface3,
        child: const Icon(Icons.image_outlined, color: AppColors.textMuted, size: 24),
      );
}
