import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  String _statusFilter = 'Pending';
  String _priorityFilter = 'All';
  bool _isLoading = true;
  final Set<int> _selected = {};

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
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 720;

    return Scaffold(
      appBar: AdminAppBar(title: 'Content Moderation'),
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

    final flagged = _mockFlaggedItems;

    return Column(
      children: [
        _buildSummaryBar(theme),
        const Divider(height: 1),
        _buildSearchAndFilter(theme),
        const Divider(height: 1),
        if (_selected.isNotEmpty) _buildBulkBar(theme),
        Expanded(
          child: flagged.isEmpty
              ? _buildEmpty(theme)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: flagged.length,
                  itemBuilder: (_, i) => _buildFlaggedCard(theme, flagged[i], i),
                ),
        ),
        _buildPagination(theme),
      ],
    );
  }

  Widget _buildSummaryBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: theme.colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          _statChip(theme, Icons.flag, '23 Pending', Colors.orange),
          const SizedBox(width: 16),
          _statChip(theme, Icons.warning_amber, '12 Escalated', Colors.red),
          const Spacer(),
          Icon(Icons.refresh, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
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
      child: Row(
        children: [
          SizedBox(
            width: 320,
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
          const SizedBox(width: 12),
          _dropdownFilter(theme, _typeFilter, ['All Types', 'Messages', 'Reviews', 'Profiles', 'Notes', 'Images'], (v) => setState(() => _typeFilter = v)),
          const SizedBox(width: 8),
          _dropdownFilter(theme, _statusFilter, ['Pending', 'Under Review', 'Resolved', 'Dismissed'], (v) => setState(() => _statusFilter = v)),
          const SizedBox(width: 8),
          _dropdownFilter(theme, _priorityFilter, ['All', 'High', 'Medium', 'Low'], (v) => setState(() => _priorityFilter = v)),
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
          Text('${_selected.length} selected', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 16),
          _bulkBtn('Dismiss', Icons.check_circle_outline),
          const SizedBox(width: 8),
          _bulkBtn('Remove Content', Icons.delete_outline),
          const SizedBox(width: 8),
          _bulkBtn('Suspend User', Icons.block),
          const Spacer(),
          TextButton(onPressed: () => setState(() => _selected.clear()), child: const Text('Clear')),
        ],
      ),
    );
  }

  Widget _bulkBtn(String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () => _showConfirm(context, label),
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
    );
  }

  Widget _buildFlaggedCard(ThemeData theme, _MockFlaggedItem item, int index) {
    final isSelected = _selected.contains(index);
    final priorityColor = item.priority == 'HIGH' ? Colors.red : item.priority == 'MED' ? Colors.orange : Colors.grey;

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
            if (isSelected) { _selected.remove(index); } else { _selected.add(index); }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Checkbox(value: isSelected, onChanged: (v) {
                setState(() { if (v == true) { _selected.add(index); } else { _selected.remove(index); } });
              }),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: priorityColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(item.priority, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: priorityColor)),
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
                        Text('Reported by: ${item.reportedBy}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, size: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                        const SizedBox(width: 4),
                        Text(item.timestamp, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                        const SizedBox(width: 16),
                        Icon(Icons.person, size: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                        const SizedBox(width: 4),
                        Text('From: ${item.from}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _actionBtn('View', Icons.visibility_outlined, () => _showDetail(context, item)),
              const SizedBox(width: 4),
              _actionBtn('Dismiss', Icons.check, () => _showConfirm(context, 'Dismiss')),
              const SizedBox(width: 4),
              _actionBtn('Action', Icons.more_horiz, () {}),
            ],
          ),
        ),
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
            child: Icon(Icons.shield, size: 40, color: Colors.green),
          ),
          const SizedBox(height: 16),
          Text('All clear!', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('No flagged content pending review.', style: theme.textTheme.bodySmall),
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
          Text('Showing 1-10 of 23', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          Row(children: [
            IconButton(icon: const Icon(Icons.chevron_left, size: 20), onPressed: null, padding: EdgeInsets.zero),
            _pageBtn('1', true), _pageBtn('2', false), _pageBtn('3', false),
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

  void _showConfirm(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$action?'),
        content: Text('Are you sure you want to $action this content? This action will be logged.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () { Navigator.pop(ctx); }, child: const Text('Confirm')),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, _MockFlaggedItem item) {
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
                    color: (item.priority == 'HIGH' ? Colors.red : item.priority == 'MED' ? Colors.orange : Colors.grey).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(item.priority, style: TextStyle(fontWeight: FontWeight.bold, color: item.priority == 'HIGH' ? Colors.red : item.priority == 'MED' ? Colors.orange : Colors.grey)),
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
              _detailRow('From user', item.from),
              _detailRow('Time', item.timestamp),
              _detailRow('Type', item.type),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontWeight: FontWeight.w500)), Text(value)]),
    );
  }
}

class _MockFlaggedItem {
  final String priority;
  final String reason;
  final String preview;
  final String reportedBy;
  final String from;
  final String timestamp;
  final String type;
  _MockFlaggedItem({required this.priority, required this.reason, required this.preview, required this.reportedBy, required this.from, required this.timestamp, required this.type});
}

final _mockFlaggedItems = [
  _MockFlaggedItem(priority: 'HIGH', reason: 'Inappropriate message', preview: '"You are so..." in chat conversation', reportedBy: 'Thandi Nkosi', from: 'Kwanele Mhlongo', timestamp: '5m ago', type: 'Message'),
  _MockFlaggedItem(priority: 'MED', reason: 'Spam review', preview: '"Check out my..." on Busi\'s profile', reportedBy: 'Auto-flagged', from: 'Busi Dlamini', timestamp: '15m ago', type: 'Review'),
  _MockFlaggedItem(priority: 'LOW', reason: 'Offensive avatar', preview: 'Profile picture flagged as inappropriate', reportedBy: 'Auto-flagged', from: 'Unknown', timestamp: '1h ago', type: 'Profile'),
  _MockFlaggedItem(priority: 'HIGH', reason: 'Harassment report', preview: 'Repeated messages in direct chat', reportedBy: 'Sipho Zulu', from: 'Lindiwe Mokoena', timestamp: '2h ago', type: 'Message'),
  _MockFlaggedItem(priority: 'MED', reason: 'Misleading content', preview: 'False information in skill description', reportedBy: 'Nomsa Khumalo', from: 'Themba Mthembu', timestamp: '3h ago', type: 'Skills'),
];
