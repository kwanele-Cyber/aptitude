import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:myapp/features/admin/presentation/bloc/admin_event.dart';
import 'package:myapp/features/admin/presentation/bloc/admin_state.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_sidebar.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_stat_card.dart';
import 'package:myapp/core/utils/responsive_utils.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_event.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(AdminLoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      appBar: const AdminAppBar(),
      drawer: isDesktop ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isDesktop) const AdminSidebar(),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is AdminDashboardLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AdminError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => context.read<AdminBloc>().add(AdminLoadDashboard()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                final data = state is AdminDashboardLoaded ? state : null;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, Admin',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Here\'s what\'s happening on your platform',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildKpiRow(theme, data),
                      const SizedBox(height: 32),
                      Text(
                        'Quick Actions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActions(theme),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow(ThemeData theme, AdminDashboardLoaded? data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 48) / 4;
        return Row(
          children: [
            SizedBox(
              width: cardWidth,
              child: AdminStatCard(
                icon: Icons.people,
                label: 'Total Users',
                value: _fmt(data?.totalUsers),
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: cardWidth,
              child: AdminStatCard(
                icon: Icons.handshake,
                label: 'Active Matches',
                value: _fmt(data?.activeMatches),
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: cardWidth,
              child: AdminStatCard(
                icon: Icons.event,
                label: 'Sessions/Week',
                value: _fmt(data?.sessionsThisWeek),
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: cardWidth,
              child: AdminStatCard(
                icon: Icons.star,
                label: 'Avg Rating',
                value: data != null ? data.averageRating.toStringAsFixed(1) : '—',
                color: Colors.purple,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    final actions = [
      _ActionTile(Icons.people, 'User Management', () => context.go('/admin/users')),
      _ActionTile(Icons.flag, 'Content Moderation', () => context.go('/admin/moderation')),
      _ActionTile(Icons.analytics, 'Analytics', () => context.go('/admin/analytics')),
      _ActionTile(Icons.settings, 'System Config', () => context.go('/admin/config')),
      _ActionTile(Icons.campaign, 'Broadcast', () => context.go('/admin/broadcast')),
      _ActionTile(Icons.record_voice_over, 'Audit Log', () => context.go('/admin/audit')),
      if (kDebugMode)
        _ActionTile(Icons.science, 'Seed Data', () => context.go('/admin/seed')),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtils.gridColumns(context, desktop: 3),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final a = actions[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: InkWell(
            onTap: a.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(a.icon, color: theme.colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    a.label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
                const SizedBox(height: 8),
                Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _drawerItem(Icons.dashboard, 'Dashboard', () { Navigator.pop(context); }),
          _drawerItem(Icons.people, 'Users', () { Navigator.pop(context); context.go('/admin/users'); }),
          _drawerItem(Icons.flag, 'Moderation', () { Navigator.pop(context); context.go('/admin/moderation'); }),
          _drawerItem(Icons.gavel, 'Penalties', () { Navigator.pop(context); context.go('/admin/penalties'); }),
          _drawerItem(Icons.analytics, 'Analytics', () { Navigator.pop(context); context.go('/admin/analytics'); }),
          _drawerItem(Icons.settings, 'Config', () { Navigator.pop(context); context.go('/admin/config'); }),
          _drawerItem(Icons.campaign, 'Broadcast', () { Navigator.pop(context); context.go('/admin/broadcast'); }),
          _drawerItem(Icons.record_voice_over, 'Audit Log', () { Navigator.pop(context); context.go('/admin/audit'); }),
          const Divider(),
          _drawerItem(Icons.logout, 'Sign Out', () { Navigator.pop(context); context.read<AuthBloc>().add(AuthLogoutRequested()); }),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }

  String _fmt(int? value) => value != null ? value.toString() : '—';
}

class _ActionTile {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile(this.icon, this.label, this.onTap);
}
