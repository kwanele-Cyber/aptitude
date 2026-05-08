import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_event.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routerState = GoRouterState.of(context);
    final location = routerState.matchedLocation;

    return NavigationRail(
      selectedIndex: _selectedIndex(location),
      onDestinationSelected: (i) => _onNavigate(context, i),
      labelType: NavigationRailLabelType.all,
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings, color: theme.colorScheme.primary, size: 32),
            const SizedBox(height: 4),
            Text('Admin', style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            )),
          ],
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: Text('Users'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.flag_outlined),
          selectedIcon: Icon(Icons.flag),
          label: Text('Moderation'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.gavel_outlined),
          selectedIcon: Icon(Icons.gavel),
          label: Text('Penalties'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.shield_outlined),
          selectedIcon: Icon(Icons.shield),
          label: Text('Disputes'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: Text('Analytics'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Config'),
        ),
      ],
      trailing: Column(
        children: [
          if (kDebugMode)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: IconButton(
                icon: const Icon(Icons.science_outlined),
                tooltip: 'Seed Data',
                isSelected: _selectedIndex(location) == 7,
                selectedIcon: const Icon(Icons.science),
                onPressed: () => context.go('/admin/seed'),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
          ),
        ],
      ),
    );
  }

  int _selectedIndex(String location) {
    if (location.startsWith('/admin/users')) return 1;
    if (location.startsWith('/admin/moderation')) return 2;
    if (location.startsWith('/admin/penalties')) return 3;
    if (location.startsWith('/admin/disputes')) return 4;
    if (location.startsWith('/admin/analytics')) return 5;
    if (location.startsWith('/admin/config') ||
        location.startsWith('/admin/categories') ||
        location.startsWith('/admin/broadcast') ||
        location.startsWith('/admin/database') ||
        location.startsWith('/admin/roles') ||
        location.startsWith('/admin/audit')) {
      return 6;
    }
    return 0;
  }

  void _onNavigate(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/admin'); break;
      case 1: context.go('/admin/users'); break;
      case 2: context.go('/admin/moderation'); break;
      case 3: context.go('/admin/penalties'); break;
      case 4: context.go('/admin/disputes'); break;
      case 5: context.go('/admin/analytics'); break;
      case 6: context.go('/admin/config'); break;
    }
  }
}
