import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/route_names.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    (path: RouteNames.dashboard, label: 'Dashboard', icon: Icons.dashboard_outlined),
    (path: RouteNames.products, label: 'Products', icon: Icons.inventory_2_outlined),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(RouteNames.addProduct),
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          children: [
            ..._tabs.sublist(0, 2).asMap().entries.map((e) =>
              _NavItem(
                icon: e.value.icon,
                label: e.value.label,
                selected: currentIndex == e.key,
                onTap: () => context.go(_tabs[e.key].path),
                selectedColor: colorScheme.primary,
              ),
            ),
            const Spacer(),
            const Spacer(),
            ..._tabs.sublist(2).asMap().entries.map((e) =>
              _NavItem(
                icon: e.value.icon,
                label: e.value.label,
                selected: currentIndex == e.key + 2,
                onTap: () => context.go(_tabs[e.key + 2].path),
                selectedColor: colorScheme.primary,
              ),
            ),
          ],
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

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
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
              Icon(icon, color: color),
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
