import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/trust/domain/entity/trust_entity.dart';
import 'package:myapp/features/trust/presentation/bloc/trust_bloc.dart';
import 'package:myapp/features/trust/presentation/bloc/trust_event.dart';
import 'package:myapp/features/trust/presentation/bloc/trust_state.dart';

class TrustProfilePage extends StatefulWidget {
  final String userId;
  const TrustProfilePage({super.key, required this.userId});

  @override
  State<TrustProfilePage> createState() => _TrustProfilePageState();
}

class _TrustProfilePageState extends State<TrustProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<TrustBloc>().add(
      GetTrustProfileRequested(userId: widget.userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trust Profile')),
      body: BlocConsumer<TrustBloc, TrustState>(
        listener: (context, state) {
          if (state is TrustError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is TrustLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TrustProfileLoaded) {
            return _TrustProfileContent(profile: state.profile);
          }

          if (state is TrustScoreLoaded) {
            return _TrustProfileContent(profile: state.trust);
          }

          if (state is TrustError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TrustBloc>().add(
                        GetTrustProfileRequested(userId: widget.userId),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('No trust data available'));
        },
      ),
    );
  }
}

class _TrustProfileContent extends StatelessWidget {
  final TrustEntity profile;
  const _TrustProfileContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScoreCard(score: profile.score, lastUpdated: profile.lastCalculated),
          const SizedBox(height: 24),
          Text('Trust Factors', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          ...profile.factors.map((factor) => _FactorCard(factor: factor)),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int score;
  final DateTime lastUpdated;
  const _ScoreCard({required this.score, required this.lastUpdated});

  Color _scoreColor() {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  IconData _scoreIcon() {
    if (score >= 80) return Icons.verified_user;
    if (score >= 50) return Icons.help_outline;
    return Icons.warning_amber;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(_scoreIcon(), size: 64, color: _scoreColor()),
            const SizedBox(height: 16),
            Text(
              '$score/100',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: _scoreColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Trust Score',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Last updated: ${_formatDate(lastUpdated)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _FactorCard extends StatelessWidget {
  final TrustFactorEntity factor;
  const _FactorCard({required this.factor});

  @override
  Widget build(BuildContext context) {
    final isPositive = factor.impact == TrustFactorImpact.positive;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
          color: isPositive ? Colors.green : Colors.red,
        ),
        title: Text(factor.name),
        subtitle: Text(factor.description),
        trailing: Text(
          '${isPositive ? '+' : ''}${factor.weight.toStringAsFixed(0)}',
          style: TextStyle(
            color: isPositive ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
