import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'complaint_detail_screen.dart';
import 'admin_users_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  List<Complaint> _complaints = [];
  Map<String, dynamic> _stats = {};
  bool _loading = true;
  String _filter = 'ALL';
  late TabController _tabCtrl;

  final _statusFilters = [
    'ALL', 'PENDING', 'REVIEWING', 'RESOLVED', 'DISMISSED'
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.getAllComplaints(status: _filter),
        ApiService.getAdminStats(),
      ]);
      _complaints = results[0] as List<Complaint>;
      _stats = results[1] as Map<String, dynamic>;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AdminUsersScreen()),
            ),
            tooltip: 'Manage Users',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppTheme.lightPurple,
          labelColor: AppTheme.lightPurple,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Complaints'),
            Tab(text: 'Overview'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _complaintsTab(),
          _overviewTab(),
        ],
      ),
    );
  }

  Widget _complaintsTab() {
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            itemCount: _statusFilters.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = _statusFilters[i];
              final isSelected = _filter == f;
              return FilterChip(
                label: Text(f == 'ALL'
                    ? 'All'
                    : f.toLowerCase().capitalize()),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _filter = f);
                  _load();
                },
                selectedColor: AppTheme.primaryPurple,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppTheme.textSecondary,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              );
            },
          ),
        ),
        const Divider(height: 1, color: AppTheme.dividerColor),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.lightPurple))
              : _complaints.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.task_alt,
                              size: 48,
                              color: AppTheme.textSecondary),
                          const SizedBox(height: 12),
                          Text('No $_filter complaints',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 16)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppTheme.lightPurple,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _complaints.length,
                        itemBuilder: (_, i) => ComplaintCard(
                          complaint: _complaints[i],
                          isAdmin: true,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ComplaintDetailScreen(
                                  complaint: _complaints[i],
                                  isAdmin: true,
                                ),
                              ),
                            );
                            _load();
                          },
                        ),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _overviewTab() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(
              color: AppTheme.lightPurple));
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('System Overview',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _statCard(
                'Total Complaints',
                _stats['totalComplaints']?.toString() ?? '0',
                Icons.report_rounded,
                AppTheme.lightPurple),
            _statCard(
                'Pending Review',
                _stats['pendingComplaints']?.toString() ?? '0',
                Icons.hourglass_empty_rounded,
                AppTheme.pendingColor),
            _statCard(
                'Flagged Users',
                _stats['flaggedUsers']?.toString() ?? '0',
                Icons.flag_rounded,
                AppTheme.flaggedColor),
            _statCard(
                'Banned Accounts',
                _stats['bannedUsers']?.toString() ?? '0',
                Icons.block_rounded,
                AppTheme.bannedColor),
            _statCard(
                'Resolved',
                _stats['resolvedComplaints']?.toString() ?? '0',
                Icons.check_circle_rounded,
                AppTheme.resolvedColor),
            _statCard(
                'Dismissed',
                _stats['dismissedComplaints']?.toString() ?? '0',
                Icons.cancel_rounded,
                AppTheme.dismissedColor),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Quick Actions',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _quickAction(
          icon: Icons.people_rounded,
          label: 'Manage Users',
          subtitle: 'View strikes, ban/unban accounts',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AdminUsersScreen()),
          ),
        ),
        const SizedBox(height: 8),
        _quickAction(
          icon: Icons.hourglass_empty_rounded,
          label: 'Review Pending',
          subtitle: 'Handle outstanding complaints',
          onTap: () {
            _tabCtrl.animateTo(0);
            setState(() => _filter = 'PENDING');
            _load();
          },
        ),
      ],
    );
  }

  Widget _statCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 28,
                      fontWeight: FontWeight.w800)),
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: AppTheme.lightPurple, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => isEmpty
      ? this
      : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}