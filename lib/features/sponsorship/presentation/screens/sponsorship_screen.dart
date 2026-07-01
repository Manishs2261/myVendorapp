import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/main_shell.dart';
import '../../../../features/products/presentation/providers/products_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/sponsorship_models.dart';
import '../providers/sponsorship_provider.dart';

class SponsorshipScreen extends ConsumerStatefulWidget {
  const SponsorshipScreen({super.key});

  @override
  ConsumerState<SponsorshipScreen> createState() => _SponsorshipScreenState();
}

class _SponsorshipScreenState extends ConsumerState<SponsorshipScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(sponsorshipProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(isDarkModeProvider);
    final state = ref.watch(sponsorshipProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sponsorship'),
            Text(
              'Apply for vendor sponsorship to boost your shop visibility',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.normal,
                  ),
            ),
          ],
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(sponsorshipProvider.notifier).load(),
          ),
        ],
      ),
      body: state.loading && state.plans.isEmpty && state.applications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.plans.isEmpty
              ? ErrorView(
                  message: state.error!,
                  onRetry: () => ref.read(sponsorshipProvider.notifier).load(),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(sponsorshipProvider.notifier).load(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Section 1 — active sponsorship card
                      if (state.activeApplication != null) ...[
                        _ActiveSponsorshipCard(app: state.activeApplication!),
                        const SizedBox(height: 20),
                      ],

                      // Section 2 — available plans
                      _SectionHeader(
                        title: 'Sponsorship Plans',
                        subtitle:
                            'Choose a plan to boost your shop\'s visibility across the marketplace.',
                      ),
                      const SizedBox(height: 12),
                      if (state.plans.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No plans available',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                        )
                      else
                        ...state.plans.asMap().entries.map((entry) {
                          final index = entry.key;
                          final plan = entry.value;
                          final isMostPopular = index == 0;
                          final isBestValue = state.plans.length > 1 &&
                              index == state.plans.length - 1;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PlanCard(
                              plan: plan,
                              alreadyApplied:
                                  state.hasPendingForPlan(plan.id),
                              isMostPopular: isMostPopular,
                              isBestValue: isBestValue,
                              onApply: () => _showApplySheet(plan),
                            ),
                          );
                        }),

                      // Section 3 — application history
                      if (state.applications.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _SectionHeader(title: 'My Applications'),
                        const SizedBox(height: 12),
                        ...state.applications.map(
                          (app) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ApplicationTile(
                              app: app,
                              onCancel: () => _handleCancel(app.id),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Future<void> _showApplySheet(SponsorshipPlan plan) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ApplySheet(
        plan: plan,
        onConfirm: (request) => _handleApply(request),
      ),
    );
  }

  Future<void> _handleApply(SponsorApplyRequest request) async {
    final success =
        await ref.read(sponsorshipProvider.notifier).apply(request);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sponsorship applied successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final err =
          ref.read(sponsorshipProvider).error ?? 'Failed to apply for sponsorship';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _handleCancel(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Sponsorship'),
        content: const Text(
            'Are you sure you want to cancel this pending application?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('Yes, Cancel', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final success = await ref.read(sponsorshipProvider.notifier).cancel(id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application cancelled.')),
      );
    } else {
      final err = ref.read(sponsorshipProvider).error ?? 'Failed to cancel';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.error),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Section Header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Active Sponsorship Card
// ---------------------------------------------------------------------------

class _ActiveSponsorshipCard extends StatelessWidget {
  final SponsorshipApplication app;
  const _ActiveSponsorshipCard({required this.app});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planName = app.plan?.name ?? 'Sponsorship';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header label
          Text(
            'ACTIVE SPONSORSHIP',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),

          // Plan name + days left badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (app.startDate != null && app.endDate != null)
                      Text(
                        '${AppFormatters.date(app.startDate!)} → ${AppFormatters.date(app.endDate!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      '${app.daysLeft}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'days left',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: app.progressFraction,
              minHeight: 6,
              backgroundColor: AppColors.border,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 14),

          // Stats grid
          Row(
            children: [
              _StatCol(label: 'Views', value: '${app.viewCount}'),
              _StatCol(label: 'Clicks', value: '${app.clickCount}'),
              _StatCol(
                  label: 'CTR',
                  value: '${app.ctr.toStringAsFixed(1)}%'),
              _StatCol(
                  label: 'Duration',
                  value: '${app.plan?.durationDays ?? 30}d'),
            ],
          ),

          // Location chips
          if (app.targetLocations.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ChipRow(
              icon: Icons.location_on,
              chips: app.targetLocations,
            ),
          ],

          // Keyword chips
          if (app.targetKeywords.isNotEmpty) ...[
            const SizedBox(height: 6),
            _ChipRow(
              icon: Icons.search,
              chips: app.targetKeywords,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  const _StatCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  final IconData icon;
  final List<String> chips;
  const _ChipRow({required this.icon, required this.chips});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: chips
                .map(
                  (c) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surface3,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      c,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppColors.textMuted),
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

// ---------------------------------------------------------------------------
// Plan Card
// ---------------------------------------------------------------------------

class _PlanCard extends StatelessWidget {
  final SponsorshipPlan plan;
  final bool alreadyApplied;
  final bool isMostPopular;
  final bool isBestValue;
  final VoidCallback onApply;

  const _PlanCard({
    required this.plan,
    required this.alreadyApplied,
    required this.isMostPopular,
    required this.isBestValue,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMostPopular
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges
          if (isMostPopular || isBestValue)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Wrap(
                spacing: 8,
                children: [
                  if (isMostPopular) _Badge('MOST POPULAR', AppColors.primary),
                  if (isBestValue) _Badge('BEST VALUE', AppColors.warning),
                ],
              ),
            ),

          // Name + description
          Text(
            plan.name,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (plan.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                plan.description,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.textMuted),
              ),
            ),
          const SizedBox(height: 12),

          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${plan.price.toStringAsFixed(0)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${plan.durationDays} days · ₹${plan.pricePerDay.toStringAsFixed(0)}/day',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Features
          _FeatureItem('Homepage carousel'),
          _FeatureItem('Search result priority'),
          _FeatureItem(
              'Location targeting (${plan.maxLocations} cities)'),
          _FeatureItem(
              'Category targeting (${plan.maxCategories} categories)'),
          _FeatureItem('Priority level ${plan.priority}'),
          const SizedBox(height: 16),

          // Action button
          SizedBox(
            width: double.infinity,
            child: alreadyApplied
                ? OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Already Applied',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : AppButton(
                    label: 'Apply',
                    onTap: onApply,
                  ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;
  const _FeatureItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Application Tile
// ---------------------------------------------------------------------------

class _ApplicationTile extends StatelessWidget {
  final SponsorshipApplication app;
  final VoidCallback onCancel;

  const _ApplicationTile({required this.app, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planName = app.plan?.name ?? 'Plan #${app.planId}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan name + status
          Row(
            children: [
              Expanded(
                child: Text(
                  planName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              StatusBadge(status: app.status),
            ],
          ),
          const SizedBox(height: 12),

          // Progress stepper
          _StatusStepper(status: app.status),
          const SizedBox(height: 12),

          // Date info
          Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 13, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  _buildDateText(),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          if (app.createdAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  const SizedBox(width: 18),
                  Text(
                    'Applied ${AppFormatters.date(app.createdAt!)}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              _InlineStat(label: 'Views', value: '${app.viewCount}'),
              const SizedBox(width: 20),
              _InlineStat(label: 'Clicks', value: '${app.clickCount}'),
              const SizedBox(width: 20),
              _InlineStat(
                  label: 'CTR',
                  value: '${app.ctr.toStringAsFixed(1)}%'),
            ],
          ),

          // Category chips
          if (app.targetCategories.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: app.targetCategories
                  .map((id) => _SmallChip('#$id'))
                  .toList(),
            ),
          ],

          // Location chips
          if (app.targetLocations.isNotEmpty) ...[
            const SizedBox(height: 6),
            _ChipRow(icon: Icons.location_on, chips: app.targetLocations),
          ],

          // Keyword chips
          if (app.targetKeywords.isNotEmpty) ...[
            const SizedBox(height: 6),
            _ChipRow(icon: Icons.search, chips: app.targetKeywords),
          ],

          // Admin notes (rejection reason)
          if (app.adminNotes != null && app.adminNotes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: AppColors.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      app.adminNotes!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Cancel button
          if (app.status == 'pending') ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                ),
                child: const Text('Cancel Application'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _buildDateText() {
    if (app.startDate != null && app.endDate != null) {
      final elapsed = app.daysElapsed;
      final total = app.plan?.durationDays ?? 30;
      return '${AppFormatters.date(app.startDate!)} – ${AppFormatters.date(app.endDate!)} · $elapsed of $total days elapsed';
    }
    return '';
  }
}

class _StatusStepper extends StatelessWidget {
  final String status;
  const _StatusStepper({required this.status});

  static const _steps = ['Applied', 'Reviewed', 'Active', 'Ended'];

  int _activeIndex() {
    return switch (status.toLowerCase()) {
      'pending' => 0,
      'approved' => 1,
      'active' => 2,
      'rejected' || 'cancelled' || 'expired' || 'ended' => 3,
      _ => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeIndex();
    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final lineIndex = i ~/ 2;
          final filled = lineIndex < active;
          return Expanded(
            child: Container(
              height: 2,
              color: filled ? AppColors.success : AppColors.border,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final isDone = stepIndex <= active;
        final isActive = stepIndex == active;
        return Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? AppColors.success : AppColors.surface3,
                border: isActive
                    ? Border.all(
                        color: AppColors.success, width: 2)
                    : Border.all(color: AppColors.border),
              ),
              child: isDone
                  ? const Icon(Icons.check,
                      size: 11, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              _steps[stepIndex],
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDone
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                    fontSize: 9,
                  ),
            ),
          ],
        );
      }),
    );
  }
}

class _InlineStat extends StatelessWidget {
  final String label;
  final String value;
  const _InlineStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _SmallChip extends StatelessWidget {
  final String label;
  const _SmallChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Apply Bottom Sheet
// ---------------------------------------------------------------------------

class _ApplySheet extends ConsumerStatefulWidget {
  final SponsorshipPlan plan;
  final Future<void> Function(SponsorApplyRequest) onConfirm;

  const _ApplySheet({required this.plan, required this.onConfirm});

  @override
  ConsumerState<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends ConsumerState<_ApplySheet> {
  final Set<int> _selectedCategories = {};
  final List<String> _locations = [];
  final List<String> _keywords = [];
  final _locationController = TextEditingController();
  final _keywordController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _locationController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  void _addLocation() {
    final val = _locationController.text.trim();
    if (val.isEmpty) return;
    if (_locations.length >= widget.plan.maxLocations) return;
    setState(() {
      _locations.add(val);
      _locationController.clear();
    });
  }

  void _addKeyword() {
    final val = _keywordController.text.trim();
    if (val.isEmpty) return;
    setState(() {
      _keywords.add(val);
      _keywordController.clear();
    });
  }

  Future<void> _submit() async {
    if (_locations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one target location')),
      );
      return;
    }
    setState(() => _submitting = true);
    final request = SponsorApplyRequest(
      planId: widget.plan.id,
      targetCategories: _selectedCategories.toList(),
      targetLocations: _locations,
      targetKeywords: _keywords,
    );
    await widget.onConfirm(request);
    if (mounted) {
      setState(() => _submitting = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
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

            // Header
            Text(
              'Apply for ${widget.plan.name}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '₹${widget.plan.price.toStringAsFixed(0)} · ${widget.plan.durationDays} days',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 20),

            // Location targeting
            Text(
              'Target Locations (max ${widget.plan.maxLocations})',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _locationController,
                    label: 'City name',
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _locations.length < widget.plan.maxLocations
                      ? _addLocation
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (_locations.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _locations
                      .map((loc) => _RemovableChip(
                            label: loc,
                            onRemove: () =>
                                setState(() => _locations.remove(loc)),
                          ))
                      .toList(),
                ),
              ),
            const SizedBox(height: 20),

            // Category targeting
            Text(
              'Target Categories (max ${widget.plan.maxCategories})',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            categoriesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Text(
                'Could not load categories',
                style: TextStyle(color: AppColors.textMuted),
              ),
              data: (categories) => Wrap(
                spacing: 8,
                runSpacing: 6,
                children: categories.map((cat) {
                  final selected = _selectedCategories.contains(cat.id);
                  final atMax = _selectedCategories.length >=
                      widget.plan.maxCategories;
                  return FilterChip(
                    label: Text(cat.name),
                    selected: selected,
                    onSelected: (!selected && atMax)
                        ? null
                        : (val) {
                            setState(() {
                              if (val) {
                                _selectedCategories.add(cat.id);
                              } else {
                                _selectedCategories.remove(cat.id);
                              }
                            });
                          },
                    selectedColor:
                        AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                    side: BorderSide(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.border,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Keyword targeting
            Text(
              'Target Keywords',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _keywordController,
                    label: 'Search keyword',
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addKeyword,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (_keywords.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _keywords
                      .map((kw) => _RemovableChip(
                            label: kw,
                            onRemove: () =>
                                setState(() => _keywords.remove(kw)),
                          ))
                      .toList(),
                ),
              ),
            const SizedBox(height: 28),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Confirm & Apply',
                loading: _submitting,
                onTap: _submitting ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemovableChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _RemovableChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.surface3,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10),
            child: Icon(Icons.close,
                size: 14, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
