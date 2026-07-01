import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/profile/domain/profile_models.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../router/route_names.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(isDarkModeProvider);
    final location = GoRouterState.of(context).matchedLocation;
    final profileAsync = ref.watch(profileNotifierProvider);

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(profileAsync: profileAsync),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  _DrawerSection(title: 'MAIN'),
                  _DrawerItem(label: 'Dashboard',   path: RouteNames.dashboard,  letter: 'D', color: AppColors.primary,       location: location),
                  _DrawerItem(label: 'Products',    path: RouteNames.products,   letter: 'P', color: AppColors.secondary,     location: location),
                  _DrawerItem(label: 'Analytics',   path: RouteNames.analytics,  letter: 'A', color: AppColors.tertiary,      location: location),
                  _DrawerItem(label: 'Marketplace', path: RouteNames.marketplace,letter: 'M', color: const Color(0xFF10B981), location: location),
                  _DrawerItem(label: 'Promotions',  path: RouteNames.promotions, letter: 'P', color: AppColors.warning,       location: location),
                  _DrawerItem(label: 'Sponsorship', path: RouteNames.sponsorship,letter: 'S', color: const Color(0xFFF97316), location: location),
                  const SizedBox(height: 8),
                  _DrawerSection(title: 'FEEDBACK'),
                  _DrawerItem(label: 'Shop Reviews',    path: RouteNames.shopReviews,    letter: 'S', color: const Color(0xFFEC4899), location: location),
                  _DrawerItem(label: 'Product Reviews', path: RouteNames.productReviews, letter: 'P', color: const Color(0xFF8B5CF6), location: location),
                  _DrawerItem(label: 'Help & Feedback', path: RouteNames.helpFeedback,   letter: 'H', color: AppColors.textMuted,    location: location),
                  const SizedBox(height: 8),
                  _DrawerSection(title: 'ACCOUNT'),
                  _DrawerItem(label: 'Shop Profile',     path: RouteNames.shop,            letter: 'S', color: AppColors.primaryDark,   location: location),
                  _DrawerItem(label: 'Storefront Editor',path: RouteNames.storefrontEditor,letter: 'E', color: AppColors.secondaryDark, location: location),
                  _DrawerItem(label: 'Payments',         path: RouteNames.payments,        letter: '\$', color: AppColors.success,       location: location),
                  _DrawerItem(label: 'Notifications',    path: RouteNames.notifications,   letter: 'N', color: AppColors.tertiaryDark,  location: location),
                  _DrawerItem(label: 'Settings',         path: RouteNames.settings,        letter: 'S', color: AppColors.textMuted,     location: location),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final AsyncValue<VendorProfile> profileAsync;

  const _DrawerHeader({required this.profileAsync});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: profileAsync.when(
        loading: () => Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.surface3,
              child: const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Loading...', style: TextStyle(color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
        error: (e, _) => Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.surface3,
              child: Text('V', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Text('Vendor', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
        data: (profile) => Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryGlow,
              backgroundImage: profile.logoUrl != null ? NetworkImage(profile.logoUrl!) : null,
              child: profile.logoUrl == null
                  ? Text(
                      profile.businessName.isNotEmpty ? profile.businessName[0].toUpperCase() : 'V',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.businessName,
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text('View profile', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  final String title;

  const _DrawerSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final String path;
  final String letter;
  final Color color;
  final String location;

  const _DrawerItem({
    required this.label,
    required this.path,
    required this.letter,
    required this.color,
    required this.location,
  });

  bool get _isActive => location == path || location.startsWith('$path/');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: _isActive ? AppColors.primaryGlow : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.of(context).pop();
            if (!_isActive) context.go(path);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: color.withValues(alpha: 0.18),
                  child: Text(
                    letter,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: _isActive ? AppColors.textPrimary : AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: _isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
