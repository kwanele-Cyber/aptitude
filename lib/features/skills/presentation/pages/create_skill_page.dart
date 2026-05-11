import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/core/validators/validators.dart';
import 'package:myapp/features/ai/domain/entities/skill_recommendation_entity.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_bloc.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_event.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_state.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_bloc.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_event.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_state.dart';

class CreateSkillPage extends StatefulWidget {
  final SkillType type;

  const CreateSkillPage({super.key, this.type = SkillType.offer});

  @override
  State<CreateSkillPage> createState() => _CreateSkillPageState();
}

class _CreateSkillPageState extends State<CreateSkillPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  SkillLevel _level = SkillLevel.beginner;
  SkillFormat _format = SkillFormat.online;
  final _tagsController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onFieldChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      if (title.isEmpty && description.isEmpty) return;
      context.read<SkillBloc>().add(
            SuggestCategoryRequested(
              title: title,
              description: description,
            ),
          );
    });
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
            type: widget.type,
            level: _level,
            format: _format,
            tags: tags,
          ),
        );
  }

  String get _title =>
      widget.type == SkillType.offer ? 'Create Skill Offer' : 'Create Skill Request';
  String get _actionLabel =>
      widget.type == SkillType.offer ? 'Create Skill Offer' : 'Create Skill Request';
  String get _successMessage =>
      widget.type == SkillType.offer
          ? 'Skill offer created successfully!'
          : 'Skill request created successfully!';
  String get _descriptionHint =>
      widget.type == SkillType.offer
          ? 'Describe what you can teach...'
          : 'Describe what you want to learn...';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: BlocListener<SkillBloc, SkillState>(
        listener: (context, state) {
          if (state is SkillOfferCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_successMessage),
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
                      onChanged: (_) => _onFieldChanged(),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: _descriptionHint,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (v) =>
                          Validators.nonEmpty(v, fieldName: 'Description'),
                      onChanged: (_) => _onFieldChanged(),
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
                    if (state is CategoriesSuggested) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: state
                            .suggestions
                            .map(
                              (suggestion) => ActionChip(
                                label: Text(
                                  suggestion,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                onPressed: () {
                                  _categoryController.text = suggestion;
                                  context.read<SkillBloc>().add(
                                        SuggestCategoryRequested(
                                          title: '',
                                          description: '',
                                        ),
                                      );
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                      ),
                    ],
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
                    const SizedBox(height: 20),
                    const _AiRecommendationsCard(),
                    const SizedBox(height: 16),
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
                          : Text(_actionLabel),
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

class _AiRecommendationsCard extends StatefulWidget {
  const _AiRecommendationsCard();

  @override
  State<_AiRecommendationsCard> createState() =>
      _AiRecommendationsCardState();
}

class _AiRecommendationsCardState extends State<_AiRecommendationsCard> {
  @override
  void initState() {
    super.initState();
    context.read<AiBloc>().add(GetSkillRecommendations(userId: ''));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AiBloc, AiState>(
      builder: (context, state) {
        if (state is AiLoading) {
          return const SizedBox.shrink();
        }

        List<SkillRecommendationEntity> recs = [];
        if (state is SkillRecommendationsLoaded) {
          recs = state.recommendations;
        }

        if (recs.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF5F5CFF).withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome,
                      size: 16, color: const Color(0xFF5F5CFF)),
                  const SizedBox(width: 6),
                  Text(
                    'AI recommends',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF5F5CFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...recs.take(3).map(
                    (rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            rec.type == RecommendationType.learn
                                ? Icons.school
                                : Icons.menu_book,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rec.skillTitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5F5CFF)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${(rec.confidenceScore * 100).toInt()}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF5F5CFF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
