import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_sidebar.dart';

class AdminPenaltiesPage extends StatefulWidget {
  const AdminPenaltiesPage({super.key});

  @override
  State<AdminPenaltiesPage> createState() => _AdminPenaltiesPageState();
}

class _AdminPenaltiesPageState extends State<AdminPenaltiesPage> {
  final _searchController = TextEditingController();
  bool _isLoading = true;

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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 720;

    return Scaffold(
      appBar: AdminAppBar(title: 'Penalties & Enforcement'),
      drawer: isWide ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isWide) const AdminSidebar(),
          const VerticalDivider(width: 1),
          Expanded(child: _buildContent(theme)),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildStatsRow(theme),
        const Divider(height: 1),
        _buildSearchBar(theme),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _mockPenalties.length,
            itemBuilder: (_, i) => _buildPenaltyCard(theme, _mockPenalties[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _statCard(theme, 'Active Bans', '3', Colors.red),
          const SizedBox(width: 16),
          _statCard(theme, 'Suspended', '12', Colors.orange),
          const SizedBox(width: 16),
          _statCard(theme, 'Warnings', '47', Colors.amber),
          const SizedBox(width: 16),
          _statCard(theme, 'Appeals Pending', '5', Colors.blue),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            ),
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
          SizedBox(
            width: 320,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search penalties by user, reason...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
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

  Widget _buildPenaltyCard(ThemeData theme, _MockPenalty penalty) {
    final severityColor = penalty.severity == 'High' ? Colors.red : penalty.severity == 'Medium' ? Colors.orange : Colors.grey;

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
                  child: Text(penalty.severity, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: severityColor)),
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
                    if (v == 'appeal') _showAppealDetail(context, penalty);
                    if (v == 'restore') _showConfirm(context, 'restore ${penalty.user}\'s account');
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'appeal', child: Text('View Appeal')),
                    const PopupMenuItem(value: 'restore', child: Text('Restore Account')),
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
                  child: Text(penalty.initials, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
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
                  onPressed: () => _showConfirm(context, 'overturn this penalty'),
                  icon: const Icon(Icons.gavel, size: 14),
                  label: const Text('Overturn', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            if (penalty.strikes >= 3)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 16, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Text('3-strike rule triggered - permanent ban recommended', style: TextStyle(fontSize: 12, color: Colors.red.shade700, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
          ],
        ),
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
            Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
            const SizedBox(height: 8),
            Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ])),
          _drawerItem(Icons.dashboard, 'Dashboard', () { Navigator.pop(context); context.go('/admin'); }),
          _drawerItem(Icons.people, 'Users', () { Navigator.pop(context); context.go('/admin/users'); }),
          _drawerItem(Icons.flag, 'Moderation', () { Navigator.pop(context); context.go('/admin/moderation'); }),
          _drawerItem(Icons.gavel, 'Penalties', () { Navigator.pop(context); context.go('/admin/penalties'); }),
          _drawerItem(Icons.analytics, 'Analytics', () { Navigator.pop(context); context.go('/admin/analytics'); }),
          _drawerItem(Icons.settings, 'Config', () { Navigator.pop(context); context.go('/admin/config'); }),
          _drawerItem(Icons.category, 'Categories', () { Navigator.pop(context); context.go('/admin/categories'); }),
          _drawerItem(Icons.campaign, 'Broadcast', () { Navigator.pop(context); context.go('/admin/broadcast'); }),
          _drawerItem(Icons.record_voice_over, 'Audit Log', () { Navigator.pop(context); context.go('/admin/audit'); }),
          _drawerItem(Icons.admin_panel_settings, 'Roles', () { Navigator.pop(context); context.go('/admin/roles'); }),
          _drawerItem(Icons.storage, 'Database', () { Navigator.pop(context); context.go('/admin/database'); }),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
  }

  void _showConfirm(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Action'),
        content: Text('Are you sure you want to $action? This will be logged in the audit trail.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () { Navigator.pop(ctx); }, child: const Text('Confirm')),
        ],
      ),
    );
  }

  void _showApplyPenalty(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apply Penalty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'User', hintText: 'Search and select user',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: 'Warning',
              decoration: InputDecoration(labelText: 'Penalty Type', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true),
              items: ['Warning', 'Suspension', 'Ban', 'Trust Score Adjustment'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () { Navigator.pop(ctx); }, child: const Text('Apply')),
        ],
      ),
    );
  }

  void _showAppealDetail(BuildContext context, _MockPenalty penalty) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Text('Appeal Details', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _detailRow('User', penalty.user),
              _detailRow('Penalty', penalty.type),
              _detailRow('Status', 'Under Review'),
              _detailRow('Submitted', '2 days ago'),
              const SizedBox(height: 16),
              Text('Appeal Message:', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('I apologize for my actions. I understand I violated the community guidelines and assure this will not happen again. Please consider reducing the suspension duration.'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Reject'))),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton(onPressed: () { Navigator.pop(ctx); }, child: const Text('Approve'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w500)), Text(value)]),
    );
  }
}

class _MockPenalty {
  final String severity, type, user, reason, date, duration, initials;
  final int strikes;
  _MockPenalty({required this.severity, required this.type, required this.user, required this.reason, required this.date, required this.duration, required this.initials, required this.strikes});
}

final _mockPenalties = [
  _MockPenalty(severity: 'High', type: 'Permanent Ban', user: 'Nomsa Khumalo', reason: 'Repeated harassment', date: '2 days ago', duration: 'Permanent', initials: 'NK', strikes: 3),
  _MockPenalty(severity: 'High', type: 'Suspension', user: 'Busi Dlamini', reason: 'False skill claims', date: '5 days ago', duration: '14 days remaining', initials: 'BD', strikes: 2),
  _MockPenalty(severity: 'Medium', type: 'Warning', user: 'Sipho Zulu', reason: 'Inappropriate language', date: '1 week ago', duration: 'N/A', initials: 'SZ', strikes: 1),
  _MockPenalty(severity: 'Medium', type: 'Trust Score Reduction', user: 'Lindiwe Mokoena', reason: 'No-show on session', date: '2 weeks ago', duration: '-15 points', initials: 'LM', strikes: 1),
  _MockPenalty(severity: 'Low', type: 'Content Removal', user: 'Themba Mthembu', reason: 'Spam listing', date: '3 weeks ago', duration: 'Listing removed', initials: 'TM', strikes: 0),
];
