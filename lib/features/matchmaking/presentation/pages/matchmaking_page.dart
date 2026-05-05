import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  double _minScore = 0;
  double _minTrustScore = 0;
  double _maxDistance = double.infinity;
  bool _verifiedOnly = false;

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

  List<dynamic> _applyFilters(List<dynamic> matches) {
    return matches.where((m) {
      if (m.score < _minScore) return false;
      if (m.targetTrustScore < _minTrustScore) return false;
      if (_verifiedOnly && !m.targetIsVerified) return false;
      if (_maxDistance.isFinite &&
          m.distance != null &&
          m.distance > _maxDistance) return false;
      return true;
    }).toList();
  }

  Future<void> _showFilterDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Matches'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FilterSlider(
                  label: 'Min Match Score',
                  value: _minScore,
                  onChanged: (v) => setDialogState(() => _minScore = v),
                ),
                const SizedBox(height: 8),
                _FilterSlider(
                  label: 'Min Trust Score',
                  value: _minTrustScore,
                  onChanged: (v) => setDialogState(() => _minTrustScore = v),
                ),
                const SizedBox(height: 8),
                _FilterSlider(
                  label: 'Max Distance (km)',
                  value: _maxDistance.isFinite ? _maxDistance : 200,
                  max: 200,
                  onChanged: (v) => setDialogState(() {
                    _maxDistance = v >= 200 ? double.infinity : v;
                  }),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Verified Only'),
                    const Spacer(),
                    Switch(
                      value: _verifiedOnly,
                      onChanged: (v) =>
                          setDialogState(() => _verifiedOnly = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  _minScore = 0;
                  _minTrustScore = 0;
                  _maxDistance = double.infinity;
                  _verifiedOnly = false;
                });
              },
              child: const Text('Reset'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFeedbackDialog(BuildContext context, String matchId) async {
    final rating = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate this match'),
        content: _RatingSelector(),
      ),
    );
    if (rating != null && mounted) {
      context
          .read<MatchBloc>()
          .add(SubmitFeedbackRequested(matchId: matchId, rating: rating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Matches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: BlocBuilder<MatchBloc, MatchState>(
        builder: (context, state) {
          if (state is MatchLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MatchesLoaded) {
            final filtered = _applyFilters(state.matches);
            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No matches found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.matches.isEmpty
                          ? 'Create more skill listings to get matches'
                          : 'Try adjusting your filters',
                      style: const TextStyle(color: Colors.grey),
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
              matches: filtered,
              onAccept: (matchId) {
                context
                    .read<MatchBloc>()
                    .add(AcceptMatchRequested(matchId: matchId));
                _showFeedbackDialog(context, matchId);
              },
              onReject: (matchId) {
                context
                    .read<MatchBloc>()
                    .add(RejectMatchRequested(matchId: matchId));
                _showFeedbackDialog(context, matchId);
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

class _FilterSlider extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;

  const _FilterSlider({
    required this.label,
    required this.value,
    this.max = 100,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${max > 100 ? value.toStringAsFixed(0) : value.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Slider(
          value: value.clamp(0, max),
          max: max,
          divisions: max > 100 ? 40 : 20,
          onChanged: onChanged,
        ),
      ],
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
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/profile/${match.targetUserId}'),
                      child: CircleAvatar(
                        child: Text(
                          match.targetSkillTitle.isNotEmpty
                              ? match.targetSkillTitle[0]
                              : '?',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => context.push('/skills/details/${match.targetSkillId}'),
                            child: Text(
                              match.targetSkillTitle,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
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
                Text('${match.targetSkillLevel.name} · ${match.targetSkillFormat.name}${match.distance != null ? ' · ${match.distance!.toStringAsFixed(1)} km' : ''}'),
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

class _RatingSelector extends StatefulWidget {
  @override
  State<_RatingSelector> createState() => _RatingSelectorState();
}

class _RatingSelectorState extends State<_RatingSelector> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('How was this match?',
            style: TextStyle(fontSize: 16)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final star = i + 1;
            return IconButton(
              icon: Icon(
                star <= _selected ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 36,
              ),
              onPressed: () => setState(() => _selected = star),
            );
          }),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _selected > 0
              ? () => Navigator.of(context).pop(_selected)
              : null,
          child: const Text('Submit'),
        ),
      ],
    );
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
