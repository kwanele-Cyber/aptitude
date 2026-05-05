import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/utils/responsive_utils.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_sidebar.dart';

class AdminDatabasePage extends StatefulWidget {
  const AdminDatabasePage({super.key});

  @override
  State<AdminDatabasePage> createState() => _AdminDatabasePageState();
}

class _AdminDatabasePageState extends State<AdminDatabasePage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      appBar: AdminAppBar(title: 'Database Admin'),
      drawer: isDesktop ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isDesktop) const AdminSidebar(),
          const VerticalDivider(width: 1),
          Expanded(child: _buildContent(theme)),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCards(theme),
          const SizedBox(height: 24),
          _buildSection(theme, 'Collections', _buildCollections(theme)),
          const SizedBox(height: 24),
          _buildSection(theme, 'Admin Management', _buildAdminTools(theme)),
          const SizedBox(height: 24),
          _buildSection(theme, 'Backup & Maintenance', _buildBackupTools(theme)),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(ThemeData theme) {
    final cards = [
      _DbStat('Total Documents', '24,582', Icons.description, Colors.blue),
      _DbStat('Collections', '14', Icons.collections_bookmark, Colors.green),
      _DbStat('Storage Used', '2.4 GB', Icons.storage, Colors.orange),
      _DbStat('Last Backup', 'Today 06:45', Icons.backup, Colors.purple),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cards.map((c) => SizedBox(
        width: ResponsiveUtils.isMobile(context) ? double.infinity : (ResponsiveUtils.isTablet(context) ? 200 : null),
        child: _dbStatCard(theme, c),
      )).toList(),
    );
  }

  Widget _dbStatCard(ThemeData theme, _DbStat c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: c.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(c.icon, color: c.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
                Text(c.label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, Widget content) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Padding(padding: const EdgeInsets.all(20), child: content),
        ],
      ),
    );
  }

  Widget _buildCollections(ThemeData theme) {
    final collections = [
      _CollData('users', '8,450', '1.2 GB', 'Online'),
      _CollData('skills', '5,230', '340 MB', 'Online'),
      _CollData('matches', '3,890', '280 MB', 'Online'),
      _CollData('sessions', '2,150', '190 MB', 'Online'),
      _CollData('agreements', '1,240', '95 MB', 'Online'),
      _CollData('reviews', '3,622', '160 MB', 'Online'),
      _CollData('audit_logs', '12,847', '320 MB', 'Online'),
    ];

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              const Expanded(flex: 2, child: Text('Collection', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              const Expanded(child: Text('Documents', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              const Expanded(child: Text('Size', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              const Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              const SizedBox(width: 100),
            ],
          ),
        ),
        ...collections.map((c) => Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)))),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
              Expanded(child: Text(c.documents, style: const TextStyle(fontSize: 13))),
              Expanded(child: Text(c.size, style: const TextStyle(fontSize: 13))),
              Expanded(child: _statusBadge(c.status)),
              SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.visibility_outlined, size: 16), onPressed: () {}, padding: EdgeInsets.zero),
                    IconButton(icon: const Icon(Icons.download_outlined, size: 16), onPressed: () {}, padding: EdgeInsets.zero),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _statusBadge(String status) {
    final color = status == 'Online' ? Colors.green : Colors.grey;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildAdminTools(ThemeData theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _toolCard(theme, Icons.admin_panel_settings, 'Emergency Admin', 'Designate successor admin via multi-step verification'),
        _toolCard(theme, Icons.visibility, 'Read-Only Access', 'Grant analytics team read-only DB access'),
        _toolCard(theme, Icons.timer, 'Temporary Grant', 'Time-bound admin access for specific tasks'),
        _toolCard(theme, Icons.vpn_key, 'Recovery Keys', 'Manage offline recovery key storage and rotation'),
      ],
    );
  }

  Widget _toolCard(ThemeData theme, IconData icon, String title, String desc) {
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showDialog(context, title),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, size: 20, color: theme.colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(desc, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackupTools(ThemeData theme) {
    return Column(
      children: [
        if (ResponsiveUtils.isMobile(context))
          Column(
            children: [
              _backupBtn(theme, Icons.backup, 'Create Backup'),
              const SizedBox(height: 8),
              _backupBtn(theme, Icons.restore, 'Restore from Backup'),
              const SizedBox(height: 8),
              _backupBtn(theme, Icons.auto_fix_high, 'Run Maintenance'),
            ],
          )
        else
          Row(
            children: [
              Expanded(child: _backupBtn(theme, Icons.backup, 'Create Backup')),
              const SizedBox(width: 12),
              Expanded(child: _backupBtn(theme, Icons.restore, 'Restore from Backup')),
              const SizedBox(width: 12),
              Expanded(child: _backupBtn(theme, Icons.auto_fix_high, 'Run Maintenance')),
            ],
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text('Last maintenance: 7 days ago | Next scheduled: Tomorrow 03:00 AM', style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _backupBtn(ThemeData theme, IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
    );
  }

  void _showDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text('This feature requires authentication and authorization confirmation. Contact the system administrator for access.'),
        actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: [
        DrawerHeader(decoration: BoxDecoration(color: theme.colorScheme.primary), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
          Icon(Icons.admin_panel_settings, color: Colors.white, size: 40), const SizedBox(height: 8),
          Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ])),
        _drw(Icons.dashboard, 'Dashboard', '/admin'), _drw(Icons.people, 'Users', '/admin/users'),
        _drw(Icons.flag, 'Moderation', '/admin/moderation'), _drw(Icons.gavel, 'Penalties', '/admin/penalties'),
        _drw(Icons.analytics, 'Analytics', '/admin/analytics'), _drw(Icons.settings, 'Config', '/admin/config'),
      ]),
    );
  }

  Widget _drw(IconData icon, String label, String route) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: () { Navigator.pop(context); context.go(route); });
  }
}

class _DbStat {
  final String label, value;
  final IconData icon;
  final Color color;
  _DbStat(this.label, this.value, this.icon, this.color);
}

class _CollData {
  final String name, documents, size, status;
  _CollData(this.name, this.documents, this.size, this.status);
}
