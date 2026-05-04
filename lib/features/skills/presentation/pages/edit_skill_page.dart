import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/core/validators/validators.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_bloc.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_event.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_state.dart';

class EditSkillPage extends StatefulWidget {
  final SkillEntity skill;

  const EditSkillPage({super.key, required this.skill});

  @override
  State<EditSkillPage> createState() => _EditSkillPageState();
}

class _EditSkillPageState extends State<EditSkillPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late SkillLevel _level;
  late SkillFormat _format;
  late final TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.skill.title);
    _descriptionController =
        TextEditingController(text: widget.skill.description);
    _categoryController = TextEditingController(text: widget.skill.category);
    _level = widget.skill.level;
    _format = widget.skill.format;
    _tagsController =
        TextEditingController(text: widget.skill.tags.join(', '));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    context.read<SkillBloc>().add(
          UpdateSkillRequested(
            id: widget.skill.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _categoryController.text.trim(),
            type: widget.skill.type,
            level: _level,
            format: _format,
            tags: tags,
          ),
        );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Skill'),
        content: const Text(
          'Are you sure you want to delete this skill? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SkillBloc>().add(
                    DeleteSkillRequested(id: widget.skill.id),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Skill')),
      body: BlocListener<SkillBloc, SkillState>(
        listener: (context, state) {
          if (state is SkillUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Skill updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
          if (state is SkillDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Skill deleted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).popUntil(
              (route) => route.settings.name == '/home',
            );
          }
          if (state is SkillError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<SkillBloc, SkillState>(
          builder: (context, state) {
            final isLoading = state is SkillLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'e.g., Flutter Development',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          Validators.nonEmpty(v, fieldName: 'Title'),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe what you can teach...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (v) =>
                          Validators.nonEmpty(v, fieldName: 'Description'),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        hintText: 'e.g., Technology, Music, Art',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          Validators.nonEmpty(v, fieldName: 'Category'),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<SkillLevel>(
                      value: _level,
                      decoration: const InputDecoration(
                        labelText: 'Level',
                        border: OutlineInputBorder(),
                      ),
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
                      onChanged: isLoading
                          ? null
                          : (v) {
                              if (v != null) setState(() => _level = v);
                            },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<SkillFormat>(
                      value: _format,
                      decoration: const InputDecoration(
                        labelText: 'Format',
                        border: OutlineInputBorder(),
                      ),
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
                      onChanged: isLoading
                          ? null
                          : (v) {
                              if (v != null) setState(() => _format = v);
                            },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags',
                        hintText: 'Comma-separated (e.g., mobile, dart)',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Changes'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: isLoading ? null : _confirmDelete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete Skill'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
