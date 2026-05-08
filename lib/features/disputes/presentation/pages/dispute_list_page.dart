import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/disputes/domain/entities/dispute_entity.dart';
import 'package:myapp/features/disputes/presentation/bloc/dispute_bloc.dart';
import 'package:myapp/features/disputes/presentation/bloc/dispute_event.dart';
import 'package:myapp/features/disputes/presentation/bloc/dispute_state.dart';
import 'package:myapp/features/disputes/presentation/pages/dispute_detail_page.dart';

class DisputeListPage extends StatefulWidget {
  final bool adminView;

  const DisputeListPage({super.key, this.adminView = false});

  @override
  State<DisputeListPage> createState() => _DisputeListPageState();
}

class _DisputeListPageState extends State<DisputeListPage> {
  @override
  void initState() {
    super.initState();
    _loadDisputes();
  }

  void _loadDisputes() {
    if (widget.adminView) {
      context.read<DisputeBloc>().add(FetchAllDisputesRequested());
    } else {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<DisputeBloc>().add(
              FetchDisputesRequested(userId: authState.userEntity.id),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.adminView ? 'All Disputes' : 'My Reports & Disputes'),
      ),
      body: BlocBuilder<DisputeBloc, DisputeState>(
        builder: (context, state) {
          if (state is DisputeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DisputesLoaded) {
            final disputes = state.disputes;

            if (disputes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 64, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      widget.adminView
                          ? 'No disputes to review'
                          : 'No reports or disputes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadDisputes(),
              child: ListView.builder(
                itemCount: disputes.length,
                itemBuilder: (context, index) {
                  final dispute = disputes[index];
                  return _DisputeCard(
                    dispute: dispute,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DisputeDetailPage(
                            disputeId: dispute.id,
                            adminView: widget.adminView,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          if (state is DisputeError) {
            return Center(child: Text(state.message));
          }

          return const Center(child: Text('No disputes'));
        },
      ),
    );
  }
}

class _DisputeCard extends StatelessWidget {
  final DisputeEntity dispute;
  final VoidCallback onTap;

  const _DisputeCard({
    required this.dispute,
    required this.onTap,
  });

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

  IconData _typeIcon(DisputeType type) {
    switch (type) {
      case DisputeType.report:
        return Icons.flag;
      case DisputeType.dispute:
        return Icons.warning_amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(dispute.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.15),
          child: Icon(_typeIcon(dispute.type), color: statusColor, size: 20),
        ),
        title: Text(
          dispute.reason,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${dispute.type == DisputeType.report ? "Reported" : "Filed"}: ${_formatDate(dispute.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Chip(
          label: Text(
            dispute.status.name.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: statusColor.withValues(alpha: 0.1),
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
