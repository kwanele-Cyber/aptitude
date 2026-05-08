import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/progress/domain/entity/learning_goal_entity.dart';
import 'package:myapp/features/progress/presentation/bloc/progress_bloc.dart';
import 'package:myapp/features/progress/presentation/bloc/progress_event.dart';

class SetGoalPage extends StatefulWidget {
  const SetGoalPage({super.key});

  @override
  State<SetGoalPage> createState() => _SetGoalPageState();
}

class _SetGoalPageState extends State<SetGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _skillTitleController = TextEditingController();
  int _targetLevel = 1;
  DateTime? _targetDate;

  @override
  void dispose() {
    _descriptionController.dispose();
    _skillTitleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final goal = LearningGoalEntity(
      id: '${authState.userEntity.id}_${DateTime.now().millisecondsSinceEpoch}',
      userId: authState.userEntity.id,
      skillId: _skillTitleController.text.toLowerCase().replaceAll(' ', '_'),
      skillTitle: _skillTitleController.text,
      description: _descriptionController.text,
      targetLevel: _targetLevel,
      targetDate: _targetDate,
      createdAt: DateTime.now(),
    );

    context.read<ProgressBloc>().add(SetGoalRequested(goal: goal));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Goal set successfully!')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Learning Goal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _skillTitleController,
                decoration: const InputDecoration(
                  labelText: 'Skill',
                  hintText: 'e.g. Flutter, Guitar, Photography',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter a skill' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Goal Description',
                  hintText: 'e.g. Build a complete Flutter app',
                ),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Describe your goal' : null,
              ),
              const SizedBox(height: 16),
              Text('Target Level',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(5, (i) {
                  final level = i + 1;
                  return ChoiceChip(
                    label: Text('Level $level'),
                    selected: _targetLevel == level,
                    onSelected: (_) => setState(() => _targetLevel = level),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _targetDate != null
                          ? 'Target: ${_targetDate!.month}/${_targetDate!.day}/${_targetDate!.year}'
                          : 'No target date set',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text(
                        _targetDate != null ? 'Change Date' : 'Set Date'),
                  ),
                  if (_targetDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _targetDate = null),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('Set Goal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
