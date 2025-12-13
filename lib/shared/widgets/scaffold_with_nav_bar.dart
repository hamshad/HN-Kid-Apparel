import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          height: 65,
          backgroundColor: Theme.of(context).colorScheme.surface,
          indicatorColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => _onTap(context, index),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          animationDuration: const Duration(milliseconds: 500),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.home, color: Theme.of(context).colorScheme.primary),
              label: 'Home',
            ),
            NavigationDestination(
               icon: Icon(Icons.grid_view_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
               selectedIcon: Icon(Icons.grid_view, color: Theme.of(context).colorScheme.primary),
               label: 'Catalog',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.history, color: Theme.of(context).colorScheme.primary),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.admin_panel_settings, color: Theme.of(context).colorScheme.primary),
              label: 'Admin',
            ),
          ],
        ),
      ),
    );
  }
}
