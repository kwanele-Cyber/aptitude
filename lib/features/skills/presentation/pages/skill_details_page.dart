import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_bloc.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_event.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_state.dart';

class SkillDetailsPage extends StatefulWidget {
  final String skillId;

  const SkillDetailsPage({super.key, required this.skillId});

  @override
  State<SkillDetailsPage> createState() => _SkillDetailsPageState();
}

class _SkillDetailsPageState extends State<SkillDetailsPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<SkillBloc>()
        .add(ViewSkillDetailsRequested(id: widget.skillId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skill Details')),
      body: BlocBuilder<SkillBloc, SkillState>(
        builder: (context, state) {
          if (state is SkillLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SkillDetailsLoaded) {
            final skill = state.skill;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(skill.title,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  _infoRow('Description', skill.description),
                  _infoRow('Category', skill.category),
                  _infoRow('Level', skill.level.name),
                  _infoRow('Format', skill.format.name),
                  _infoRow('Type', skill.type.name),
                  if (skill.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Tags',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: skill.tags
                          .map((tag) => Chip(label: Text(tag)))
                          .toList(),
                    ),
                  ],
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
                      context.read<SkillBloc>().add(
                          ViewSkillDetailsRequested(id: widget.skillId));
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
