import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_bloc.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_event.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_state.dart';

class SearchSkillsPage extends StatefulWidget {
  const SearchSkillsPage({super.key});

  @override
  State<SearchSkillsPage> createState() => _SearchSkillsPageState();
}

class _SearchSkillsPageState extends State<SearchSkillsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    context.read<SkillBloc>().add(SearchSkillsRequested(query: query.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search skills...',
            border: InputBorder.none,
          ),
          onSubmitted: _onSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _onSearch(_searchController.text),
          ),
        ],
      ),
      body: BlocBuilder<SkillBloc, SkillState>(
        builder: (context, state) {
          if (state is SkillLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SkillsSearchCompleted) {
            final skills = state.skills;
            if (skills.isEmpty) {
              return const Center(
                child: Text('No skills found'),
              );
            }
            return ListView.builder(
              itemCount: skills.length,
              itemBuilder: (context, index) {
                final skill = skills[index];
                return ListTile(
                  title: Text(skill.title),
                  subtitle: Text(skill.description),
                  trailing: Chip(
                    label: Text(skill.level.name),
                  ),
                  onTap: () => context.push('/skills/details/${skill.id}'),
                );
              },
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
                    onPressed: () =>
                        _onSearch(_searchController.text),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Enter a search query to find skills'),
          );
        },
      ),
    );
  }
}
