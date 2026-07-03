import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/main_shell.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/last_updated_chip.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/profile_provider.dart';
import '../../domain/profile_models.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _formatValue(dynamic value) {
    if (value == null) return '';
    final s = value.toString().trim();
    if (s.isEmpty || s == 'null') return '';
    return s;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatGender(dynamic val) {
    if (val == null) return '';
    final s = val.toString().trim();
    if (s.isEmpty || s == 'null') return '';
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(isDarkModeProvider);
    final profileAsync = ref.watch(profileNotifierProvider);
    final notifier = ref.read(profileNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(RouteNames.editProfile),
          ),
          if (notifier.lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: LastUpdatedChip(lastUpdated: notifier.lastUpdated!),
            ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const _ProfileShimmerLoading(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (profile) {
          return RefreshIndicator(
            onRefresh: () => notifier.refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Premium Vendor Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.4),
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: AppColors.surface2,
                              backgroundImage: profile.avatarUrl != null
                                  ? NetworkImage(profile.avatarUrl!)
                                  : null,
                              child: profile.avatarUrl == null
                                  ? Text(
                                      (profile.name?.isNotEmpty ?? false)
                                          ? profile.name![0].toUpperCase()
                                          : 'V',
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: profile.status == 'active'
                                    ? AppColors.success
                                    : AppColors.error,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.surface,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                (profile.status ?? 'unknown').toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.name ?? 'No Name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGlow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (profile.role ?? 'VENDOR').toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.push(RouteNames.editProfile),
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label: const Text('Edit Profile', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Contact Card
                _ProfileCard(
                  title: 'Contact Information',
                  children: [
                    _ProfileDetailRow(
                      label: 'Email',
                      value: _formatValue(profile.email),
                      icon: Icons.email_outlined,
                      isVerified: profile.isEmailVerified,
                    ),
                    const Divider(height: 1, thickness: 0.5),
                    _ProfileDetailRow(
                      label: 'Phone',
                      value: _formatValue(profile.phone),
                      icon: Icons.phone_outlined,
                      isVerified: profile.isPhoneVerified,
                    ),
                    const Divider(height: 1, thickness: 0.5),
                    _ProfileDetailRow(
                      label: 'Alternate Phone',
                      value: _formatValue(profile.alternatePhone),
                      icon: Icons.phone_android_outlined,
                    ),
                  ],
                ),

                // Location Card
                _ProfileCard(
                  title: 'Address & Location',
                  children: [
                    _ProfileDetailRow(
                      label: 'City',
                      value: _formatValue(profile.city),
                      icon: Icons.location_city_outlined,
                    ),
                    const Divider(height: 1, thickness: 0.5),
                    _ProfileDetailRow(
                      label: 'State',
                      value: _formatValue(profile.state),
                      icon: Icons.map_outlined,
                    ),
                    const Divider(height: 1, thickness: 0.5),
                    _ProfileDetailRow(
                      label: 'Pincode',
                      value: _formatValue(profile.pincode),
                      icon: Icons.pin_drop_outlined,
                    ),
                  ],
                ),

                // Personal Details Card
                _ProfileCard(
                  title: 'Personal Details',
                  children: [
                    _ProfileDetailRow(
                      label: 'Gender',
                      value: _formatGender(profile.gender),
                      icon: Icons.person_outline,
                    ),
                    const Divider(height: 1, thickness: 0.5),
                    _ProfileDetailRow(
                      label: 'Date of Birth',
                      value: _formatValue(profile.dateOfBirth),
                      icon: Icons.cake_outlined,
                    ),
                  ],
                ),

                // Account/System Details Card
                _ProfileCard(
                  title: 'Account Details',
                  children: [
                    _ProfileDetailRow(
                      label: 'Joined Date',
                      value: _formatDate(profile.createdAt),
                      icon: Icons.calendar_today_outlined,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Logout Action
                _ProfileSessionCard(
                  onLogout: () async {
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (context.mounted) context.go(RouteNames.login);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Helper Widgets
class _ProfileCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool? isVerified;

  const _ProfileDetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value.isEmpty ? 'Not specified' : value;
    final isNotSpecified = value.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayValue,
                  style: TextStyle(
                    color: isNotSpecified
                        ? AppColors.textDim
                        : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: isNotSpecified
                        ? FontWeight.normal
                        : FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isVerified != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isVerified! ? AppColors.successBg : AppColors.warningBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isVerified! ? Icons.check_circle : Icons.cancel,
                    size: 12,
                    color: isVerified! ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isVerified! ? 'Verified' : 'Unverified',
                    style: TextStyle(
                      fontSize: 10,
                      color: isVerified!
                          ? AppColors.success
                          : AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileSessionCard extends StatelessWidget {
  final VoidCallback onLogout;

  const _ProfileSessionCard({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Log out from your vendor account',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _ProfileShimmerLoading extends StatelessWidget {
  const _ProfileShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Header Shimmer
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              const SizedBox(
                width: 92,
                height: 92,
                child: _DynamicShimmer(shape: BoxShape.circle),
              ),
              const SizedBox(height: 16),
              const Center(
                child: _DynamicShimmer(height: 20, width: 140, borderRadius: 6),
              ),
              const SizedBox(height: 8),
              const Center(
                child: _DynamicShimmer(height: 16, width: 80, borderRadius: 6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Info Cards Shimmers
        for (int i = 0; i < 4; i++) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DynamicShimmer(height: 12, width: 120, borderRadius: 4),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const _DynamicShimmer(height: 32, width: 32, borderRadius: 8),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _DynamicShimmer(height: 10, width: 60, borderRadius: 4),
                          SizedBox(height: 6),
                          _DynamicShimmer(height: 14, width: 150, borderRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const _DynamicShimmer(height: 32, width: 32, borderRadius: 8),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _DynamicShimmer(height: 10, width: 40, borderRadius: 4),
                          SizedBox(height: 6),
                          _DynamicShimmer(height: 14, width: 120, borderRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _DynamicShimmer extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;
  final BoxShape shape;

  const _DynamicShimmer({
    this.height = 80,
    this.width,
    this.borderRadius = 12,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[850]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: shape == BoxShape.circle ? null : height,
        width: shape == BoxShape.circle ? null : (width ?? double.infinity),
        decoration: BoxDecoration(
          color: baseColor,
          shape: shape,
          borderRadius: shape == BoxShape.circle
              ? null
              : BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
