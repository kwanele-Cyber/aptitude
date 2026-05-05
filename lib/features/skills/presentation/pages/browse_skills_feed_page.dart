import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
              child: ListView.builder(
                itemCount: skills.length,
                itemBuilder: (context, index) {
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
                              maxLines: 2, overflow: TextOverflow.ellipsis),
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
                      onTap: () => context.push('/skills/details/${skill.id}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_outline, size: 20),
                        tooltip: 'View profile',
                        onPressed: () => context.push('/profile/${skill.userId}'),
                      ),
                    ),
                  );
                },
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
