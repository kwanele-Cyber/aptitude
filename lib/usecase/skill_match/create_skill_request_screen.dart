import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/skill_enums.dart';
import 'package:provider/provider.dart';
import 'view_model/create_skill_request_view_model.dart';

class CreateSkillRequestScreen extends StatelessWidget {
  const CreateSkillRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateSkillRequestViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Request to Learn'),
        ),
        body: const _CreateSkillRequestForm(),
      ),
    );
  }
}

class _CreateSkillRequestForm extends StatefulWidget {
  const _CreateSkillRequestForm();

  @override
  State<_CreateSkillRequestForm> createState() => _CreateSkillRequestFormState();
}

class _CreateSkillRequestFormState extends State<_CreateSkillRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _skillController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _skillController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateSkillRequestViewModel>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'What do you want to learn?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skillController,
                decoration: const InputDecoration(
                  labelText: 'Skill Name',
                  hintText: 'e.g. Flutter, Graphic Design, Cooking',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
                onChanged: viewModel.updateSkillName,
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Please enter a skill' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Target Proficiency Level',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildLevelSelector(viewModel),
              const SizedBox(height: 24),
              const Text(
                'Preferred Learning Format',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildFormatSelector(viewModel),
              const SizedBox(height: 24),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Specific Requirements',
                  hintText: 'e.g. "Looking for weekend sessions", "Need help with X"...',
                  border: OutlineInputBorder(),
                ),
                onChanged: viewModel.updateDescription,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await viewModel.saveRequest();
                          if (!context.mounted) return;
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Learning request created!')),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Failed to save learning request')),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: viewModel.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Learning Request',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelSelector(CreateSkillRequestViewModel viewModel) {
    return SegmentedButton<SkillLevel>(
      segments: SkillLevel.values.map((level) {
        return ButtonSegment<SkillLevel>(
          value: level,
          label: Text(level.displayName),
        );
      }).toList(),
      selected: {viewModel.targetLevel},
      onSelectionChanged: (Set<SkillLevel> newSelection) {
        viewModel.updateTargetLevel(newSelection.first);
      },
    );
  }

  Widget _buildFormatSelector(CreateSkillRequestViewModel viewModel) {
    return SegmentedButton<SkillFormat>(
      segments: SkillFormat.values.map((format) {
        return ButtonSegment<SkillFormat>(
          value: format,
          label: Text(format.displayName),
        );
      }).toList(),
      selected: {viewModel.preferredFormat},
      onSelectionChanged: (Set<SkillFormat> newSelection) {
        viewModel.updatePreferredFormat(newSelection.first);
      },
    );
  }
}
