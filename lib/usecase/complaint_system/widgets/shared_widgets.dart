import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/complaint.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool small;
  const StatusBadge(
      {super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusColor(status);
    final icon = AppTheme.statusIcon(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: small ? 10 : 13, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: small ? 9 : 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class StrikeBadge extends StatelessWidget {
  final int strikes;
  const StrikeBadge({super.key, required this.strikes});

  @override
  Widget build(BuildContext context) {
    final isBanned = strikes >= 3;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < strikes;
        return Padding(
          padding: const EdgeInsets.only(right: 3),
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled
                  ? (isBanned
                      ? AppTheme.bannedColor
                      : AppTheme.flaggedColor)
                  : AppTheme.bgCardLight,
              border: Border.all(
                color: filled
                    ? (isBanned
                        ? AppTheme.bannedColor
                        : AppTheme.flaggedColor)
                    : AppTheme.dividerColor,
              ),
            ),
            child: filled
                ? Icon(
                    isBanned && i == 2
                        ? Icons.block
                        : Icons.flag,
                    size: 10,
                    color: Colors.white,
                  )
                : null,
          ),
        );
      }),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool loading;
  final Widget child;
  const LoadingOverlay(
      {super.key,
      required this.loading,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (loading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.lightPurple),
            ),
          ),
      ],
    );
  }
}

class ComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final bool isAdmin;
  final VoidCallback? onTap;

  const ComplaintCard({
    super.key,
    required this.complaint,
    this.isAdmin = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ViolationType.getIcon(
                          complaint.violationType),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          ViolationType.getLabel(
                              complaint.violationType),
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          complaint.formattedDate,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: complaint.status),
                ],
              ),
            ),
            const Divider(
                height: 1, color: AppTheme.dividerColor),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(
                    isAdmin ? 'Reported by' : 'Against',
                    isAdmin
                        ? complaint.reporterName
                        : complaint.reportedUserName,
                    Icons.person_rounded,
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 8),
                    _infoRow('Against',
                        complaint.reportedUserName,
                        Icons.gavel_rounded),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        const Text('Strikes: ',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12)),
                        StrikeBadge(
                            strikes: complaint.strikeCount),
                        if (complaint.isBanned) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.bannedColor
                                  .withValues(alpha: 0.2),
                              borderRadius:
                                  BorderRadius.circular(6),
                              border: Border.all(
                                  color:
                                      AppTheme.bannedColor),
                            ),
                            child: const Text('BANNED',
                                style: TextStyle(
                                    color:
                                        AppTheme.bannedColor,
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.w800)),
                          ),
                        ],
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    complaint.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13),
                  ),
                  if (complaint.adminNote != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.reviewingColor
                            .withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.reviewingColor
                                .withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Icon(
                              Icons
                                  .admin_panel_settings_rounded,
                              size: 14,
                              color: AppTheme.reviewingColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              complaint.adminNote!,
                              style: const TextStyle(
                                  color:
                                      AppTheme.reviewingColor,
                                  fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
      String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 6),
        Text('$label: ',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12)),
        Text(value,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}