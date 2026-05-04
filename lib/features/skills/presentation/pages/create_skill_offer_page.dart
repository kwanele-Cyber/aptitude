import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/core/validators/validators.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_bloc.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_event.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_state.dart';

class CreateSkillOfferPage extends StatefulWidget {
  const CreateSkillOfferPage({super.key});

  @override
  State<CreateSkillOfferPage> createState() => _CreateSkillOfferPageState();
}

class _CreateSkillOfferPageState extends State<CreateSkillOfferPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  SkillLevel _level = SkillLevel.beginner;
  SkillFormat _format = SkillFormat.online;
  final _tagsController = TextEditingController();

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
          CreateSkillOfferRequested(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _categoryController.text.trim(),
            level: _level,
            format: _format,
            tags: tags,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Skill Offer')),
      body: BlocListener<SkillBloc, SkillState>(
        listener: (context, state) {
          if (state is SkillOfferCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Skill offer created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
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
                          : const Text('Create Skill Offer'),
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
