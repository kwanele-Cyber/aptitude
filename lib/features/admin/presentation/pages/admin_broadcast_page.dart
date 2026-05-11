import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/utils/responsive_utils.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:myapp/features/admin/domain/entities/admin_entities.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_sidebar.dart';

class AdminBroadcastPage extends StatefulWidget {
  const AdminBroadcastPage({super.key});

  @override
  State<AdminBroadcastPage> createState() => _AdminBroadcastPageState();
}

class _AdminBroadcastPageState extends State<AdminBroadcastPage> {
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _audience = 'All Users';
  bool _scheduled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
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
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      appBar: AdminAppBar(title: 'Broadcast Center'),
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
      child: ResponsiveUtils.isMobile(context)
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildComposer(theme),
              const SizedBox(height: 24),
              _buildHistory(theme),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildComposer(theme)),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: _buildHistory(theme)),
            ],
          ),
    );
  }

  Widget _buildComposer(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Compose New Broadcast', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Audience *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _audience,
                          isExpanded: true,
                          style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                          onChanged: (v) => setState(() => _audience = v!),
                          items: ['All Users', 'All Active', 'Users Only', 'Admins Only', 'Moderators Only'].map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                        ),
                      ),
                    ),
                    Text('2,847', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageCtrl,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Message *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.text_fields, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                  const SizedBox(width: 4),
                  Text('${_messageCtrl.text.length}/2000 characters', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Schedule', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
                  const SizedBox(width: 12),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Send Now')),
                      ButtonSegment(value: true, label: Text('Schedule')),
                    ],
                    selected: {_scheduled},
                    onSelectionChanged: (v) => setState(() => _scheduled = v.first),
                  ),
                ],
              ),
              if (_scheduled) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.date_range, size: 16),
                        label: const Text('Select Date'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.access_time, size: 16),
                        label: const Text('Select Time'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Preview'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        if (_titleCtrl.text.isEmpty || _messageCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and message are required')));
                          return;
                        }
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Send Broadcast?'),
                            content: Text('This will be sent to ${_audience.toLowerCase()} (estimated 2,847 recipients).'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                              FilledButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Broadcast sent successfully'))); }, child: const Text('Send')),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.send, size: 16),
                      label: const Text('Send Broadcast'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistory(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Broadcasts', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        ..._broadcasts.map((b) => Card(
          margin: const EdgeInsets.only(bottom: 12),
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
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.email, size: 16, color: theme.colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(b.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.people, size: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                    const SizedBox(width: 4),
                    Text('${b.recipientCount} users', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                    const SizedBox(width: 4),
                    Text(b.sentDate, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: b.openRate / 100,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  color: Colors.green,
                  minHeight: 4,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${b.openRate}% open rate', style: TextStyle(fontSize: 11, color: Colors.green.shade700)),
                    const Spacer(),
                    TextButton.icon(onPressed: () {}, icon: const Icon(Icons.bar_chart, size: 14), label: const Text('Stats', style: TextStyle(fontSize: 11))),
                    TextButton.icon(onPressed: () {}, icon: const Icon(Icons.refresh, size: 14), label: const Text('Resend', style: TextStyle(fontSize: 11))),
                  ],
                ),
              ],
            ),
          ),
        )),
      ],
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

final _broadcasts = [
  BroadcastMessageEntity(id: 'b1', title: 'Platform Update v2.1', message: 'We\'re excited to announce...', audience: 'All Users', recipientCount: 2847, sentDate: 'Feb 10, 2026', openRate: 68),
  BroadcastMessageEntity(id: 'b2', title: 'Maintenance Notice', message: 'Scheduled maintenance...', audience: 'All Users', recipientCount: 2801, sentDate: 'Feb 5, 2026', openRate: 82),
  BroadcastMessageEntity(id: 'b3', title: 'Community Guidelines Update', message: 'Please review...', audience: 'All Users', recipientCount: 2750, sentDate: 'Jan 28, 2026', openRate: 74),
];
