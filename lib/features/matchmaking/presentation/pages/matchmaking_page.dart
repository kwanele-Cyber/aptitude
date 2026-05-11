import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_bloc.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/matchmaking/domain/entity/match_entity.dart';
import 'package:myapp/features/matchmaking/presentation/bloc/match_bloc.dart';
import 'package:myapp/features/matchmaking/presentation/bloc/match_event.dart';
import 'package:myapp/features/matchmaking/presentation/bloc/match_state.dart';
import 'package:myapp/features/notifications/domain/entity/notification_type.dart';
import 'package:myapp/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:myapp/features/notifications/presentation/bloc/notification_event.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_event.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_state.dart';
import 'package:myapp/features/ai/domain/entities/match_optimization_entity.dart';

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
  bool _aiOptimized = false;
  List<MatchEntity>? _lastMatches;
  String? _lastAcceptedMatchId;
  List<MatchOptimizationEntity>? _aiInsights;
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

  List<MatchEntity> _applyFilters(List<MatchEntity> matches) {
    return matches.where((m) {
      if (m.score < _minScore) return false;
      if (m.targetTrustScore < _minTrustScore) return false;
      if (_verifiedOnly && !m.targetIsVerified) return false;
      if (_maxDistance.isFinite &&
          m.distance != null &&
          m.distance! > _maxDistance) {
        return false;
      }
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
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'AI-Optimized',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _aiOptimized,
                      onChanged: (v) => setDialogState(() {
                        _aiOptimized = v;
                        if (v) {
                          _minScore = 50;
                          _minTrustScore = 60;
                          _verifiedOnly = true;
                        } else {
                          _minScore = 0;
                          _minTrustScore = 0;
                          _verifiedOnly = false;
                        }
                      }),
                    ),
                  ],
                ),
                if (_aiOptimized)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Automatically applies optimal match criteria based on your skill profile',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
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
                  _aiOptimized = false;
                });
              },
              child: const Text('Reset'),
            ),
            FilledButton(
              onPressed: () {
                if (_aiOptimized && _userId != null) {
                  context.read<AiBloc>().add(
                    GetMatchOptimizations(userId: _userId!),
                  );
                } else {
                  setState(() => _aiInsights = null);
                }
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
    final bloc = context.read<MatchBloc>();
    final rating = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate this match'),
        content: _RatingSelector(),
      ),
    );
    if (rating != null && mounted) {
      bloc.add(SubmitFeedbackRequested(matchId: matchId, rating: rating));
    }
  }

  void _onAccept(String matchId) {
    _lastAcceptedMatchId = matchId;
    context.read<MatchBloc>().add(AcceptMatchRequested(matchId: matchId));
    _showFeedbackDialog(context, matchId);
  }

  void _offerCreateAgreement(String matchId) {
    if (_lastMatches == null) return;
    MatchEntity? match;
    for (final m in _lastMatches!) {
      if (m.id == matchId) {
        match = m;
        break;
      }
    }
    if (match == null || !mounted) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Agreement?'),
        content: const Text(
          'Would you like to formalize this match with a skill exchange agreement?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Not Now'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push('/agreements/create', extra: {
                'partnerId': match!.targetUserId,
                'partnerName': match!.targetUserName,
                'partnerSkillId': match!.targetSkillId,
                'partnerSkillTitle': match!.targetSkillTitle,
                'initiatorSkillId': match!.matchedSkillId,
                'initiatorName':
                    '${authState.userEntity.firstName} ${authState.userEntity.lastName}',
                'initiatorId': authState.userEntity.id,
              });
            },
            icon: const Icon(Icons.handshake, size: 18),
            label: const Text('Create Agreement'),
          ),
        ],
      ),
    );
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
      body: BlocListener<AiBloc, AiState>(
        listener: (context, state) {
          if (state is MatchOptimizationsLoaded) {
            setState(() => _aiInsights = state.optimizations);
          }
        },
        child: Column(
          children: [
            if (_aiOptimized && _aiInsights != null && _aiInsights!.isNotEmpty)
              _AiInsightsBanner(insights: _aiInsights!),
            Expanded(
              child: BlocConsumer<MatchBloc, MatchState>(
        listener: (context, state) {
          if (state is MatchesLoaded) {
            _lastMatches = state.matches;
          }
          if (state is MatchStatusUpdated &&
              state.status == MatchStatus.accepted &&
              _lastAcceptedMatchId != null) {
            _offerCreateAgreement(_lastAcceptedMatchId!);
            _lastAcceptedMatchId = null;
          }
        },
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
              currentUserId: _userId,
              onAccept: _onAccept,
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
            ),
          ],
        ),
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
  final List<MatchEntity> matches;
  final String? currentUserId;
  final ValueChanged<String> onAccept;
  final ValueChanged<String> onReject;
  final ValueChanged<String> onIgnore;

  const _MatchCardStack({
    required this.matches,
    this.currentUserId,
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
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () =>
                          context.push('/trust/${match.targetUserId}'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _trustColor(
                                  (match.targetTrustScore as num).toDouble())
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(match.targetTrustScore as num).toInt()}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _trustColor(
                                (match.targetTrustScore as num).toDouble()),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(match.targetSkillCategory,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text('${match.targetSkillLevel.name} · ${match.targetSkillFormat.name}${match.distance != null ? ' · ${match.distance!.toStringAsFixed(1)} km' : ''}'),
                const SizedBox(height: 12),
                // AI session quality prediction derived from match score
                _SessionQualityBar(score: match.score),
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
                      onTap: () {
                        onAccept(match.id);
                        if (currentUserId != null) {
                          context.read<NotificationBloc>().add(
                            SendNotificationRequested(
                              userId: match.targetUserId,
                              type: NotificationType.match,
                              title: 'Match Accepted',
                              body: '${match.targetUserName} wants to connect with you!',
                            ),
                          );
                        }
                      },
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

  Color _trustColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
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

class _SessionQualityBar extends StatelessWidget {
  final double score;

  const _SessionQualityBar({required this.score});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final predictedQuality = (score * 0.7 + 15).clamp(0, 100);
    final qualityColor = predictedQuality >= 70
        ? const Color(0xFF2E7D32)
        : predictedQuality >= 40
            ? Colors.orange
            : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: qualityColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: qualityColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.analytics_outlined, size: 16, color: qualityColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Predicted session quality',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Text(
            '${predictedQuality.toInt()}%',
            style: theme.textTheme.labelMedium?.copyWith(
              color: qualityColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiInsightsBanner extends StatelessWidget {
  final List<MatchOptimizationEntity> insights;

  const _AiInsightsBanner({required this.insights});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.08),
            theme.colorScheme.primary.withValues(alpha: 0.03),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome,
                  size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'AI Optimizations',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...insights.take(2).map(
            (opt) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '• ${opt.insight}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
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
