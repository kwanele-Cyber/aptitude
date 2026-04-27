import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() =>
      _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<UserSummary> _users = [];
  List<UserSummary> _filtered = [];
  bool _loading = true;
  bool _actioning = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _users = await ApiService.getAllUsers();
      _applyFilter();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    _filtered = _users
        .where((u) =>
            u.name
                .toLowerCase()
                .contains(_search.toLowerCase()) ||
            u.email
                .toLowerCase()
                .contains(_search.toLowerCase()))
        .toList();
    _filtered.sort((a, b) {
      if (a.isBanned && !b.isBanned) return -1;
      if (!a.isBanned && b.isBanned) return 1;
      return b.strikeCount.compareTo(a.strikeCount);
    });
  }

  Future<void> _toggleBan(UserSummary user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(
          user.isBanned
              ? 'Unban ${user.name}?'
              : 'Ban ${user.name}?',
          style:
              const TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          user.isBanned
              ? 'This will restore access to their account.'
              : 'This will permanently block their access.',
          style:
              const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(
                    color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isBanned
                  ? AppTheme.resolvedColor
                  : AppTheme.bannedColor,
            ),
            child: Text(user.isBanned ? 'Unban' : 'Ban'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _actioning = true);
    try {
      if (user.isBanned) {
        await ApiService.unbanUser(user.id);
      } else {
        await ApiService.banUser(user.id);
      }
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(user.isBanned
              ? '✅ ${user.name} has been unbanned'
              : '🚫 ${user.name} has been banned'),
          backgroundColor: user.isBanned
              ? AppTheme.resolvedColor
              : AppTheme.bannedColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppTheme.flaggedColor,
        ));
      }
    } finally {
      if (mounted) setState(() => _actioning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      loading: _actioning,
      child: Scaffold(
        appBar:
            AppBar(title: const Text('User Management')),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                style: const TextStyle(
                    color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppTheme.textSecondary),
                ),
                onChanged: (v) {
                  setState(() {
                    _search = v;
                    _applyFilter();
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.lightPurple))
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppTheme.lightPurple,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) =>
                            _userCard(_filtered[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userCard(UserSummary user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: user.isBanned
              ? AppTheme.bannedColor.withValues(alpha: 0.5)
              : user.strikeCount > 0
                  ? AppTheme.flaggedColor.withValues(alpha: 0.3)
                  : AppTheme.dividerColor,
          width: user.isBanned ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: user.isBanned
                    ? AppTheme.bannedColor
                        .withValues(alpha: 0.2)
                    : AppTheme.primaryPurple
                        .withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: user.isBanned
                      ? AppTheme.bannedColor
                      : AppTheme.dividerColor,
                ),
              ),
              child: Icon(
                user.isBanned
                    ? Icons.block_rounded
                    : Icons.person_rounded,
                color: user.isBanned
                    ? AppTheme.bannedColor
                    : AppTheme.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(user.name,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                      if (user.isBanned) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.bannedColor
                                .withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(4),
                            border: Border.all(
                                color: AppTheme.bannedColor),
                          ),
                          child: const Text('BANNED',
                              style: TextStyle(
                                  color: AppTheme.bannedColor,
                                  fontSize: 9,
                                  fontWeight:
                                      FontWeight.w800)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(user.email,
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      StrikeBadge(
                          strikes: user.strikeCount),
                      const SizedBox(width: 10),
                      Text(
                        '${user.complaintsAgainst} reports',
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _toggleBan(user),
              icon: Icon(
                user.isBanned
                    ? Icons.lock_open_rounded
                    : Icons.block_rounded,
                color: user.isBanned
                    ? AppTheme.resolvedColor
                    : AppTheme.flaggedColor,
              ),
              tooltip:
                  user.isBanned ? 'Unban User' : 'Ban User',
            ),
          ],
        ),
      ),
    );
  }
}