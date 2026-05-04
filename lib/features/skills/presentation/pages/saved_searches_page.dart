import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/skills/domain/entity/saved_search_entity.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_bloc.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_event.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_state.dart';

class SavedSearchesPage extends StatefulWidget {
  final String uid;

  const SavedSearchesPage({super.key, required this.uid});

  @override
  State<SavedSearchesPage> createState() => _SavedSearchesPageState();
}

class _SavedSearchesPageState extends State<SavedSearchesPage> {
  @override
  void initState() {
    super.initState();
    context.read<SkillBloc>().add(FetchSavedSearchesRequested(uid: widget.uid));
  }

  void _onDeleteSearch(String id) {
    context.read<SkillBloc>().add(DeleteSavedSearchRequested(id: id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Searches'),
      ),
      body: BlocBuilder<SkillBloc, SkillState>(
        builder: (context, state) {
          if (state is SkillLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SavedSearchesFetched) {
            final searches = state.searches;
            if (searches.isEmpty) {
              return const Center(
                child: Text('No saved searches yet'),
              );
            }
            return ListView.builder(
              itemCount: searches.length,
              itemBuilder: (context, index) {
                final search = searches[index];
                return _SearchTile(
                  search: search,
                  onDelete: () => _onDeleteSearch(search.id),
                );
              },
            );
          }

          if (state is SavedSearchDeleted) {
            context
                .read<SkillBloc>()
                .add(FetchSavedSearchesRequested(uid: widget.uid));
          }

          if (state is SkillError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<SkillBloc>()
                        .add(FetchSavedSearchesRequested(uid: widget.uid)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _SearchTile extends StatelessWidget {
  final SavedSearchEntity search;
  final VoidCallback onDelete;

  const _SearchTile({
    required this.search,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <String>[];
    if (search.category != null) chips.add(search.category!);
    if (search.level != null) chips.add(search.level!.name);
    if (search.format != null) chips.add(search.format!.name);
    if (search.type != null) chips.add(search.type!.name);

    return ListTile(
      title: Text(search.query),
      subtitle: chips.isNotEmpty
          ? Wrap(
              spacing: 4,
              runSpacing: 2,
              children: chips
                  .map((chip) => Chip(
                        label: Text(chip, style: const TextStyle(fontSize: 11)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            )
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}
