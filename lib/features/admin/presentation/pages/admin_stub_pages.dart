import 'package:flutter/material.dart';

class AdminUserManagementPage extends StatelessWidget {
  const AdminUserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _stubPage(context, 'User Management', Icons.people);
  }
}

Widget _stubPage(BuildContext context, String title, IconData icon) {
  final theme = Theme.of(context);
  return Scaffold(
    appBar: AppBar(title: Text(title), centerTitle: true),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 24),
          Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Coming soon',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    ),
  );
}

class AdminContentModerationPage extends StatelessWidget {
  const AdminContentModerationPage({super.key});
  @override
  Widget build(BuildContext context) => _stubPage(context, 'Content Moderation', Icons.flag);
}

class AdminPenaltiesPage extends StatelessWidget {
  const AdminPenaltiesPage({super.key});
  @override
  Widget build(BuildContext context) => _stubPage(context, 'Penalties', Icons.gavel);
}

class AdminAnalyticsPage extends StatelessWidget {
  const AdminAnalyticsPage({super.key});
  @override
  Widget build(BuildContext context) => _stubPage(context, 'Analytics', Icons.analytics);
}

class AdminSystemConfigPage extends StatelessWidget {
  const AdminSystemConfigPage({super.key});
  @override
  Widget build(BuildContext context) => _stubPage(context, 'System Config', Icons.settings);
}

class AdminCategoryManagementPage extends StatelessWidget {
  const AdminCategoryManagementPage({super.key});
  @override
  Widget build(BuildContext context) => _stubPage(context, 'Category Management', Icons.category);
}

class AdminBroadcastPage extends StatelessWidget {
  const AdminBroadcastPage({super.key});
  @override
  Widget build(BuildContext context) => _stubPage(context, 'Broadcast', Icons.campaign);
}

class AdminAuditLogPage extends StatelessWidget {
  const AdminAuditLogPage({super.key});
  @override
  Widget build(BuildContext context) => _stubPage(context, 'Audit Log', Icons.record_voice_over);
}

class AdminRoleManagementPage extends StatelessWidget {
  const AdminRoleManagementPage({super.key});
  @override
  Widget build(BuildContext context) => _stubPage(context, 'Role Management', Icons.admin_panel_settings);
}

class AdminDatabasePage extends StatelessWidget {
  const AdminDatabasePage({super.key});
  @override
  Widget build(BuildContext context) => _stubPage(context, 'Database Admin', Icons.storage);
}
