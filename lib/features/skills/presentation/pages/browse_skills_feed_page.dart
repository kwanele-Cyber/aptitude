import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_bloc.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_event.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_state.dart';
import 'package:myapp/features/ai/domain/entities/skill_recommendation_entity.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_bloc.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_event.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_state.dart';

class BrowseSkillsFeedPage extends StatefulWidget {
  const BrowseSkillsFeedPage({super.key});

  @override
  State<BrowseSkillsFeedPage> createState() => _BrowseSkillsFeedPageState();
}

class _BrowseSkillsFeedPageState extends State<BrowseSkillsFeedPage> {
  @override
  void initState() {
    super.initState();
    context.read<SkillBloc>().add(BrowseSkillsFeedRequested());
    context.read<AiBloc>().add(GetSkillRecommendations(userId: ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skills Feed')),
      body: BlocBuilder<SkillBloc, SkillState>(
        builder: (context, state) {
          if (state is SkillLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SkillsFeedLoaded) {
            final skills = state.skills;
            if (skills.isEmpty) {
              return const Center(child: Text('No skills available'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<SkillBloc>().add(BrowseSkillsFeedRequested());
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _RecommendedHeader(),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final skill = skills[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(skill.title[0].toUpperCase()),
                            ),
                            title: Text(skill.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(skill.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    Chip(
                                      label: Text(
                                        skill.level.name,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    Chip(
                                      label: Text(
                                        skill.format.name,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    Chip(
                                      label: Text(
                                        skill.category,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            onTap: () =>
                                context.push('/skills/details/${skill.id}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.person_outline, size: 20),
                              tooltip: 'View profile',
                              onPressed: () =>
                                  context.push('/profile/${skill.userId}'),
                            ),
                          ),
                        );
                      },
                      childCount: skills.length,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is SkillError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<SkillBloc>()
                          .add(BrowseSkillsFeedRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Loading...'));
        },
      ),
    );
  }
}

class _RecommendedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AiBloc, AiState>(
      builder: (context, state) {
        if (state is! SkillRecommendationsLoaded) {
          return const SizedBox.shrink();
        }
        final recs = state.recommendations;
        if (recs.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome,
                      size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Recommended for You',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final rec = recs[index];
                  return Container(
                    width: 180,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F4FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                rec.type == RecommendationType.learn
                                    ? 'Learn'
                                    : 'Teach',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFF5F5CFF),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(rec.confidenceScore * 100).toInt()}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          rec.skillTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          rec.reason,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
