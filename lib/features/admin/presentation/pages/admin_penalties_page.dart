import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/utils/responsive_utils.dart';
import 'package:myapp/features/admin/domain/entities/admin_entities.dart';
import 'package:myapp/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:myapp/features/admin/presentation/bloc/admin_event.dart';
import 'package:myapp/features/admin/presentation/bloc/admin_state.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_sidebar.dart';

class AdminPenaltiesPage extends StatefulWidget {
  const AdminPenaltiesPage({super.key});

  @override
  State<AdminPenaltiesPage> createState() => _AdminPenaltiesPageState();
}

class _AdminPenaltiesPageState extends State<AdminPenaltiesPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<AdminBloc>().add(AdminLoadPenalties(query: _searchController.text));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      appBar: const AdminAppBar(title: 'Penalties & Enforcement'),
      drawer: isDesktop ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isDesktop) const AdminSidebar(),
          const VerticalDivider(width: 1),
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                return Column(
                  children: [
                    _buildStatsRow(theme, state),
                    const Divider(height: 1),
                    _buildSearchBar(theme),
                    const Divider(height: 1),
                    Expanded(child: _buildMainContent(theme, state)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme, AdminState state) {
    if (state is AdminPenaltiesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AdminError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    final penalties = state is AdminPenaltiesLoaded ? state.penalties : <PenaltyEntity>[];
    if (penalties.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.gavel_outlined, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text('No active penalties found'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: penalties.length,
      itemBuilder: (_, i) => _buildPenaltyCard(theme, penalties[i]),
    );
  }

  Widget _buildStatsRow(ThemeData theme, AdminState state) {
    final penalties = state is AdminPenaltiesLoaded ? state.penalties : <PenaltyEntity>[];
    final bansCount = penalties.where((p) => p.type.toLowerCase().contains('ban')).length;
    final suspensionsCount = penalties.where((p) => p.type.toLowerCase().contains('suspension')).length;
    final warningsCount = penalties.where((p) => p.type.toLowerCase().contains('warning')).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _statCard(theme, 'Active Bans', '$bansCount', Colors.red),
          const SizedBox(width: 16),
          _statCard(theme, 'Suspended', '$suspensionsCount', Colors.orange),
          const SizedBox(width: 16),
          _statCard(theme, 'Warnings', '$warningsCount', Colors.amber),
        ],
      ),
    );
  }

  Widget _statCard(ThemeData theme, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search penalties by user, reason...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  isDense: true,
                ),
                onChanged: (_) => _loadData(),
              ),
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => _showApplyPenalty(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Apply Penalty'),
          ),
        ],
      ),
    );
  }

  Widget _buildPenaltyCard(ThemeData theme, PenaltyEntity penalty) {
    final severityColor = penalty.severity.toLowerCase() == 'high' ? Colors.red : penalty.severity.toLowerCase() == 'medium' ? Colors.orange : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: severityColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text(penalty.severity.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: severityColor)),
                ),
                const SizedBox(width: 12),
                Text(penalty.type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const Spacer(),
                Text(penalty.date, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  offset: const Offset(0, 32),
                  onSelected: (v) {
                    if (v == 'overturn') _showConfirmOverturn(penalty);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'overturn', child: Text('Overturn Penalty')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(penalty.user.substring(0, 1), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
                ),
                const SizedBox(width: 8),
                Text(penalty.user, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                const SizedBox(width: 16),
                Icon(Icons.info_outline, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                const SizedBox(width: 4),
                Text(penalty.reason, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Strikes: ${penalty.strikes}/3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: penalty.strikes >= 3 ? Colors.red : Colors.orange)),
                const SizedBox(width: 16),
                Text('Duration: ${penalty.duration}', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showConfirmOverturn(penalty),
                  icon: const Icon(Icons.gavel, size: 14),
                  label: const Text('Overturn', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmOverturn(PenaltyEntity penalty) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Overturn Penalty'),
        content: Text('Are you sure you want to overturn the penalty for ${penalty.user}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              context.read<AdminBloc>().add(AdminOverturnPenalty(penalty.id));
              Navigator.pop(ctx);
            },
            child: const Text('Overturn'),
          ),
        ],
      ),
    );
  }

  void _showApplyPenalty(BuildContext context) {
    final userIdController = TextEditingController();
    final reasonController = TextEditingController();
    String type = 'Warning';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apply Penalty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(labelText: 'User ID', hintText: 'Enter user ID'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: type,
              decoration: const InputDecoration(labelText: 'Penalty Type'),
              items: ['Warning', 'Suspension', 'Ban'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => type = v!,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              context.read<AdminBloc>().add(AdminApplyPenalty(
                userId: userIdController.text,
                type: type,
                reason: reasonController.text,
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(decoration: BoxDecoration(color: theme.colorScheme.primary), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
            const Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
            const SizedBox(height: 8),
            const Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ])),
          _drawerItem(Icons.dashboard, 'Dashboard', () { Navigator.pop(context); context.go('/admin'); }),
          _drawerItem(Icons.people, 'Users', () { Navigator.pop(context); context.go('/admin/users'); }),
          _drawerItem(Icons.flag, 'Moderation', () { Navigator.pop(context); context.go('/admin/moderation'); }),
          _drawerItem(Icons.gavel, 'Penalties', () { Navigator.pop(context); context.go('/admin/penalties'); }),
          _drawerItem(Icons.analytics, 'Analytics', () { Navigator.pop(context); context.go('/admin/analytics'); }),
          _drawerItem(Icons.settings, 'Config', () { Navigator.pop(context); context.go('/admin/config'); }),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
  }
}
