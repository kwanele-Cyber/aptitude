import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final Complaint complaint;
  final bool isAdmin;

  const ComplaintDetailScreen({
    super.key,
    required this.complaint,
    required this.isAdmin,
  });

  @override
  State<ComplaintDetailScreen> createState() =>
      _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState
    extends State<ComplaintDetailScreen> {
  late Complaint _complaint;
  bool _updating = false;
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _complaint = widget.complaint;
    if (_complaint.adminNote != null) {
      _noteCtrl.text = _complaint.adminNote!;
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String status,
      {bool issueStrike = false}) async {
    setState(() => _updating = true);
    try {
      final updated = await ApiService.updateComplaintStatus(
        complaintId: _complaint.id,
        status: status,
        adminNote: _noteCtrl.text.trim().isEmpty
            ? null
            : _noteCtrl.text.trim(),
        issueStrike: issueStrike,
      );
      setState(() => _complaint = updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(issueStrike
              ? '✅ Strike issued & complaint resolved'
              : '✅ Status updated to $status'),
          backgroundColor: AppTheme.resolvedColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppTheme.flaggedColor,
        ));
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  void _showActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Actions',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              'Complaint #${_complaint.id} · '
              'Against ${_complaint.reportedUserName}',
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _noteCtrl,
              style: const TextStyle(
                  color: AppTheme.textPrimary),
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Add admin note (optional)...',
                prefixIcon: Icon(Icons.note_alt_outlined,
                    color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
            if (_complaint.status == 'pending')
              _actionBtn(
                icon: Icons.manage_search_rounded,
                label: 'Mark as Reviewing',
                color: AppTheme.reviewingColor,
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus('reviewing');
                },
              ),
            if (_complaint.status != 'resolved' &&
                _complaint.status != 'dismissed') ...[
              const SizedBox(height: 8),
              _actionBtn(
                icon: Icons.flag_rounded,
                label: 'Issue Strike & Resolve',
                subtitle:
                    '${_complaint.strikeCount}/3 strikes — '
                    '${3 - _complaint.strikeCount} more until ban',
                color: AppTheme.flaggedColor,
                onTap: () {
                  Navigator.pop(context);
                  _showStrikeConfirm();
                },
              ),
              const SizedBox(height: 8),
              _actionBtn(
                icon: Icons.check_circle_rounded,
                label: 'Resolve (No Strike)',
                color: AppTheme.resolvedColor,
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus('resolved');
                },
              ),
              const SizedBox(height: 8),
              _actionBtn(
                icon: Icons.cancel_rounded,
                label: 'Dismiss Complaint',
                color: AppTheme.dismissedColor,
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus('dismissed');
                },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showStrikeConfirm() {
    final newCount = _complaint.strikeCount + 1;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded,
                color: AppTheme.flaggedColor),
            const SizedBox(width: 8),
            Text(
              newCount >= 3
                  ? 'Issue Strike & BAN User'
                  : 'Issue Strike',
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to issue a strike to '
              '${_complaint.reportedUserName}.',
              style: const TextStyle(
                  color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: newCount >= 3
                    ? AppTheme.bannedColor
                        .withValues(alpha: 0.1)
                    : AppTheme.flaggedColor
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: newCount >= 3
                      ? AppTheme.bannedColor
                          .withValues(alpha: 0.5)
                      : AppTheme.flaggedColor
                          .withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  StrikeBadge(strikes: newCount),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      newCount >= 3
                          ? '⚠️ This is the 3rd strike. '
                            'The user will be BANNED.'
                          : 'Strike $newCount of 3. '
                            '${3 - newCount} more until ban.',
                      style: TextStyle(
                        color: newCount >= 3
                            ? AppTheme.bannedColor
                            : AppTheme.flaggedColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(
                    color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus('resolved', issueStrike: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newCount >= 3
                  ? AppTheme.bannedColor
                  : AppTheme.flaggedColor,
            ),
            child: Text(newCount >= 3
                ? 'Confirm & BAN'
                : 'Issue Strike'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      loading: _updating,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Complaint #${_complaint.id}'),
          actions: [
            if (widget.isAdmin &&
                _complaint.status != 'resolved' &&
                _complaint.status != 'dismissed')
              IconButton(
                icon: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: AppTheme.accentPurple),
                onPressed: _showActionSheet,
                tooltip: 'Admin Actions',
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                StatusBadge(status: _complaint.status),
                const Spacer(),
                Text(_complaint.formattedDate,
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),
            _sectionCard('Violation Details', [
              _detailRow(
                  '${ViolationType.getIcon(_complaint.violationType)}  Type',
                  ViolationType.getLabel(
                      _complaint.violationType)),
              _detailRow('📋  Description',
                  _complaint.description),
            ]),
            const SizedBox(height: 16),
            _sectionCard('Parties Involved', [
              _detailRow('👤  Reported by',
                  _complaint.reporterName),
              _detailRow('🎯  Reported user',
                  _complaint.reportedUserName),
            ]),
            const SizedBox(height: 16),
            if (widget.isAdmin) ...[
              _sectionCard('Strike & Status', [
                Row(
                  children: [
                    const Text('Strikes: ',
                        style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13)),
                    StrikeBadge(
                        strikes: _complaint.strikeCount),
                    const SizedBox(width: 8),
                    Text(
                      _complaint.isBanned
                          ? '— ACCOUNT BANNED'
                          : '— ${3 - _complaint.strikeCount} remaining',
                      style: TextStyle(
                        color: _complaint.isBanned
                            ? AppTheme.bannedColor
                            : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 16),
            ],
            if (_complaint.adminNote != null)
              _sectionCard('Admin Note', [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 16,
                        color: AppTheme.reviewingColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _complaint.adminNote!,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
                if (_complaint
                    .formattedUpdatedDate.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Updated: '
                      '${_complaint.formattedUpdatedDate}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11),
                    ),
                  ),
              ]),
            if (widget.isAdmin &&
                _complaint.status != 'resolved' &&
                _complaint.status != 'dismissed') ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showActionSheet,
                icon: const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 18),
                label: const Text('Take Action'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(title,
                style: const TextStyle(
                    color: AppTheme.accentPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)),
          ),
          const Divider(
              height: 1, color: AppTheme.dividerColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14)),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    String? subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: color),
          ],
        ),
      ),
    );
  }
}