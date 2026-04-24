import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/usecase/admin/admin_viewmodel.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F2027),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => viewModel.loadDashboardData(),
            icon: const Icon(Icons.refresh, color: Colors.white70),
          ),
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.logout, color: Colors.white70),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : RefreshIndicator(
                onRefresh: () => viewModel.loadDashboardData(),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildMetricsGrid(viewModel),
                    const SizedBox(height: 32),
                    _buildSectionHeader('System Activity'),
                    const SizedBox(height: 16),
                    _buildSystemLogs(viewModel),
                    const SizedBox(height: 32),
                    _buildSectionHeader('User Management'),
                    const SizedBox(height: 16),
                    _buildUserList(viewModel),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMetricsGrid(AdminViewModel viewModel) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard('Total Users', viewModel.users.length.toString(), Icons.people, Colors.blueAccent),
        _buildMetricCard('Active Agreements', viewModel.agreements.length.toString(), Icons.handshake, Colors.greenAccent),
        _buildMetricCard('Admin Users', viewModel.users.where((u) => u.role == UserRole.admin).length.toString(), Icons.admin_panel_settings, Colors.orangeAccent),
        _buildMetricCard('Platform Health', 'Good', Icons.security, Colors.purpleAccent),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemLogs(AdminViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: viewModel.systemLogs.map((log) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    log,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserList(AdminViewModel viewModel) {
    if (viewModel.users.isEmpty) {
      return const Center(child: Text('No users found.', style: TextStyle(color: Colors.white70)));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = viewModel.users[index];
        return _buildUserCard(user, viewModel);
      },
    );
  }

  Widget _buildUserCard(UserModel user, AdminViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: user.isSuspended ? Colors.redAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: user.isSuspended ? Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1) : null,
      ),
      child: Row(
        children: [
          Opacity(
            opacity: user.isSuspended ? 0.5 : 1.0,
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(user.displayName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.displayName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: user.isSuspended ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (user.isSuspended) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.block, color: Colors.redAccent, size: 14),
                    ],
                  ],
                ),
                Text(user.email, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ),
          if (user.role == UserRole.admin)
            const Chip(
              label: Text('Admin', style: TextStyle(fontSize: 10, color: Colors.white)),
              backgroundColor: Colors.orangeAccent,
              padding: EdgeInsets.zero,
            )
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              color: const Color(0xFF203A43),
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteConfirmation(user.uid, viewModel);
                } else if (value == 'promote') {
                  viewModel.promoteToAdmin(user.uid);
                } else if (value == 'toggle_suspend') {
                  viewModel.toggleSuspension(user.uid, !user.isSuspended);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'promote', child: Text('Promote to Admin', style: TextStyle(color: Colors.white))),
                PopupMenuItem(
                  value: 'toggle_suspend',
                  child: Text(
                    user.isSuspended ? 'Unsuspend User' : 'Suspend User',
                    style: TextStyle(color: user.isSuspended ? Colors.greenAccent : Colors.orangeAccent),
                  ),
                ),
                const PopupMenuItem(value: 'delete', child: Text('Delete User', style: TextStyle(color: Colors.redAccent))),
              ],
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String uid, AdminViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: const Text('Delete User?', style: TextStyle(color: Colors.white)),
        content: const Text('This action is permanent and will remove all user data.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              viewModel.deleteUser(uid);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
