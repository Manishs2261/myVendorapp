import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/main_shell.dart';
import '../../../../features/products/domain/product_models.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../providers/promotions_provider.dart';

class PromotionsScreen extends ConsumerStatefulWidget {
  const PromotionsScreen({super.key});

  @override
  ConsumerState<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends ConsumerState<PromotionsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(promotionsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(promotionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Promotions'),
            Text(
              'Sponsor your products to boost visibility',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.normal,
                  ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: state.loading && state.products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.products.isEmpty
              ? ErrorView(
                  message: state.error!,
                  onRetry: () => ref.read(promotionsProvider.notifier).load(),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(promotionsProvider.notifier).load(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _StatsRow(state: state),
                      const SizedBox(height: 16),
                      _InfoBanner(),
                      const SizedBox(height: 20),
                      _SectionHeader(),
                      const SizedBox(height: 8),
                      if (state.products.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text('No products yet'),
                          ),
                        )
                      else
                        ...state.products.map(
                          (p) => _ProductSponsorTile(
                            product: p,
                            isRequesting:
                                state.requestingIds.contains(p.id),
                            onRequest: () => _handleRequest(p),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Future<void> _handleRequest(Product p) async {
    final success = await ref
        .read(promotionsProvider.notifier)
        .requestSponsorship(p.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sponsorship requested for "${p.name}"'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final err = ref.read(promotionsProvider).error ?? 'Request failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.error),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Stats Row
// ---------------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  final PromotionsState state;
  const _StatsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          label: 'Active Sponsors',
          value: '${state.activeCount}',
          icon: Icons.campaign,
          iconColor: AppColors.tertiary,
        ),
        StatCard(
          label: 'Pending Approval',
          value: '${state.pendingCount}',
          icon: Icons.hourglass_top,
          iconColor: AppColors.warning,
        ),
        StatCard(
          label: 'Rejected',
          value: '${state.rejectedCount}',
          icon: Icons.cancel_outlined,
          iconColor: AppColors.error,
        ),
        StatCard(
          label: 'Can Request',
          value: '${state.canRequestCount}',
          icon: Icons.add_circle_outline,
          iconColor: AppColors.textMuted,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Info Banner
// ---------------------------------------------------------------------------

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.campaign, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How Sponsorship Works',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                    children: const [
                      TextSpan(
                          text:
                              'Sponsored products appear with a subtle '),
                      TextSpan(
                        text: '"Ad"',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: ' badge on their card, feature in the '),
                      TextSpan(
                        text: '"Featured Picks"',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                          text:
                              ' homepage carousel, and are injected every 5 products in browsing pages. Request sponsorship below — admin reviews and approves.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'All Products — Sponsor Status',
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Product row
// ---------------------------------------------------------------------------

class _ProductSponsorTile extends StatelessWidget {
  final Product product;
  final bool isRequesting;
  final VoidCallback onRequest;

  const _ProductSponsorTile({
    required this.product,
    required this.isRequesting,
    required this.onRequest,
  });

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductDetailsSheet(
        product: product,
        isRequesting: isRequesting,
        onRequest: () {
          Navigator.of(context).pop();
          onRequest();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetails(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              _ProductImage(urls: product.imageUrls),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${AppFormatters.currency(product.price)}'
                      '${product.category != null ? ' · ${product.category}' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusWidget(
                product: product,
                isRequesting: isRequesting,
                onRequest: onRequest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Product Details Bottom Sheet
// ---------------------------------------------------------------------------

class _ProductDetailsSheet extends StatelessWidget {
  final Product product;
  final bool isRequesting;
  final VoidCallback onRequest;

  const _ProductDetailsSheet({
    required this.product,
    required this.isRequesting,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: product.imageUrls.isNotEmpty
                  ? Image.network(
                      product.imageUrls.first,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              product.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // Price + category
            Row(
              children: [
                Text(
                  AppFormatters.currency(product.price),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (product.category != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surface3,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.category!,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Divider
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 20),

            // Sponsorship status section
            Text(
              'Sponsorship Status',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _StatusDetail(product: product),
            const SizedBox(height: 20),

            // Action button
            if (!product.isSponsored && product.sponsorStatus == 'none')
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isRequesting ? null : onRequest,
                  icon: isRequesting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.campaign),
                  label: Text(isRequesting
                      ? 'Submitting…'
                      : 'Request Sponsorship'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        height: 180,
        color: AppColors.surface3,
        child: const Center(
          child: Icon(Icons.image, size: 48, color: AppColors.textDim),
        ),
      );
}

class _StatusDetail extends StatelessWidget {
  final Product product;
  const _StatusDetail({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (product.isSponsored) {
      return _StatusCard(
        color: AppColors.tertiary,
        icon: Icons.campaign,
        title: 'Actively Sponsored',
        description:
            'This product is live with a sponsored badge and appears in Featured Picks and browsing injections.',
      );
    }

    if (product.sponsorStatus == 'pending') {
      return _StatusCard(
        color: AppColors.warning,
        icon: Icons.hourglass_top,
        title: 'Pending Admin Review',
        description:
            'Your sponsorship request has been submitted. An admin will review and approve or reject it shortly.',
      );
    }

    if (product.sponsorStatus == 'rejected') {
      return _StatusCard(
        color: AppColors.error,
        icon: Icons.cancel_outlined,
        title: 'Request Rejected',
        description:
            'Your previous sponsorship request was rejected by the admin. You can submit a new request.',
      );
    }

    // none / eligible
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface3,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.add_circle_outline,
              color: AppColors.textMuted, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This product is eligible for sponsorship. Tap "Request Sponsorship" to submit for admin review.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String description;

  const _StatusCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final List<String> urls;
  const _ProductImage({required this.urls});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: urls.isNotEmpty
          ? Image.network(
              urls.first,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        width: 48,
        height: 48,
        color: AppColors.surface3,
        child: const Icon(Icons.image, size: 20, color: AppColors.textDim),
      );
}

class _StatusWidget extends StatelessWidget {
  final Product product;
  final bool isRequesting;
  final VoidCallback onRequest;

  const _StatusWidget({
    required this.product,
    required this.isRequesting,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    if (isRequesting) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (product.isSponsored) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Chip(label: '📢 Sponsored', color: AppColors.tertiary),
          const SizedBox(height: 4),
          Text(
            'Active',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ],
      );
    }

    if (product.sponsorStatus == 'pending') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Chip(label: '⏳ Pending Review', color: AppColors.warning),
          const SizedBox(height: 4),
          Text(
            'Awaiting admin',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ],
      );
    }

    if (product.sponsorStatus == 'rejected') {
      return _Chip(label: '✕ Rejected', color: AppColors.error);
    }

    return TextButton(
      onPressed: onRequest,
      style: TextButton.styleFrom(
        backgroundColor: AppColors.primaryGlow,
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('📢 Request Sponsorship',
          style: TextStyle(fontSize: 11)),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
