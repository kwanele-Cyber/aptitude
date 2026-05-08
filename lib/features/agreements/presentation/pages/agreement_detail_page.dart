import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/agreements/domain/entities/agreement_entity.dart';
import 'package:myapp/features/agreements/presentation/bloc/agreement_bloc.dart';
import 'package:myapp/features/agreements/presentation/bloc/agreement_event.dart';
import 'package:myapp/features/agreements/presentation/bloc/agreement_state.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';

class AgreementDetailPage extends StatefulWidget {
  final String agreementId;

  const AgreementDetailPage({super.key, required this.agreementId});

  @override
  State<AgreementDetailPage> createState() => _AgreementDetailPageState();
}

class _AgreementDetailPageState extends State<AgreementDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<AgreementBloc>().add(
          FetchAgreementByIdRequested(agreementId: widget.agreementId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agreement Details'),
      ),
      body: BlocConsumer<AgreementBloc, AgreementState>(
        listener: (context, state) {
          if (state is AgreementActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<AgreementBloc>().add(
                  FetchAgreementByIdRequested(
                      agreementId: widget.agreementId),
                );
          }
        },
        builder: (context, state) {
          if (state is AgreementLoading && state is! AgreementDetailLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AgreementDetailLoaded) {
            return _AgreementDetailContent(
              agreement: state.agreement,
              onAccept: () => _acceptAgreement(state.agreement),
              onModify: () => _modifyAgreement(context, state.agreement),
              onCancel: () => _cancelAgreement(state.agreement),
            );
          }

          if (state is AgreementError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AgreementBloc>().add(
                            FetchAgreementByIdRequested(
                                agreementId: widget.agreementId),
                          );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _acceptAgreement(AgreementEntity agreement) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accept Agreement'),
        content: const Text(
            'Confirm the terms and proceed with this agreement?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AgreementBloc>().add(
                    AcceptAgreementRequested(
                      agreementId: agreement.id,
                      userId: authState.userEntity.id,
                    ),
                  );
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _cancelAgreement(AgreementEntity agreement) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Agreement'),
        content: const Text(
            'Are you sure you want to cancel this agreement?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('No'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AgreementBloc>().add(
                    CancelAgreementRequested(
                      agreementId: agreement.id,
                      userId: authState.userEntity.id,
                    ),
                  );
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _modifyAgreement(BuildContext context, AgreementEntity agreement) {
    final durationController =
        TextEditingController(text: agreement.duration);
    final frequencyController =
        TextEditingController(text: agreement.frequency);
    final sessionsController =
        TextEditingController(text: agreement.sessionsCount.toString());
    final notesController = TextEditingController(text: agreement.notes ?? '');
    final authState = this.context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modify Agreement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration',
                  hintText: 'e.g., 4 weeks, 2 months',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: frequencyController,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  hintText: 'e.g., 1x/week, 2x/week',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sessionsController,
                decoration: const InputDecoration(
                  labelText: 'Number of Sessions',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final sessions =
                  int.tryParse(sessionsController.text) ?? 1;
              Navigator.of(ctx).pop();
              this.context.read<AgreementBloc>().add(
                    ModifyAgreementRequested(
                      agreementId: agreement.id,
                      userId: authState.userEntity.id,
                      duration: durationController.text,
                      frequency: frequencyController.text,
                      sessionsCount: sessions,
                      notes: notesController.text.isNotEmpty
                          ? notesController.text
                          : null,
                    ),
                  );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}

class _AgreementDetailContent extends StatelessWidget {
  final AgreementEntity agreement;
  final VoidCallback onAccept;
  final VoidCallback onModify;
  final VoidCallback onCancel;

  const _AgreementDetailContent({
    required this.agreement,
    required this.onAccept,
    required this.onModify,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.read<AuthBloc>().state;
    final isInitiator = authState is AuthAuthenticated &&
        authState.userEntity.id == agreement.initiatorId;
    final partnerName =
        isInitiator ? agreement.partnerName : agreement.initiatorName;
    final partnerSkill = isInitiator
        ? agreement.partnerSkillTitle
        : agreement.initiatorSkillTitle;
    final mySkill = isInitiator
        ? agreement.initiatorSkillTitle
        : agreement.partnerSkillTitle;
    final canAct = agreement.status == AgreementStatus.pending ||
        agreement.status == AgreementStatus.modified;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _statusColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _statusColor().withValues(alpha:0.3)),
              ),
              child: Text(
                agreement.status.name.toUpperCase(),
                style: TextStyle(
                  color: _statusColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Skill exchange
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Text(mySkill.isNotEmpty
                                  ? mySkill[0]
                                  : '?'),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              mySkill,
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.swap_horiz, size: 32),
                      Expanded(
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.tertiaryContainer,
                              child: Text(partnerSkill.isNotEmpty
                                  ? partnerSkill[0]
                                  : '?'),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              partnerName,
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              partnerSkill,
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Terms
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Terms',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  _TermRow(
                      Icons.schedule,
                      'Duration',
                      agreement.duration),
                  const SizedBox(height: 8),
                  _TermRow(
                      Icons.repeat,
                      'Frequency',
                      agreement.frequency),
                  const SizedBox(height: 8),
                  _TermRow(
                      Icons.numbers,
                      'Sessions',
                      '${agreement.sessionsCount}'),
                  if (agreement.notes != null &&
                      agreement.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _TermRow(
                        Icons.notes,
                        'Notes',
                        agreement.notes!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Timeline
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Timeline',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  _TimelineItem(
                    'Created',
                    _formatDate(agreement.createdAt),
                    Icons.add_circle_outline,
                  ),
                  if (agreement.status == AgreementStatus.accepted ||
                      agreement.status == AgreementStatus.modified)
                    _TimelineItem(
                      'Accepted',
                      _formatDate(agreement.updatedAt),
                      Icons.check_circle_outline,
                    ),
                  if (agreement.status == AgreementStatus.modified)
                    _TimelineItem(
                      'Modified',
                      _formatDate(agreement.updatedAt),
                      Icons.edit,
                    ),
                  if (agreement.status == AgreementStatus.cancelled &&
                      agreement.cancelledAt != null)
                    _TimelineItem(
                      'Cancelled by ${agreement.cancelledBy == agreement.initiatorId ? agreement.initiatorName : agreement.partnerName}',
                      _formatDate(agreement.cancelledAt!),
                      Icons.cancel_outlined,
                      color: Colors.red,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          if (canAct) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAccept,
                icon: const Icon(Icons.check),
                label: const Text('Accept Agreement'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onModify,
                icon: const Icon(Icons.edit),
                label: const Text('Modify Terms'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
          if (agreement.status == AgreementStatus.accepted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final currentUserId = authState is AuthAuthenticated
                      ? authState.userEntity.id
                      : '';
                  final mySkillId = isInitiator
                      ? agreement.initiatorSkillId
                      : agreement.partnerSkillId;
                  final mySkillTitle = isInitiator
                      ? agreement.initiatorSkillTitle
                      : agreement.partnerSkillTitle;
                  final otherUserId = isInitiator
                      ? agreement.partnerId
                      : agreement.initiatorId;
                  context.push('/sessions/create', extra: {
                    'matchId': '',
                    'skillId': mySkillId,
                    'skillTitle': mySkillTitle,
                    'initiatorId': currentUserId,
                    'participantId': otherUserId,
                    'participantName': partnerName,
                  });
                },
                icon: const Icon(Icons.event),
                label: const Text('Schedule Session'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
          if (agreement.status != AgreementStatus.cancelled &&
              agreement.status != AgreementStatus.completed) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Agreement'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final respondentId = isInitiator
                    ? agreement.partnerId
                    : agreement.initiatorId;
                final respondentName = isInitiator
                    ? agreement.partnerName
                    : agreement.initiatorName;
                context.push('/disputes/create', extra: {
                  'respondentId': respondentId,
                  'respondentName': respondentName,
                  'agreementId': agreement.id,
                });
              },
              icon: const Icon(Icons.warning_amber_outlined),
              label: const Text('Create Dispute'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor() {
    return switch (agreement.status) {
      AgreementStatus.pending => Colors.orange,
      AgreementStatus.accepted => Colors.green,
      AgreementStatus.modified => Colors.blue,
      AgreementStatus.cancelled => Colors.red,
      AgreementStatus.completed => Colors.green,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _TermRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TermRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(color: Colors.grey)),
        Expanded(child: Text(value)),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  final Color? color;

  const _TimelineItem(
    this.title,
    this.date,
    this.icon, {
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w500)),
          ),
          Text(date, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
