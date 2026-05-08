import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/matchmaking/domain/entity/match_entity.dart';
import 'package:myapp/features/matchmaking/presentation/bloc/match_bloc.dart';
import 'package:myapp/features/matchmaking/presentation/bloc/match_event.dart';
import 'package:myapp/features/matchmaking/presentation/bloc/match_state.dart';

class MatchHistoryPage extends StatefulWidget {
  final String userId;

  const MatchHistoryPage({super.key, required this.userId});

  @override
  State<MatchHistoryPage> createState() => _MatchHistoryPageState();
}

class _MatchHistoryPageState extends State<MatchHistoryPage> {
  MatchStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    context
        .read<MatchBloc>()
        .add(FetchMatchHistoryRequested(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match History'),
        actions: [
          PopupMenuButton<MatchStatus?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              setState(() => _statusFilter = filter);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All')),
              ...MatchStatus.values.map(
                (status) => PopupMenuItem(
                  value: status,
                  child: Text(status.name.toUpperCase()),
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<MatchBloc, MatchState>(
        builder: (context, state) {
          if (state is MatchLoading && state is! MatchHistoryLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MatchHistoryLoaded) {
            final matches = _statusFilter != null
                ? state.matches
                    .where((m) => m.status == _statusFilter)
                    .toList()
                : state.matches;

            if (matches.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      _statusFilter != null
                          ? 'No ${_statusFilter!.name} matches'
                          : 'No match history yet',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<MatchBloc>()
                    .add(FetchMatchHistoryRequested(userId: widget.userId));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: matches.length,
                itemBuilder: (context, index) =>
                    _MatchHistoryCard(match: matches[index]),
              ),
            );
          }

          if (state is MatchError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<MatchBloc>()
                          .add(FetchMatchHistoryRequested(userId: widget.userId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('No match history'));
        },
      ),
    );
  }
}

class _MatchHistoryCard extends StatelessWidget {
  final MatchEntity match;

  const _MatchHistoryCard({required this.match});

  void _createAgreement(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    context.push('/agreements/create', extra: {
      'partnerId': match.targetUserId,
      'partnerName': match.targetUserName,
      'partnerSkillId': match.targetSkillId,
      'partnerSkillTitle': match.targetSkillTitle,
      'initiatorSkillId': match.matchedSkillId,
      'initiatorName':
          '${authState.userEntity.firstName} ${authState.userEntity.lastName}',
      'initiatorId': authState.userEntity.id,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/profile/${match.targetUserId}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    match.targetSkillTitle.isNotEmpty
                        ? match.targetSkillTitle[0]
                        : '?',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.targetUserName,
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        match.targetSkillTitle,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: match.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              match.targetSkillCategory,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              '${match.targetSkillLevel.name} · ${match.targetSkillFormat.name} · ${match.score.toStringAsFixed(0)}% match',
              style: theme.textTheme.bodySmall,
            ),
            if (match.status == MatchStatus.accepted) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _createAgreement(context),
                  icon: const Icon(Icons.handshake, size: 18),
                  label: const Text('Create Agreement'),
                ),
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final MatchStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = switch (status) {
      MatchStatus.accepted => (Colors.green, Icons.check),
      MatchStatus.rejected => (Colors.red, Icons.close),
      MatchStatus.ignored => (Colors.orange, Icons.remove_red_eye),
      MatchStatus.pending => (Colors.grey, Icons.schedule),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
