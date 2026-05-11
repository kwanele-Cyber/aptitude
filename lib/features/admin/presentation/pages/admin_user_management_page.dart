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

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() => _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  final _searchController = TextEditingController();
  String _roleFilter = 'All';
  String _statusFilter = 'All';
  final Set<String> _selectedIds = {};

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
    context.read<AdminBloc>().add(AdminSearchUsers(
      query: _searchController.text,
      role: _roleFilter,
      status: _statusFilter,
    ));
  }

  void _onSearchChanged() {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      appBar: const AdminAppBar(title: 'User Management'),
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
                    _buildSearchAndFilter(theme),
                    const Divider(height: 1),
                    if (_selectedIds.isNotEmpty) _buildBulkActionBar(theme),
                    Expanded(child: _buildMainContent(theme, state)),
                    _buildPagination(theme),
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
    if (state is AdminUsersLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            const Text('Loading user data...'),
          ],
        ),
      );
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

    final users = state is AdminUsersLoaded ? state.users : <AdminUserEntity>[];
    return _buildTable(theme, users);
  }

  Widget _buildSearchAndFilter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name, email, ID...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (_) => _onSearchChanged(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildFilterChip(theme, 'Role', _roleFilter, ['All', 'User', 'Admin', 'Moderator', 'Support'], (v) {
                setState(() => _roleFilter = v);
                _loadData();
              }),
              const SizedBox(width: 8),
              _buildFilterChip(theme, 'Status', _statusFilter, ['All', 'Active', 'Suspended', 'Deleted', 'Banned'], (v) {
                setState(() => _statusFilter = v);
                _loadData();
              }),
              if (_roleFilter != 'All' || _statusFilter != 'All') ...[
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Active Filters',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _roleFilter = 'All';
                      _statusFilter = 'All';
                    });
                    _loadData();
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ThemeData theme, String label, String current, List<String> options, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text('$label: ', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ),
          DropdownButton<String>(
            value: current,
            underline: const SizedBox(),
            padding: EdgeInsets.zero,
            style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
            onChanged: (v) => onChanged(v!),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActionBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Row(
        children: [
          Text('${_selectedIds.length} selected', style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
          const SizedBox(width: 16),
          _bulkButton(theme, Icons.block, 'Suspend', 'suspend'),
          const SizedBox(width: 8),
          _bulkButton(theme, Icons.check_circle_outline, 'Activate', 'activate'),
          const SizedBox(width: 8),
          _bulkButton(theme, Icons.delete_outline, 'Delete', 'delete'),
          const Spacer(),
          TextButton(
            onPressed: () => setState(() => _selectedIds.clear()),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _bulkButton(ThemeData theme, IconData icon, String label, String action) {
    return OutlinedButton.icon(
      onPressed: () => _handleBulkAction(action),
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        textStyle: const TextStyle(fontSize: 13),
      ),
    );
  }

  void _handleBulkAction(String action) {
    context.read<AdminBloc>().add(AdminBulkUserAction(userIds: _selectedIds.toList(), action: action));
    setState(() => _selectedIds.clear());
  }

  Widget _buildTable(ThemeData theme, List<AdminUserEntity> users) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: ResponsiveUtils.isMobile(context) ? 600 : MediaQuery.of(context).size.width - 48,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 32, child: Text('')),
                  Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  Expanded(flex: 2, child: Text('Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  Expanded(child: Text('Role', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  Expanded(child: Text('Joined', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  SizedBox(width: 120, child: Text('')),
                ],
              ),
            ),
            const SizedBox(height: 4),
            ...users.map((user) => _buildUserRow(theme, user)),
            if (users.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text('No users found', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      const Text('Try adjusting your search or filters'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRow(ThemeData theme, AdminUserEntity user) {
    final isSelected = _selectedIds.contains(user.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() {
          if (isSelected) {
            _selectedIds.remove(user.id);
          } else {
            _selectedIds.add(user.id);
          }
        }),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _selectedIds.add(user.id);
                    } else {
                      _selectedIds.remove(user.id);
                    }
                  }),
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(user.initials, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                        Text(user.id.substring(0, 8), style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(flex: 2, child: Text(user.email, style: const TextStyle(fontSize: 13))),
              Expanded(child: _buildRoleBadge(theme, user.role)),
              Expanded(child: _buildStatusBadge(theme, user.status)),
              Expanded(child: Text(user.joined, style: const TextStyle(fontSize: 12))),
              SizedBox(
                width: 120,
                child: Row(
                  children: [
                    _rowAction(theme, Icons.visibility_outlined, 'View', () => _showUserDetail(context, user)),
                    const SizedBox(width: 4),
                    _rowAction(theme, Icons.edit_outlined, 'Edit', () {}),
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      offset: const Offset(0, 32),
                      onSelected: (v) {
                        if (v == 'suspend') _showSuspendDialog(user);
                        if (v == 'delete') _showDeleteDialog(user);
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'suspend', child: ListTile(leading: Icon(Icons.block, size: 18), title: Text('Suspend'), dense: true)),
                        const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, size: 18), title: Text('Delete'), dense: true)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuspendDialog(AdminUserEntity user) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Suspend ${user.name}'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: 'Enter reason for suspension'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              context.read<AdminBloc>().add(AdminSuspendUser(userId: user.id, reason: reasonController.text));
              Navigator.pop(ctx);
            },
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(AdminUserEntity user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${user.name}'),
        content: const Text('Are you sure? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              context.read<AdminBloc>().add(AdminDeleteUser(user.id));
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(ThemeData theme, String role) {
    final color = role == 'Admin' ? Colors.purple : role == 'Moderator' ? Colors.blue : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(role, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active': color = Colors.green; break;
      case 'suspended': color = Colors.red; break;
      case 'banned': color = Colors.red.shade900; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }

  Widget _rowAction(ThemeData theme, IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      onPressed: onTap,
      style: IconButton.styleFrom(padding: const EdgeInsets.all(6)),
    );
  }

  Widget _buildPagination(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Showing 1-25 users', style: TextStyle(fontSize: 13)),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.chevron_left, size: 20), onPressed: () {}, padding: EdgeInsets.zero),
              _pageBtn('1', true),
              IconButton(icon: const Icon(Icons.chevron_right, size: 20), onPressed: () {}, padding: EdgeInsets.zero),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pageBtn(String label, bool active) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: const Size(30, 30),
          backgroundColor: active ? theme.colorScheme.primaryContainer : null,
          foregroundColor: active ? theme.colorScheme.onPrimaryContainer : null,
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
              const Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
              const SizedBox(height: 8),
              const Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
          ),
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

  void _showUserDetail(BuildContext context, AdminUserEntity user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Row(children: [
                CircleAvatar(radius: 30, child: Text(user.initials)),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(user.email, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                ]),
              ]),
              const SizedBox(height: 24),
              _detailRow('ID', user.id),
              _detailRow('Role', user.role),
              _detailRow('Status', user.status),
              _detailRow('Joined', user.joined),
              _detailRow('Sessions', '${user.sessions}'),
              _detailRow('Rating', '${user.rating}/5.0'),
              _detailRow('Reports', '${user.reportsCount}'),
              _detailRow('2FA Enabled', user.twoFactorEnabled ? 'Yes' : 'No'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w500)), Text(value)],
      ),
    );
  }
}
