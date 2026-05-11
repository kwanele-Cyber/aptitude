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

class AdminContentModerationPage extends StatefulWidget {
  const AdminContentModerationPage({super.key});

  @override
  State<AdminContentModerationPage> createState() => _AdminContentModerationPageState();
}

class _AdminContentModerationPageState extends State<AdminContentModerationPage> {
  final _searchController = TextEditingController();
  String _typeFilter = 'All Types';
  String _statusFilter = 'All';
  String _priorityFilter = 'All';
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
    context.read<AdminBloc>().add(AdminLoadFlaggedContent(
      status: _statusFilter,
      priority: _priorityFilter,
      type: _typeFilter == 'All Types' ? 'All' : _typeFilter,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      appBar: const AdminAppBar(title: 'Content Moderation'),
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
                    _buildSummaryBar(theme, state),
                    const Divider(height: 1),
                    _buildSearchAndFilter(theme),
                    const Divider(height: 1),
                    if (_selectedIds.isNotEmpty) _buildBulkBar(theme),
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
    if (state is AdminModerationLoading) {
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

    final items = state is AdminModerationLoaded ? state.items : <FlaggedContentEntity>[];
    if (items.isEmpty) return _buildEmpty(theme);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildFlaggedCard(theme, items[i]),
    );
  }

  Widget _buildSummaryBar(ThemeData theme, AdminState state) {
    final items = state is AdminModerationLoaded ? state.items : <FlaggedContentEntity>[];
    final pendingCount = items.where((i) => i.status == 'Pending').length;
    final highPriorityCount = items.where((i) => i.priority == 'High').length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: theme.colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          _statChip(theme, Icons.flag, '$pendingCount Pending', Colors.orange),
          const SizedBox(width: 16),
          _statChip(theme, Icons.warning_amber, '$highPriorityCount High Priority', Colors.red),
          const Spacer(),
          IconButton(
            onPressed: _loadData,
            icon: Icon(Icons.refresh, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _statChip(ThemeData theme, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search flagged content...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          _dropdownFilter(theme, _typeFilter, ['All Types', 'Message', 'Review', 'Profile', 'Note', 'Image'], (v) {
            setState(() => _typeFilter = v);
            _loadData();
          }),
          _dropdownFilter(theme, _statusFilter, ['All', 'Pending', 'Under Review', 'Resolved', 'Dismissed'], (v) {
            setState(() => _statusFilter = v);
            _loadData();
          }),
          _dropdownFilter(theme, _priorityFilter, ['All', 'High', 'Medium', 'Low'], (v) {
            setState(() => _priorityFilter = v);
            _loadData();
          }),
        ],
      ),
    );
  }

  Widget _dropdownFilter(ThemeData theme, String current, List<String> options, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          isDense: true,
          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
          onChanged: (v) => onChanged(v!),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        ),
      ),
    );
  }

  Widget _buildBulkBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Row(
        children: [
          Text('${_selectedIds.length} selected', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 16),
          _bulkBtn('Dismiss', Icons.check_circle_outline, 'dismiss'),
          const SizedBox(width: 8),
          _bulkBtn('Remove Content', Icons.delete_outline, 'remove'),
          const Spacer(),
          TextButton(onPressed: () => setState(() => _selectedIds.clear()), child: const Text('Clear')),
        ],
      ),
    );
  }

  Widget _bulkBtn(String label, IconData icon, String action) {
    return OutlinedButton.icon(
      onPressed: () {
        context.read<AdminBloc>().add(AdminBulkModeration(flagIds: _selectedIds.toList(), action: action));
        setState(() => _selectedIds.clear());
      },
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
    );
  }

  Widget _buildFlaggedCard(ThemeData theme, FlaggedContentEntity item) {
    final isSelected = _selectedIds.contains(item.id);
    final priorityColor = item.priority.toUpperCase() == 'HIGH' ? Colors.red : item.priority.toUpperCase() == 'MEDIUM' ? Colors.orange : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            if (isSelected) { _selectedIds.remove(item.id); } else { _selectedIds.add(item.id); }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Checkbox(value: isSelected, onChanged: (v) {
                setState(() { if (v == true) { _selectedIds.add(item.id); } else { _selectedIds.remove(item.id); } });
              }),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: priorityColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(item.priority.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: priorityColor)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.reason, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(item.preview, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                        const SizedBox(width: 4),
                        Text('By: ${item.reportedBy}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, size: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                        const SizedBox(width: 4),
                        Text(item.timestamp, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                        const SizedBox(width: 16),
                        Icon(Icons.person, size: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                        const SizedBox(width: 4),
                        Text('Target: ${item.fromUser}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _actionBtn('View', Icons.visibility_outlined, () => _showDetail(context, item)),
              const SizedBox(width: 4),
              _actionBtn('Dismiss', Icons.check, () => _handleAction(item, 'dismiss')),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAction(FlaggedContentEntity item, String action) {
    if (action == 'dismiss') {
      context.read<AdminBloc>().add(AdminDismissFlag(item.id));
    } else if (action == 'remove') {
      _showRemoveDialog(item);
    }
  }

  void _showRemoveDialog(FlaggedContentEntity item) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Content'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: 'Enter reason for removal'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              context.read<AdminBloc>().add(AdminRemoveContent(flagId: item.id, reason: reasonController.text));
              Navigator.pop(ctx);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, IconData icon, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.shield, size: 40, color: Colors.green),
          ),
          const SizedBox(height: 16),
          Text('All clear!', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('No flagged content pending review.'),
        ],
      ),
    );
  }

  Widget _buildPagination(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Showing current results', style: TextStyle(fontSize: 13)),
          Row(children: [
            IconButton(icon: const Icon(Icons.chevron_left, size: 20), onPressed: () {}, padding: EdgeInsets.zero),
            _pageBtn('1', true),
            IconButton(icon: const Icon(Icons.chevron_right, size: 20), onPressed: () {}, padding: EdgeInsets.zero),
          ]),
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
    final theme = Theme.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
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

  void _showDetail(BuildContext context, FlaggedContentEntity item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (item.priority.toUpperCase() == 'HIGH' ? Colors.red : item.priority.toUpperCase() == 'MEDIUM' ? Colors.orange : Colors.grey).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(item.priority.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: item.priority.toUpperCase() == 'HIGH' ? Colors.red : item.priority.toUpperCase() == 'MEDIUM' ? Colors.orange : Colors.grey)),
                ),
                const Spacer(),
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
              ]),
              const SizedBox(height: 16),
              Text(item.reason, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                child: Text(item.preview, style: const TextStyle(fontSize: 14, height: 1.5)),
              ),
              const SizedBox(height: 16),
              _detailRow('Reported by', item.reportedBy),
              _detailRow('Target user', item.fromUser),
              _detailRow('Time', item.timestamp),
              _detailRow('Type', item.type),
              _detailRow('Status', item.status),
              if (item.contentId != null) _detailRow('Content ID', item.contentId!),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _handleAction(item, 'dismiss');
                        Navigator.pop(ctx);
                      },
                      child: const Text('Dismiss Report'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showRemoveDialog(item);
                      },
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Remove Content'),
                    ),
                  ),
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
