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

class AdminRoleManagementPage extends StatefulWidget {
  const AdminRoleManagementPage({super.key});

  @override
  State<AdminRoleManagementPage> createState() => _AdminRoleManagementPageState();
}

class _AdminRoleManagementPageState extends State<AdminRoleManagementPage> {
  String? _selectedRoleId;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<AdminBloc>().add(AdminLoadRoles());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      appBar: const AdminAppBar(title: 'Role Management'),
      drawer: isDesktop ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isDesktop) const AdminSidebar(),
          const VerticalDivider(width: 1),
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is AdminLoading) {
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

                final roles = state is AdminRolesLoaded ? state.roles : <AdminRoleEntity>[];
                final selectedRole = roles.firstWhere((r) => r.id == _selectedRoleId, orElse: () => roles.isEmpty ? const AdminRoleEntity(id: '', name: '') : roles.first);
                
                if (roles.isEmpty && state is AdminRolesLoaded) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.admin_panel_settings_outlined, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        const Text('No roles found'),
                        const SizedBox(height: 16),
                        FilledButton(onPressed: () => _addRole(theme), child: const Text('Create First Role')),
                      ],
                    ),
                  );
                }

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
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildRoleList(theme, roles)),
                            const SizedBox(width: 24),
                            Expanded(flex: 3, child: _buildEditPanel(theme, selectedRole)),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRoleList(theme, roles),
                            const SizedBox(height: 24),
                            _buildEditPanel(theme, selectedRole),
                          ],
                        ),
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

  Widget _buildRoleList(ThemeData theme, List<AdminRoleEntity> roles) {
    return Column(
      children: roles.map((role) {
        final isSelected = _selectedRoleId == role.id || (_selectedRoleId == null && roles.indexOf(role) == 0);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.2)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _selectedRoleId = role.id),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.admin_panel_settings, color: theme.colorScheme.onPrimaryContainer),
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

  Widget _buildEditPanel(ThemeData theme, AdminRoleEntity role) {
    if (role.id.isEmpty) return const SizedBox();
    
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
              if (!role.isProtected)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  onPressed: () => _deleteRole(role),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Permissions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
          const SizedBox(height: 12),
          ...role.permissions.entries.map((entry) => _permissionCategory(theme, entry.key, entry.value, role)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: role.isProtected ? null : () {
                    // Logic to collect all checked permissions and dispatch update
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permissions updated')));
                  },
                  child: const Text('Save Permissions'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _permissionCategory(ThemeData theme, String category, List<String> permissions, AdminRoleEntity role) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_formatKey(category), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
          const SizedBox(height: 6),
          ...permissions.map((perm) => CheckboxListTile(
            title: Text(perm, style: const TextStyle(fontSize: 13)),
            value: true,
            onChanged: role.isProtected ? null : (_) {},
            dense: true,
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            controlAffinity: ListTileControlAffinity.leading,
          )),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    final result = key.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}');
    return result[0].toUpperCase() + result.substring(1);
  }

  void _addRole(ThemeData theme) {
    _nameController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Role'),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Role Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                context.read<AdminBloc>().add(AdminCreateRole(name: _nameController.text, permissions: {}));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _deleteRole(AdminRoleEntity role) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text('Are you sure you want to delete the "${role.name}" role? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<AdminBloc>().add(AdminDeleteRole(role.id));
              Navigator.pop(ctx);
              setState(() => _selectedRoleId = null);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: [
        DrawerHeader(decoration: BoxDecoration(color: theme.colorScheme.primary), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
          const Icon(Icons.admin_panel_settings, color: Colors.white, size: 40), const SizedBox(height: 8),
          const Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
