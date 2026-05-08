import 'package:flutter/material.dart';
import 'package:myapp/features/progress/domain/entity/learning_goal_entity.dart';

class GoalCard extends StatelessWidget {
  final LearningGoalEntity goal;
  final VoidCallback? onUpdateProgress;

  const GoalCard({
    super.key,
    required this.goal,
    this.onUpdateProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = goal.status == GoalStatus.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.flag_outlined,
                  size: 20,
                  color: isCompleted
                      ? Colors.green
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    goal.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(fontSize: 11, color: Colors.green),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              goal.skillTitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (goal.targetDate != null) ...[
              const SizedBox(height: 2),
              Text(
                'Target: ${goal.targetDate!.month}/${goal.targetDate!.day}/${goal.targetDate!.year}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: goal.progressPercent / 100.0,
                      minHeight: 6,
                      color:
                          isCompleted ? Colors.green : theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${goal.progressPercent}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
