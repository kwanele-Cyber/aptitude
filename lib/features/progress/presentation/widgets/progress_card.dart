import 'package:flutter/material.dart';
import 'package:myapp/features/progress/domain/entity/skill_progress_entity.dart';

class ProgressCard extends StatelessWidget {
  final SkillProgressEntity progress;
  final VoidCallback? onShare;

  const ProgressCard({
    super.key,
    required this.progress,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final level = progress.level;
    final progressToNext = progress.xpPoints % 1000;
    final nextThreshold = level >= 10 ? 1.0 : progressToNext / 1000.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.primary.withOpacity(0.12),
                  child: Text(
                    'Lv.$level',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress.skillTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${progress.xpPoints} XP',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (progress.milestones.isNotEmpty && onShare != null)
                  IconButton(
                    icon: const Icon(Icons.share, size: 20),
                    onPressed: onShare,
                    tooltip: 'Share achievement',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: nextThreshold.clamp(0.0, 1.0),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatChip(
                    icon: Icons.timer,
                    label: '${progress.hoursLogged.toStringAsFixed(1)}h'),
                const SizedBox(width: 12),
                _StatChip(
                    icon: Icons.check_circle_outline,
                    label: '${progress.sessionsCompleted} sessions'),
                const SizedBox(width: 12),
                _StatChip(
                    icon: Icons.local_fire_department,
                    label: '${progress.currentStreak} day streak'),
              ],
            ),
            if (progress.milestones.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: progress.milestones
                    .where((m) => !m.startsWith('[Shared]'))
                    .map((m) => Chip(
                          label: Text(m, style: const TextStyle(fontSize: 11)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
