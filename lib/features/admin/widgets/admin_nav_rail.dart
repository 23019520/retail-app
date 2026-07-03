import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';

/// Responsive admin navigation.
/// Wide screens (≥ 720px) → NavigationRail on the left.
/// Narrow screens        → BottomNavigationBar.
class AdminShellScaffold extends StatelessWidget {
  const AdminShellScaffold({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    _NavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
      route: RouteConstants.adminDashboard,
    ),
    _NavItem(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
      label: 'Products',
      route: RouteConstants.adminProducts,
    ),
    _NavItem(
      icon: Icons.category_outlined,
      activeIcon: Icons.category_rounded,
      label: 'Categories',
      route: RouteConstants.adminCategories,
    ),
    _NavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Orders',
      route: RouteConstants.adminOrders,
    ),
    _NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
      route: RouteConstants.adminSettings,
    ),
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(RouteConstants.adminProducts)) return 1;
    if (location.startsWith(RouteConstants.adminCategories)) return 2;
    if (location.startsWith(RouteConstants.adminOrders)) return 3;
    if (location == RouteConstants.adminSettings) return 4;
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    context.go(_destinations[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 720;
    final selectedIndex = _selectedIndex(context);
    final colors = Theme.of(context).colorScheme;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) =>
                  _onDestinationSelected(context, i),
              labelType: NavigationRailLabelType.all,
              backgroundColor: colors.surface,
              indicatorColor: colors.primaryContainer,
              selectedIconTheme: IconThemeData(color: colors.primary),
              unselectedIconTheme: IconThemeData(
                  color: colors.onSurface.withValues(alpha: 0.5)),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.shopping_bag_outlined,
                      color: colors.onPrimary, size: 22),
                ),
              ),
              destinations: _destinations
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.activeIcon),
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            VerticalDivider(
                width: 1,
                color: colors.outline.withValues(alpha: 0.15)),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) =>
            _onDestinationSelected(context, i),
        destinations: _destinations
            .map((d) => NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.activeIcon),
                  label: d.label,
                ))
            .toList(),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}
