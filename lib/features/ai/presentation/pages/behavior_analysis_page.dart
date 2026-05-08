import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/ai/domain/entities/behavior_flag_entity.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_bloc.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_event.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_state.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';

class BehaviorAnalysisPage extends StatefulWidget {
  const BehaviorAnalysisPage({super.key});

  @override
  State<BehaviorAnalysisPage> createState() => _BehaviorAnalysisPageState();
}

class _BehaviorAnalysisPageState extends State<BehaviorAnalysisPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context
          .read<AiBloc>()
          .add(AnalyzeUserBehavior(userId: authState.userEntity.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Behavior Analysis'),
        centerTitle: true,
      ),
      body: BlocBuilder<AiBloc, AiState>(
        builder: (context, state) {
          if (state is AiLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AiError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 56, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthAuthenticated) {
                          context.read<AiBloc>().add(AnalyzeUserBehavior(
                              userId: authState.userEntity.id));
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is BehaviorAnalysisLoaded) {
            final flags = state.flags;
            if (flags.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield,
                          size: 72,
                          color: const Color(0xFF2E7D32)),
                      const SizedBox(height: 16),
                      Text(
                        'All Clear',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No unusual behavior detected on your account.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: flags.length,
              itemBuilder: (context, index) {
                final flag = flags[index];
                return _FlagCard(flag: flag);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _FlagCard extends StatelessWidget {
  final BehaviorFlagEntity flag;

  const _FlagCard({required this.flag});

  Color _severityColor(FlagSeverity severity) {
    switch (severity) {
      case FlagSeverity.low:
        return Colors.grey;
      case FlagSeverity.medium:
        return Colors.orange;
      case FlagSeverity.high:
        return Colors.deepOrange;
      case FlagSeverity.critical:
        return Colors.red;
    }
  }

  IconData _flagIcon(FlagType type) {
    switch (type) {
      case FlagType.unusualLoginLocation:
        return Icons.location_on;
      case FlagType.rapidMessageSpam:
        return Icons.speed;
      case FlagType.suspiciousMatchPattern:
        return Icons.people_outline;
      case FlagType.fakeReviewActivity:
        return Icons.rate_review;
      case FlagType.accountTakeoverAttempt:
        return Icons.security;
      case FlagType.policyViolation:
        return Icons.gavel;
    }
  }

  String _flagLabel(FlagType type) {
    switch (type) {
      case FlagType.unusualLoginLocation:
        return 'Unusual Login Location';
      case FlagType.rapidMessageSpam:
        return 'Rapid Message Activity';
      case FlagType.suspiciousMatchPattern:
        return 'Suspicious Match Pattern';
      case FlagType.fakeReviewActivity:
        return 'Fake Review Activity';
      case FlagType.accountTakeoverAttempt:
        return 'Account Takeover Attempt';
      case FlagType.policyViolation:
        return 'Policy Violation';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityColor = _severityColor(flag.severity);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: severityColor.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _flagIcon(flag.type),
                color: severityColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _flagLabel(flag.type),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: severityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          flag.severity.name.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: severityColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    flag.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTimestamp(flag.timestamp),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
