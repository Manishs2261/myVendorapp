import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../shared/widgets/offline_banner.dart';
import '../router/route_names.dart';
import '../theme/theme_provider.dart';
import 'app_drawer.dart';

class MainShell extends ConsumerWidget {
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    (
      path: RouteNames.dashboard,
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    (
      path: RouteNames.products,
      label: 'Products',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
    ),
    (
      path: RouteNames.shop,
      label: 'Shop',
      icon: Icons.store_outlined,
      activeIcon: Icons.store,
    ),
    (
      path: RouteNames.notifications,
      label: 'Alerts',
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
    ),
  ];

  int _currentIndex(String location) {
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(isDarkModeProvider);
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _currentIndex(location);
    final colorScheme = Theme.of(context).colorScheme;
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      key: MainShell.scaffoldKey,
      extendBody: true,
      drawer: const AppDrawer(),
      onDrawerChanged: (isOpened) {
        if (isOpened) ref.read(drawerOpenedProvider.notifier).state = true;
      },
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.03),
                      blurRadius: 24,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _tabs.asMap().entries.map((e) =>
                    _NavItem(
                      icon: e.value.icon,
                      activeIcon: e.value.activeIcon,
                      label: e.value.label,
                      selected: currentIndex == e.key,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.go(_tabs[e.key].path);
                      },
                      selectedColor: colorScheme.primary,
                      badgeCount: e.value.path == RouteNames.notifications ? unreadCount : 0,
                    ),
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                isLabelVisible: badgeCount > 0,
                label: Text(badgeCount > 99 ? '99+' : '$badgeCount'),
                child: AnimatedScale(
                  scale: selected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    selected ? activeIcon : icon,
                    color: selected ? selectedColor : colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: selectedColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
