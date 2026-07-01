import 'package:flutter/material.dart';
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
    (path: RouteNames.dashboard, label: 'Dashboard', icon: Icons.dashboard_outlined),
    (path: RouteNames.products, label: 'Products', icon: Icons.inventory_2_outlined),
    (path: RouteNames.shop, label: 'Shop', icon: Icons.store_outlined),
    (path: RouteNames.notifications, label: 'Alerts', icon: Icons.notifications_outlined),
    (path: RouteNames.profile, label: 'Profile', icon: Icons.person_outline),
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
      drawer: const AppDrawer(),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: _tabs.asMap().entries.map((e) =>
            _NavItem(
              icon: e.value.icon,
              label: e.value.label,
              selected: currentIndex == e.key,
              onTap: () => context.go(_tabs[e.key].path),
              selectedColor: colorScheme.primary,
              badgeCount: e.value.path == RouteNames.notifications ? unreadCount : 0,
            ),
          ).toList(),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : Theme.of(context).colorScheme.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                isLabelVisible: badgeCount > 0,
                label: Text(badgeCount > 99 ? '99+' : '$badgeCount'),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: color),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
