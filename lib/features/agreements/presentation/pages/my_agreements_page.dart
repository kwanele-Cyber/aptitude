import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/agreements/domain/entities/agreement_entity.dart';
import 'package:myapp/features/agreements/presentation/bloc/agreement_bloc.dart';
import 'package:myapp/features/agreements/presentation/bloc/agreement_event.dart';
import 'package:myapp/features/agreements/presentation/bloc/agreement_state.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';

class MyAgreementsPage extends StatefulWidget {
  const MyAgreementsPage({super.key});

  @override
  State<MyAgreementsPage> createState() => _MyAgreementsPageState();
}

class _MyAgreementsPageState extends State<MyAgreementsPage> {
  AgreementStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _fetchAgreements();
  }

  void _fetchAgreements() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context
          .read<AgreementBloc>()
          .add(FetchAgreementsRequested(userId: authState.userEntity.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Agreements'),
        actions: [
          PopupMenuButton<AgreementStatus?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              setState(() => _statusFilter = filter);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All')),
              ...AgreementStatus.values.map(
                (status) => PopupMenuItem(
                  value: status,
                  child: Text(status.name.toUpperCase()),
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<AgreementBloc, AgreementState>(
        builder: (context, state) {
          if (state is AgreementLoading && state is! AgreementsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AgreementsLoaded) {
            final agreements = _statusFilter != null
                ? state.agreements
                    .where((a) => a.status == _statusFilter)
                    .toList()
                : state.agreements;

            if (agreements.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.handshake_outlined,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      _statusFilter != null
                          ? 'No ${_statusFilter!.name} agreements'
                          : 'No agreements yet',
                      style:
                          const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create an agreement to formalize your skill exchanges',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/agreements/create'),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Agreement'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _fetchAgreements();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: agreements.length,
                itemBuilder: (context, index) =>
                    _AgreementCard(agreement: agreements[index]),
              ),
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
                    onPressed: _fetchAgreements,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'create_agreement',
        onPressed: () => context.push('/agreements/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AgreementCard extends StatelessWidget {
  final AgreementEntity agreement;

  const _AgreementCard({required this.agreement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.read<AuthBloc>().state;
    final isInitiator = authState is AuthAuthenticated &&
        authState.userEntity.id == agreement.initiatorId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/agreements/${agreement.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(
                      isInitiator
                          ? (agreement.partnerName.isNotEmpty
                              ? agreement.partnerName[0]
                              : '?')
                          : (agreement.initiatorName.isNotEmpty
                              ? agreement.initiatorName[0]
                              : '?'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isInitiator
                              ? agreement.partnerName
                              : agreement.initiatorName,
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          '${agreement.initiatorSkillTitle} ↔ ${agreement.partnerSkillTitle}',
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: agreement.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${agreement.frequency} · ${agreement.duration}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    '${agreement.sessionsCount} session${agreement.sessionsCount == 1 ? '' : 's'}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final AgreementStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = switch (status) {
      AgreementStatus.pending => (Colors.orange, Icons.schedule),
      AgreementStatus.accepted => (Colors.green, Icons.check_circle),
      AgreementStatus.modified => (Colors.blue, Icons.edit),
      AgreementStatus.cancelled => (Colors.red, Icons.cancel),
      AgreementStatus.completed => (Colors.green, Icons.check),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.name.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
