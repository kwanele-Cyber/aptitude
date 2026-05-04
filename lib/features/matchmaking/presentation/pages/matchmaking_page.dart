import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/matchmaking/presentation/bloc/match_bloc.dart';
import 'package:myapp/features/matchmaking/presentation/bloc/match_event.dart';
import 'package:myapp/features/matchmaking/presentation/bloc/match_state.dart';

class MatchmakingPage extends StatefulWidget {
  const MatchmakingPage({super.key});

  @override
  State<MatchmakingPage> createState() => _MatchmakingPageState();
}

class _MatchmakingPageState extends State<MatchmakingPage> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _userId = authState.userEntity.id;
      context
          .read<MatchBloc>()
          .add(FetchMatchesRequested(userId: authState.userEntity.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover Matches')),
      body: BlocBuilder<MatchBloc, MatchState>(
        builder: (context, state) {
          if (state is MatchLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MatchesLoaded) {
            final matches = state.matches;
            if (matches.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No matches found yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create more skill listings to get matches',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_userId != null) {
                          context
                              .read<MatchBloc>()
                              .add(FetchMatchesRequested(userId: _userId!));
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }
            return _MatchCardStack(
              matches: matches,
              onAccept: (matchId) {
                context
                    .read<MatchBloc>()
                    .add(AcceptMatchRequested(matchId: matchId));
              },
              onReject: (matchId) {
                context
                    .read<MatchBloc>()
                    .add(RejectMatchRequested(matchId: matchId));
              },
              onIgnore: (matchId) {
                context
                    .read<MatchBloc>()
                    .add(IgnoreMatchRequested(matchId: matchId));
              },
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
                      if (_userId != null) {
                        context
                            .read<MatchBloc>()
                            .add(FetchMatchesRequested(userId: _userId!));
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Ready to find matches'));
        },
      ),
    );
  }
}

class _MatchCardStack extends StatelessWidget {
  final List<dynamic> matches;
  final ValueChanged<String> onAccept;
  final ValueChanged<String> onReject;
  final ValueChanged<String> onIgnore;

  const _MatchCardStack({
    required this.matches,
    required this.onAccept,
    required this.onReject,
    required this.onIgnore,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                            match.targetSkillTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Match Score: ${match.score.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: _scoreColor(match.score),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (match.targetIsVerified)
                      const Icon(Icons.verified,
                          size: 18, color: Colors.green),
                  ],
                ),
                const SizedBox(height: 12),
                Text(match.targetSkillCategory,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text('${match.targetSkillLevel.name} · ${match.targetSkillFormat.name}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      icon: Icons.close,
                      color: Colors.red,
                      onTap: () => onReject(match.id),
                    ),
                    _ActionButton(
                      icon: Icons.remove_red_eye,
                      color: Colors.orange,
                      onTap: () => onIgnore(match.id),
                    ),
                    _ActionButton(
                      icon: Icons.check,
                      color: Colors.green,
                      onTap: () => onAccept(match.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _scoreColor(double score) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.grey;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}
