import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/utils/responsive_utils.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:myapp/features/admin/domain/entities/admin_entities.dart';
import 'package:intl/intl.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_sidebar.dart';

class AdminAuditLogPage extends StatefulWidget {
  const AdminAuditLogPage({super.key});

  @override
  State<AdminAuditLogPage> createState() => _AdminAuditLogPageState();
}

class _AdminAuditLogPageState extends State<AdminAuditLogPage> {
  final _searchController = TextEditingController();
  String _adminFilter = 'All Admins';
  String _actionFilter = 'All Actions';
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
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      appBar: AdminAppBar(title: 'Audit Log'),
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

    return Column(
      children: [
        _buildToolbar(theme),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _logs.length,
            itemBuilder: (_, i) => _buildLogEntry(theme, _logs[i]),
          ),
        ),
        _buildPagination(theme),
      ],
    );
  }

  Widget _buildToolbar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ResponsiveUtils.isMobile(context))
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search log entries...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                _dropdownFilter(theme, _adminFilter, ['All Admins', 'Admin_A', 'Admin_B', 'Admin_C', 'System'], (v) => setState(() => _adminFilter = v)),
                _dropdownFilter(theme, _actionFilter, ['All Actions', 'Login', 'User Management', 'Content Moderation', 'Dispute Resolution', 'System Config', 'Broadcast'], (v) => setState(() => _actionFilter = v)),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Export'),
                ),
              ],
            )
          else
            Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search log entries...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                _dropdownFilter(theme, _adminFilter, ['All Admins', 'Admin_A', 'Admin_B', 'Admin_C', 'System'], (v) => setState(() => _adminFilter = v)),
                const SizedBox(width: 8),
                _dropdownFilter(theme, _actionFilter, ['All Actions', 'Login', 'User Management', 'Content Moderation', 'Dispute Resolution', 'System Config', 'Broadcast'], (v) => setState(() => _actionFilter = v)),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Export'),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
                child: Text('Active Filters: 2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimaryContainer)),
              ),
              const SizedBox(width: 8),
              TextButton(onPressed: () => setState(() { _adminFilter = 'All Admins'; _actionFilter = 'All Actions'; }), child: const Text('Clear All')),
            ],
          ),
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
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 13)))).toList(),
        ),
      ),
    );
  }

  Widget _buildLogEntry(ThemeData theme, AuditLogEntryEntity entry) {
    final timeStr = DateFormat('HH:mm:ss').format(entry.timestamp);
    final severityIcon = entry.severity == 'critical' ? Icons.error : entry.severity == 'warning' ? Icons.warning_amber : Icons.info;
    final severityColor = entry.severity == 'critical' ? Colors.red : entry.severity == 'warning' ? Colors.orange : theme.colorScheme.onSurface.withValues(alpha: 0.4);

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Icon(severityIcon, size: 18, color: severityColor),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4)),
              child: Text(timeStr, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontFamily: 'monospace')),
            ),
            const SizedBox(width: 12),
            Text(entry.actorName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
            const SizedBox(width: 8),
            Text(entry.action, style: const TextStyle(fontSize: 13)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 34, top: 4),
          child: Text(entry.detail, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.ip != null)
                  _detailItem(theme, 'IP Address', entry.ip!),
                if (entry.device != null)
                  _detailItem(theme, 'Device', entry.device!),
                if (entry.changes != null)
                  _detailItem(theme, 'Changes', entry.changes!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
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
          Text('Showing 1-25 of 12,847 entries', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          Row(children: [
            IconButton(icon: const Icon(Icons.chevron_left, size: 20), onPressed: null, padding: EdgeInsets.zero),
            _pageBtn('1', true), _pageBtn('2', false), _pageBtn('3', false), _pageBtn('4', false), _pageBtn('5', false),
            Text('...'), _pageBtn('514', false),
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

final _logs = [
  AuditLogEntryEntity(id: 'l1', timestamp: DateTime.now(), actorId: 'a1', actorName: 'Admin_A', actorRole: 'Admin', action: 'Suspended user Kwanele Mhlongo (#2847)', detail: 'Reason: Violation of Rule 3', severity: 'critical', ip: '192.168.1.1', device: 'Chrome/Windows', changes: 'Status: Active → Suspended'),
  AuditLogEntryEntity(id: 'l2', timestamp: DateTime.now(), actorId: 'a2', actorName: 'Admin_B', actorRole: 'Admin', action: 'Modified agreement #D-2026-0042 terms', detail: 'Change: Duration 8→12 weeks', severity: 'info', changes: 'Duration: 8 → 12 weeks'),
  AuditLogEntryEntity(id: 'l3', timestamp: DateTime.now(), actorId: 'system', actorName: 'System', actorRole: 'System', action: 'User registered Thandi Nkosi (#2848)', detail: 'Email: thandi@example.com | Signup via: Google OAuth', severity: 'info'),
  AuditLogEntryEntity(id: 'l4', timestamp: DateTime.now(), actorId: 'a1', actorName: 'Admin_A', actorRole: 'Admin', action: 'Login successful', detail: 'Admin_A authenticated successfully', severity: 'info', ip: '10.0.0.5', device: 'Chrome/Windows'),
  AuditLogEntryEntity(id: 'l5', timestamp: DateTime.now(), actorId: 'a3', actorName: 'Admin_C', actorRole: 'Admin', action: 'Deleted review #1568 by Busi D', detail: 'Reason: Inappropriate content', severity: 'warning', changes: 'Review: visible → hidden'),
  AuditLogEntryEntity(id: 'l6', timestamp: DateTime.now(), actorId: 'system', actorName: 'System', actorRole: 'System', action: 'Auto-flagged content in chat #2291', detail: 'Pattern: spam link detected', severity: 'warning'),
  AuditLogEntryEntity(id: 'l7', timestamp: DateTime.now(), actorId: 'a2', actorName: 'Admin_B', actorRole: 'Admin', action: 'Applied penalty to Sipho Zulu', detail: 'Type: Warning | Strike: 1/3', severity: 'warning'),
  AuditLogEntryEntity(id: 'l8', timestamp: DateTime.now(), actorId: 'a1', actorName: 'Admin_A', actorRole: 'Admin', action: 'Updated system config: match radius', detail: 'Changed from 30km to 50km', severity: 'info', changes: 'Match Radius: 30 → 50'),
  AuditLogEntryEntity(id: 'l9', timestamp: DateTime.now(), actorId: 'a3', actorName: 'Admin_C', actorRole: 'Admin', action: 'Resolved dispute #DSP-2026-0089', detail: 'Decision: In favor of reporter', severity: 'info'),
  AuditLogEntryEntity(id: 'l10', timestamp: DateTime.now(), actorId: 'system', actorName: 'System', actorRole: 'System', action: 'Daily backup completed', detail: 'Size: 2.4GB | Duration: 12m 34s', severity: 'info'),
];
