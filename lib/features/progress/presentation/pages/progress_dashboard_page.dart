import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/progress/presentation/bloc/progress_bloc.dart';
import 'package:myapp/features/progress/presentation/bloc/progress_event.dart';
import 'package:myapp/features/progress/presentation/bloc/progress_state.dart';
import 'package:myapp/features/progress/presentation/widgets/goal_card.dart';
import 'package:myapp/features/progress/presentation/widgets/progress_card.dart';

class ProgressDashboardPage extends StatefulWidget {
  const ProgressDashboardPage({super.key});

  @override
  State<ProgressDashboardPage> createState() => _ProgressDashboardPageState();
}

class _ProgressDashboardPageState extends State<ProgressDashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final uid = authState.userEntity.id;
      context.read<ProgressBloc>().add(FetchProgressRequested(userId: uid));
      context.read<ProgressBloc>().add(FetchGoalsRequested(userId: uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Set a goal',
            onPressed: () => context.push('/progress/goals/new'),
          ),
        ],
      ),
      body: BlocConsumer<ProgressBloc, ProgressState>(
        listener: (context, state) {
          if (state is ProgressTracked ||
              state is GoalSet ||
              state is GoalProgressUpdated ||
              state is AchievementShared) {
            _loadData();
          }
        },
        builder: (context, state) {
          if (state is ProgressLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state is ProgressError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      state.message,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),

                // --- Goals Section ---
                Text(
                  'Learning Goals',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                if (state is GoalsLoaded && state.goals.isEmpty)
                  _EmptyState(
                    icon: Icons.flag_outlined,
                    message: 'No goals yet. Set a learning goal to track your progress!',
                    actionLabel: 'Set Goal',
                    onAction: () => context.push('/progress/goals/new'),
                  ),
                if (state is GoalsLoaded)
                  ...state.goals.map(
                    (goal) => GoalCard(goal: goal),
                  ),
                if (state is! GoalsLoaded && state is! ProgressError)
                  const _ShimmerCard(),

                const SizedBox(height: 24),

                // --- Progress Section ---
                Text(
                  'Skill Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),

                if (state is ProgressLoaded && state.progressList.isEmpty)
                  const _EmptyState(
                    icon: Icons.trending_up,
                    message: 'Complete sessions to start tracking your progress!',
                  ),
                if (state is ProgressLoaded)
                  ...state.progressList.map(
                    (progress) => ProgressCard(
                      progress: progress,
                      onShare: () {
                        context.read<ProgressBloc>().add(
                              ShareAchievementRequested(
                                progressId: progress.id,
                                milestone: '${progress.skillTitle} - Level ${progress.level}',
                              ),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Achievement shared!')),
                        );
                      },
                    ),
                  ),
                if (state is! ProgressLoaded && state is! ProgressError)
                  const _ShimmerCard(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}
