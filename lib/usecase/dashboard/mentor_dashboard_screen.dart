import 'package:flutter/material.dart';

class MentorDashboardScreen extends StatelessWidget {
  const MentorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mentor Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _MetricTile(title: 'Active Mentorships', value: '8', icon: Icons.group),
          SizedBox(height: 12),
          _MetricTile(title: 'Pending Requests', value: '5', icon: Icons.pending_actions),
          SizedBox(height: 12),
          _MetricTile(title: 'Avg. Rating', value: '4.9', icon: Icons.star),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MetricTile({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }
}
