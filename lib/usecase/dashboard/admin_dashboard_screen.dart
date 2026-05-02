import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RoleDashboardScaffold(
      title: 'Admin Dashboard',
      cards: [
        _DashboardCardData('User Management', Icons.admin_panel_settings, 'Review user access and permissions.'),
        _DashboardCardData('Reports Queue', Icons.report, 'Moderate reports and platform safety issues.'),
        _DashboardCardData('System Health', Icons.monitor_heart, 'Track app uptime and service status.'),
      ],
    );
  }
}

class _RoleDashboardScaffold extends StatelessWidget {
  final String title;
  final List<_DashboardCardData> cards;

  const _RoleDashboardScaffold({required this.title, required this.cards});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final card = cards[index];
          return Card(
            child: ListTile(
              leading: Icon(card.icon),
              title: Text(card.title),
              subtitle: Text(card.description),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardCardData {
  final String title;
  final IconData icon;
  final String description;

  const _DashboardCardData(this.title, this.icon, this.description);
}
