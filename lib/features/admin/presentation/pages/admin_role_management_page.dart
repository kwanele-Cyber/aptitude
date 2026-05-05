import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_sidebar.dart';

class AdminRoleManagementPage extends StatefulWidget {
  const AdminRoleManagementPage({super.key});

  @override
  State<AdminRoleManagementPage> createState() => _AdminRoleManagementPageState();
}

class _AdminRoleManagementPageState extends State<AdminRoleManagementPage> {
  bool _isLoading = true;
  int? _editingRoleIndex;

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
    final isWide = MediaQuery.of(context).size.width > 720;

    return Scaffold(
      appBar: AdminAppBar(title: 'Role Management'),
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
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Roles Overview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _addRole(theme),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Role'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildRoleList(theme)),
              const SizedBox(width: 24),
              if (_editingRoleIndex != null)
                Expanded(flex: 3, child: _buildEditPanel(theme, _mockRoles[_editingRoleIndex!])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleList(ThemeData theme) {
    final roleIcons = {
      'Super Admin': Icons.shield,
      'Moderator': Icons.verified_user,
      'Support': Icons.headset_mic,
      'Analyst': Icons.analytics,
    };

    return Column(
      children: _mockRoles.asMap().entries.map((entry) {
        final i = entry.key;
        final role = entry.value;
        final isEditing = _editingRoleIndex == i;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isEditing ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.2)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _editingRoleIndex = isEditing ? null : i),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: (role.name == 'Super Admin' ? Colors.blue : role.name == 'Moderator' ? Colors.green : role.name == 'Support' ? Colors.orange : Colors.purple).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(roleIcons[role.name] ?? Icons.person, color: role.name == 'Super Admin' ? Colors.blue : role.name == 'Moderator' ? Colors.green : role.name == 'Support' ? Colors.orange : Colors.purple),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(role.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text('${role.members} members', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                        const SizedBox(height: 2),
                        Text('Permissions: ${role.permissionCount}/${role.totalPermissions}', style: TextStyle(fontSize: 11, color: theme.colorScheme.primary)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEditPanel(ThemeData theme, _MockRole role) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Editing: ${role.name}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => setState(() => _editingRoleIndex = null),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: role.name,
            decoration: InputDecoration(
              labelText: 'Role Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
            ),
          ),
          const SizedBox(height: 20),
          Text('Permissions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
          const SizedBox(height: 12),
          ...role.permissionCategories.map((cat) => _permissionCategory(theme, cat)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => setState(() => _editingRoleIndex = null), child: const Text('Cancel'))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton(onPressed: () => setState(() => _editingRoleIndex = null), child: const Text('Save Changes'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _permissionCategory(ThemeData theme, _PermissionCategory cat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cat.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
          const SizedBox(height: 6),
          ...cat.permissions.map((perm) => CheckboxListTile(
            title: Text(perm, style: const TextStyle(fontSize: 13)),
            value: true,
            onChanged: (_) {},
            dense: true,
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            controlAffinity: ListTileControlAffinity.leading,
          )),
        ],
      ),
    );
  }

  void _addRole(ThemeData theme) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Role'),
        content: TextField(
          controller: nameCtrl,
          decoration: InputDecoration(
            labelText: 'Role Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () { Navigator.pop(ctx); }, child: const Text('Create')),
        ],
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

class _PermissionCategory {
  final String name;
  final List<String> permissions;
  _PermissionCategory(this.name, this.permissions);
}

class _MockRole {
  final String name;
  final int members, permissionCount, totalPermissions;
  final List<_PermissionCategory> permissionCategories;
  _MockRole({required this.name, required this.members, required this.permissionCount, required this.totalPermissions, required this.permissionCategories});
}

final _mockRoles = [
  _MockRole(name: 'Super Admin', members: 2, permissionCount: 47, totalPermissions: 47, permissionCategories: [
    _PermissionCategory('User Management', ['View users', 'Edit users', 'Suspend users', 'Delete users']),
    _PermissionCategory('Content Moderation', ['View flagged content', 'Dismiss flags', 'Remove content', 'Bulk moderation']),
    _PermissionCategory('Dispute Management', ['View disputes', 'Assign disputes', 'Resolve disputes', 'Close disputes']),
    _PermissionCategory('System Configuration', ['View config', 'Edit config', 'Manage feature flags']),
    _PermissionCategory('Broadcast', ['Compose', 'Send', 'Schedule', 'View history']),
    _PermissionCategory('Analytics', ['View analytics', 'Export data']),
    _PermissionCategory('Audit Log', ['View log', 'Export log']),
  ]),
  _MockRole(name: 'Moderator', members: 5, permissionCount: 32, totalPermissions: 47, permissionCategories: [
    _PermissionCategory('User Management', ['View users', 'Edit users', 'Suspend users']),
    _PermissionCategory('Content Moderation', ['View flagged content', 'Dismiss flags', 'Remove content']),
    _PermissionCategory('Dispute Management', ['View disputes', 'Assign disputes']),
    _PermissionCategory('System Configuration', []),
    _PermissionCategory('Broadcast', ['Compose', 'View history']),
    _PermissionCategory('Analytics', ['View analytics']),
    _PermissionCategory('Audit Log', ['View log']),
  ]),
  _MockRole(name: 'Support', members: 3, permissionCount: 18, totalPermissions: 47, permissionCategories: [
    _PermissionCategory('User Management', ['View users', 'Edit users']),
    _PermissionCategory('Content Moderation', ['View flagged content', 'Dismiss flags']),
    _PermissionCategory('Dispute Management', ['View disputes']),
    _PermissionCategory('System Configuration', []),
    _PermissionCategory('Broadcast', ['View history']),
    _PermissionCategory('Analytics', []),
    _PermissionCategory('Audit Log', []),
  ]),
  _MockRole(name: 'Analyst', members: 2, permissionCount: 10, totalPermissions: 47, permissionCategories: [
    _PermissionCategory('User Management', ['View users']),
    _PermissionCategory('Content Moderation', []),
    _PermissionCategory('Dispute Management', []),
    _PermissionCategory('System Configuration', []),
    _PermissionCategory('Broadcast', ['View history']),
    _PermissionCategory('Analytics', ['View analytics', 'Export data']),
    _PermissionCategory('Audit Log', ['View log', 'Export log']),
  ]),
];
