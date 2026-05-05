import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/utils/responsive_utils.dart';
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
  int _selectedCount = 0;
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
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      appBar: AdminAppBar(title: 'User Management'),
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
    if (_isLoading) return _buildLoading(theme);

    return Column(
      children: [
        _buildSearchAndFilter(theme),
        const Divider(height: 1),
        if (_selectedCount > 0) _buildBulkActionBar(theme),
        Expanded(child: _buildTable(theme)),
        _buildPagination(theme),
      ],
    );
  }

  Widget _buildLoading(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text('Loading user data...', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
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
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 12),
          if (ResponsiveUtils.isMobile(context))
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildFilterChip(theme, 'Role', _roleFilter, ['All', 'User', 'Admin', 'Moderator', 'Support'], (v) {
                  setState(() => _roleFilter = v);
                }),
                const SizedBox(width: 8),
                _buildFilterChip(theme, 'Status', _statusFilter, ['All', 'Active', 'Suspended', 'Deleted', 'Banned'], (v) {
                  setState(() => _statusFilter = v);
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
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ],
            )
          else
            Row(
              children: [
                _buildFilterChip(theme, 'Role', _roleFilter, ['All', 'User', 'Admin', 'Moderator', 'Support'], (v) {
                  setState(() => _roleFilter = v);
                }),
                const SizedBox(width: 8),
                _buildFilterChip(theme, 'Status', _statusFilter, ['All', 'Active', 'Suspended', 'Deleted', 'Banned'], (v) {
                  setState(() => _statusFilter = v);
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
          Text('$_selectedCount selected', style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
          const SizedBox(width: 16),
          _bulkButton(theme, Icons.block, 'Suspend'),
          const SizedBox(width: 8),
          _bulkButton(theme, Icons.delete_outline, 'Delete'),
          const SizedBox(width: 8),
          _bulkButton(theme, Icons.swap_horiz, 'Change Role'),
          const Spacer(),
          TextButton(
            onPressed: () => setState(() => _selectedCount = 0),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _bulkButton(ThemeData theme, IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () => _showConfirmation(context, label),
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        textStyle: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _buildTable(ThemeData theme) {
    final users = _mockUsers;

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
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 32, child: Text('')),
                  const Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  const Expanded(flex: 2, child: Text('Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  const Expanded(child: Text('Role', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  const Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  const Expanded(child: Text('Joined', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  const SizedBox(width: 120, child: Text('', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Table rows
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
                      Text('Try adjusting your search or filters', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRow(ThemeData theme, _MockUser user) {
    final isSelected = user.selected;
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => user.selected = !user.selected),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (v) => setState(() => user.selected = v ?? false),
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
                        Text(user.name, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                        Text('@${user.username}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
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
                        if (v == 'suspend') _showConfirmation(context, 'Suspend ${user.name}');
                        if (v == 'delete') _showConfirmation(context, 'Delete ${user.name}');
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
          Text('Showing 1-25 of 2,847 users', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.chevron_left, size: 20), onPressed: null, padding: EdgeInsets.zero),
              _pageBtn('1', true), _pageBtn('2', false), _pageBtn('3', false), _pageBtn('4', false), _pageBtn('5', false),
              Text('...', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
              _pageBtn('114', false),
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
              Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
              const SizedBox(height: 8),
              Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
          ),
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

  void _showConfirmation(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Action'),
        content: Text('Are you sure you want to $action? This action can be audited.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () { Navigator.pop(ctx); }, child: const Text('Confirm')),
        ],
      ),
    );
  }

  void _showUserDetail(BuildContext context, _MockUser user) {
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
                  Text('@${user.username}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                ]),
              ]),
              const SizedBox(height: 24),
              _detailRow('Email', user.email),
              _detailRow('Role', user.role),
              _detailRow('Status', user.status),
              _detailRow('Joined', user.joined),
              _detailRow('Sessions', '${user.sessions}'),
              _detailRow('Rating', '${user.rating}/5.0'),
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
        children: [Text(label, style: TextStyle(fontWeight: FontWeight.w500)), Text(value)],
      ),
    );
  }
}

class _MockUser {
  final String name;
  final String username;
  final String email;
  final String role;
  final String status;
  final String joined;
  final int sessions;
  final double rating;
  bool selected = false;

  _MockUser({required this.name, required this.username, required this.email, required this.role, required this.status, required this.joined, this.sessions = 0, this.rating = 0.0});

  String get initials => name.split(' ').map((n) => n[0]).take(2).join();
}

final _mockUsers = [
  _MockUser(name: 'Kwanele Mhlongo', username: 'kwanele', email: 'kwanele@example.com', role: 'User', status: 'Active', joined: 'Jan 2026', sessions: 24, rating: 4.8),
  _MockUser(name: 'Thandi Nkosi', username: 'thandi', email: 'thandi@example.com', role: 'User', status: 'Active', joined: 'Feb 2026', sessions: 18, rating: 4.5),
  _MockUser(name: 'Admin A', username: 'admin_a', email: 'admin@example.com', role: 'Admin', status: 'Active', joined: 'Dec 2025', sessions: 0, rating: 5.0),
  _MockUser(name: 'Busi Dlamini', username: 'busi', email: 'busi@example.com', role: 'User', status: 'Suspended', joined: 'Mar 2026', sessions: 7, rating: 3.2),
  _MockUser(name: 'Sipho Zulu', username: 'sipho', email: 'sipho@example.com', role: 'Moderator', status: 'Active', joined: 'Jan 2026', sessions: 42, rating: 4.9),
  _MockUser(name: 'Lindiwe Mokoena', username: 'lindiwe', email: 'lindiwe@example.com', role: 'User', status: 'Active', joined: 'Apr 2026', sessions: 3, rating: 4.0),
  _MockUser(name: 'Nomsa Khumalo', username: 'nomsa', email: 'nomsa@example.com', role: 'User', status: 'Banned', joined: 'Feb 2026', sessions: 1, rating: 1.0),
  _MockUser(name: 'Themba Mthembu', username: 'themba', email: 'themba@example.com', role: 'Support', status: 'Active', joined: 'Nov 2025', sessions: 56, rating: 4.7),
];
