import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_bloc.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_event.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_state.dart';

class FilterSkillsPage extends StatefulWidget {
  const FilterSkillsPage({super.key});

  @override
  State<FilterSkillsPage> createState() => _FilterSkillsPageState();
}

class _FilterSkillsPageState extends State<FilterSkillsPage> {
  String? _selectedCategory;
  SkillLevel? _selectedLevel;
  SkillFormat? _selectedFormat;
  SkillType? _selectedType;

  void _applyFilters() {
    context.read<SkillBloc>().add(FilterSkillsRequested(
          category: _selectedCategory,
          level: _selectedLevel,
          format: _selectedFormat,
          type: _selectedType,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Skills'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = null;
                _selectedLevel = null;
                _selectedFormat = null;
                _selectedType = null;
              });
              _applyFilters();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'Tech', child: Text('Tech')),
                    DropdownMenuItem(value: 'Music', child: Text('Music')),
                    DropdownMenuItem(value: 'Sports', child: Text('Sports')),
                    DropdownMenuItem(value: 'Art', child: Text('Art')),
                    DropdownMenuItem(value: 'Languages', child: Text('Languages')),
                  ],
                  onChanged: (v) {
                    setState(() => _selectedCategory = v);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<SkillLevel>(
                  decoration: const InputDecoration(labelText: 'Level'),
                  items: const [
                    DropdownMenuItem(
                      value: SkillLevel.beginner,
                      child: Text('Beginner'),
                    ),
                    DropdownMenuItem(
                      value: SkillLevel.intermediate,
                      child: Text('Intermediate'),
                    ),
                    DropdownMenuItem(
                      value: SkillLevel.advanced,
                      child: Text('Advanced'),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() => _selectedLevel = v);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<SkillFormat>(
                  decoration: const InputDecoration(labelText: 'Format'),
                  items: const [
                    DropdownMenuItem(
                      value: SkillFormat.online,
                      child: Text('Online'),
                    ),
                    DropdownMenuItem(
                      value: SkillFormat.inPerson,
                      child: Text('In Person'),
                    ),
                    DropdownMenuItem(
                      value: SkillFormat.both,
                      child: Text('Both'),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() => _selectedFormat = v);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<SkillType>(
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(
                      value: SkillType.offer,
                      child: Text('Offer'),
                    ),
                    DropdownMenuItem(
                      value: SkillType.request,
                      child: Text('Request'),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() => _selectedType = v);
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply Filters'),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<SkillBloc, SkillState>(
              builder: (context, state) {
                if (state is SkillLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SkillsFiltered) {
                  final skills = state.skills;
                  if (skills.isEmpty) {
                    return const Center(child: Text('No skills match filters'));
                  }
                  return ListView.builder(
                    itemCount: skills.length,
                    itemBuilder: (context, index) {
                      final skill = skills[index];
                      return ListTile(
                        title: Text(skill.title),
                        subtitle: Text(
                            '${skill.level.name} - ${skill.format.name}'),
                      );
                    },
                  );
                }

                if (state is SkillError) {
                  return Center(child: Text(state.message));
                }

                return const Center(
                    child: Text('Select filters and press Apply'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
