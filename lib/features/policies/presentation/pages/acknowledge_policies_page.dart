import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/policies/presentation/bloc/policies_bloc.dart';
import 'package:myapp/features/policies/presentation/bloc/policies_event.dart';
import 'package:myapp/features/policies/presentation/bloc/policies_state.dart';

class AcknowledgePoliciesPage extends StatefulWidget {
  final String userId;
  const AcknowledgePoliciesPage({super.key, required this.userId});

  @override
  State<AcknowledgePoliciesPage> createState() =>
      _AcknowledgePoliciesPageState();
}

class _AcknowledgePoliciesPageState extends State<AcknowledgePoliciesPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<PoliciesBloc>()
        .add(GetPendingPoliciesRequested(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acknowledge Policies'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<PoliciesBloc, PoliciesState>(
        listener: (context, state) {
          if (state is PoliciesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PoliciesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PoliciesError && state is! PoliciesLoaded) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        context.read<PoliciesBloc>().add(
                              GetPendingPoliciesRequested(
                                  userId: widget.userId),
                            );
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is PoliciesLoaded) {
            final policies = state.pendingPolicies;
            if (policies.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 80,
                          color: Colors.green.shade400),
                      const SizedBox(height: 24),
                      Text(
                        'All Policies Acknowledged',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You\'re up to date with all platform policies.',
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

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: theme.colorScheme.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${policies.length} polic${policies.length == 1 ? 'y' : 'ies'} need${policies.length == 1 ? 's' : ''} your acknowledgment',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Pending Policies',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...policies.map(
                  (policy) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _PolicyCard(
                      title: policy.title,
                      content: policy.content,
                      version: policy.version,
                      publishedAt: policy.publishedAt,
                      isAcknowledging: state.acknowledgingIds
                          .contains(policy.id),
                      onAcknowledge: () {
                        context.read<PoliciesBloc>().add(
                              AcknowledgePolicyRequested(
                                userId: widget.userId,
                                policyId: policy.id,
                                version: policy.version,
                              ),
                            );
                      },
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final String title;
  final String content;
  final String version;
  final DateTime publishedAt;
  final bool isAcknowledging;
  final VoidCallback onAcknowledge;

  const _PolicyCard({
    required this.title,
    required this.content,
    required this.version,
    required this.publishedAt,
    required this.isAcknowledging,
    required this.onAcknowledge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description_outlined,
                    color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Version $version • ${_formatDate(publishedAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                content,
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isAcknowledging ? null : onAcknowledge,
                icon: isAcknowledging
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline, size: 20),
                label: Text(
                    isAcknowledging ? 'Acknowledging...' : 'Acknowledge'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
