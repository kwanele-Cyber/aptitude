import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/disputes/domain/entities/dispute_entity.dart';
import 'package:myapp/features/disputes/presentation/bloc/dispute_bloc.dart';
import 'package:myapp/features/disputes/presentation/bloc/dispute_event.dart';
import 'package:myapp/features/disputes/presentation/bloc/dispute_state.dart';

class DisputeDetailPage extends StatefulWidget {
  final String disputeId;
  final bool adminView;

  const DisputeDetailPage({
    super.key,
    required this.disputeId,
    this.adminView = false,
  });

  @override
  State<DisputeDetailPage> createState() => _DisputeDetailPageState();
}

class _DisputeDetailPageState extends State<DisputeDetailPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<DisputeBloc>()
        .add(FetchDisputeByIdRequested(disputeId: widget.disputeId));
  }

  Color _statusColor(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.pending:
      case DisputeStatus.underReview:
        return Colors.orange;
      case DisputeStatus.resolved:
        return Colors.green;
      case DisputeStatus.dismissed:
        return Colors.red;
      case DisputeStatus.appealed:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispute Details'),
      ),
      body: BlocConsumer<DisputeBloc, DisputeState>(
        listener: (context, state) {
          if (state is DisputeResolved || state is DisputeAppealed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state is DisputeResolved
                    ? 'Dispute resolved'
                    : 'Appeal submitted'),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DisputeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DisputeDetailLoaded) {
            return _buildDetail(context, state.dispute);
          }

          if (state is DisputeError) {
            return Center(child: Text(state.message));
          }

          return const Center(child: Text('No details'));
        },
      ),
    );
  }

  Widget _buildDetail(BuildContext context, DisputeEntity dispute) {
    final statusColor = _statusColor(dispute.status);
    final authState = context.read<AuthBloc>().state;
    final isAdmin = authState is AuthAuthenticated && authState.userEntity.isAdmin;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Center(
            child: Chip(
              label: Text(
                dispute.status.name.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: statusColor.withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(height: 16),

          // Type and reason
          _infoRow('Type', dispute.type.name.toUpperCase()),
          _infoRow('Reason', dispute.reason),
          if (dispute.reportedUserName != null)
            _infoRow('Reported User', dispute.reportedUserName!),
          if (dispute.respondentId != null)
            _infoRow('Respondent ID', dispute.respondentId!),
          if (dispute.agreementId != null)
            _infoRow('Agreement ID', dispute.agreementId!),
          if (dispute.sessionId != null)
            _infoRow('Session ID', dispute.sessionId!),
          _infoRow('Filed', _formatDate(dispute.createdAt)),

          const Divider(height: 32),

          // Description
          Text('Description',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(dispute.description),
          if (dispute.evidenceUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Evidence',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...dispute.evidenceUrls.map(
              (url) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: InkWell(
                  onTap: () {},
                  child: Text(url,
                      style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline)),
                ),
              ),
            ),
          ],

          const Divider(height: 32),

          // Resolution section
          if (dispute.resolution != null) ...[
            Text('Resolution',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(dispute.resolution!),
            if (dispute.resolvedBy != null)
              _infoRow('Resolved by', dispute.resolvedBy!),
            if (dispute.resolvedAt != null)
              _infoRow('Resolved at', _formatDate(dispute.resolvedAt!)),
            const Divider(height: 32),
          ],

          // Appeal section
          if (dispute.appealReason != null) ...[
            Text('Appeal', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(dispute.appealReason!),
            if (dispute.appealDecision != null) ...[
              const SizedBox(height: 8),
              Text('Appeal Decision: ${dispute.appealDecision!}'),
            ],
            if (dispute.appealDecisionAt != null)
              _infoRow('Appeal decided', _formatDate(dispute.appealDecisionAt!)),
            const Divider(height: 32),
          ],

          // Action buttons
          if (widget.adminView && isAdmin &&
              dispute.status == DisputeStatus.pending)
            _AdminActions(dispute: dispute),

          if (!widget.adminView && dispute.canAppeal)
            _AppealAction(dispute: dispute),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _AdminActions extends StatelessWidget {
  final DisputeEntity dispute;

  const _AdminActions({required this.dispute});

  void _resolve(BuildContext context, String status) {
    final controller = TextEditingController();
    final authState = context.read<AuthBloc>().state;
    final adminName =
        authState is AuthAuthenticated ? authState.userEntity.name : 'Admin';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${status == 'resolved' ? "Resolve" : "Dismiss"} Dispute'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Resolution notes',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<DisputeBloc>().add(
                    ResolveDisputeRequested(
                      disputeId: dispute.id,
                      resolution: controller.text.trim(),
                      resolvedBy: adminName,
                      newStatus: status,
                    ),
                  );
              Navigator.of(ctx).pop();
            },
            child: Text(status == 'resolved' ? 'Resolve' : 'Dismiss'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => _resolve(context, 'resolved'),
          icon: const Icon(Icons.check_circle),
          label: const Text('Resolve'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _resolve(context, 'dismissed'),
          icon: const Icon(Icons.cancel),
          label: const Text('Dismiss'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
        ),
      ],
    );
  }
}

class _AppealAction extends StatelessWidget {
  final DisputeEntity dispute;

  const _AppealAction({required this.dispute});

  void _appeal(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Appeal Decision'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Reason for appeal',
            hintText: 'Explain why you disagree with the decision...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<DisputeBloc>().add(
                    AppealDecisionRequested(
                      disputeId: dispute.id,
                      appealReason: controller.text.trim(),
                    ),
                  );
              Navigator.of(ctx).pop();
            },
            child: const Text('Submit Appeal'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        Text(
          'Want to appeal this decision?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => _appeal(context),
          icon: const Icon(Icons.replay),
          label: const Text('Appeal Decision'),
        ),
      ],
    );
  }
}
