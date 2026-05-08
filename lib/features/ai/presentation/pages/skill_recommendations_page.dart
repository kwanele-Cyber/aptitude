import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/ai/domain/entities/skill_recommendation_entity.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_bloc.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_event.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_state.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';

class SkillRecommendationsPage extends StatefulWidget {
  const SkillRecommendationsPage({super.key});

  @override
  State<SkillRecommendationsPage> createState() =>
      _SkillRecommendationsPageState();
}

class _SkillRecommendationsPageState extends State<SkillRecommendationsPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context
          .read<AiBloc>()
          .add(GetSkillRecommendations(userId: authState.userEntity.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Recommendations'),
        centerTitle: true,
      ),
      body: BlocBuilder<AiBloc, AiState>(
        builder: (context, state) {
          if (state is AiLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AiError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 56, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthAuthenticated) {
                          context.read<AiBloc>().add(GetSkillRecommendations(
                              userId: authState.userEntity.id));
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is SkillRecommendationsLoaded) {
            final recs = state.recommendations;
            if (recs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lightbulb_outline,
                          size: 56,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text(
                        'No recommendations yet',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete your profile and add skills to get personalized recommendations.',
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

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recs.length,
              itemBuilder: (context, index) {
                final rec = recs[index];
                return _RecommendationCard(rec: rec);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final SkillRecommendationEntity rec;

  const _RecommendationCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLearn = rec.type == RecommendationType.learn;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLearn
                        ? const Color(0xFFF0F4FF)
                        : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isLearn ? 'Learn' : 'Teach',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isLearn
                          ? const Color(0xFF5F5CFF)
                          : const Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.trending_up,
                        size: 16,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${(rec.confidenceScore * 100).toInt()}% match',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              rec.skillTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              rec.category,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.5)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    rec.reason,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
