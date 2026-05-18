import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/route_names.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    (path: RouteNames.dashboard, label: 'Dashboard', icon: Icons.dashboard_outlined),
    (path: RouteNames.products, label: 'Products', icon: Icons.inventory_2_outlined),
    (path: RouteNames.orders, label: 'Orders', icon: Icons.shopping_bag_outlined),
    (path: RouteNames.shop, label: 'Shop', icon: Icons.store_outlined),
    (path: RouteNames.profile, label: 'Profile', icon: Icons.person_outline),
  ];

  int _currentIndex(String location) {
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _currentIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}
