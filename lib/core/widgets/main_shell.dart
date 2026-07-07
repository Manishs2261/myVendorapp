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
      bottomNavigationBar: NavigationBar(
         height: 60,
        selectedIndex: currentIndex,

        onDestinationSelected: (index) {
          HapticFeedback.lightImpact();
          context.go(_tabs[index].path);
        },
        destinations: _tabs.map((tab) {
          final isNotifications = tab.path == RouteNames.notifications;
          final showBadge = isNotifications && unreadCount > 0;
          
          return NavigationDestination(
            icon: Badge(
              isLabelVisible: showBadge,
              label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
              child: Icon(tab.icon),
            ),
            selectedIcon: Badge(
              isLabelVisible: showBadge,
              label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
              child: Icon(tab.activeIcon),
            ),
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }
}
