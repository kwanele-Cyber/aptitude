import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/skill_enums.dart';
import 'package:provider/provider.dart';
import 'view_model/create_skill_offer_view_model.dart';

class CreateSkillOfferScreen extends StatelessWidget {
  const CreateSkillOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateSkillOfferViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Skill to Teach'),
        ),
        body: const _CreateSkillOfferForm(),
      ),
    );
  }
}

class _CreateSkillOfferForm extends StatefulWidget {
  const _CreateSkillOfferForm();

  @override
  State<_CreateSkillOfferForm> createState() => _CreateSkillOfferFormState();
}

class _CreateSkillOfferFormState extends State<_CreateSkillOfferForm> {
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
    // We use context.select or similar to get specific values if we want to be efficient,
    // but for a form context.watch is fine.
    final viewModel = context.watch<CreateSkillOfferViewModel>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'What skill can you teach?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skillController,
                decoration: const InputDecoration(
                  labelText: 'Skill Name',
                  hintText: 'e.g. Flutter, Graphic Design, Cooking',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.psychology),
                ),
                onChanged: viewModel.updateSkillName,
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Please enter a skill' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Proficiency Level',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildLevelSelector(viewModel),
              const SizedBox(height: 24),
              const Text(
                'Teaching Format',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildFormatSelector(viewModel),
              const SizedBox(height: 24),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Brief Description',
                  hintText: 'Tell others about your experience...',
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
                          final success = await viewModel.saveOffer();
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Skill offer created!')),
                            );
                            Navigator.pop(context);
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Failed to save skill offer')),
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
                        'Save Skill Offer',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelSelector(CreateSkillOfferViewModel viewModel) {
    return SegmentedButton<SkillLevel>(
      segments: SkillLevel.values.map((level) {
        return ButtonSegment<SkillLevel>(
          value: level,
          label: Text(level.displayName),
        );
      }).toList(),
      selected: {viewModel.level},
      onSelectionChanged: (Set<SkillLevel> newSelection) {
        viewModel.updateLevel(newSelection.first);
      },
    );
  }

  Widget _buildFormatSelector(CreateSkillOfferViewModel viewModel) {
    return SegmentedButton<SkillFormat>(
      segments: SkillFormat.values.map((format) {
        return ButtonSegment<SkillFormat>(
          value: format,
          label: Text(format.displayName),
        );
      }).toList(),
      selected: {viewModel.format},
      onSelectionChanged: (Set<SkillFormat> newSelection) {
        viewModel.updateFormat(newSelection.first);
      },
    );
  }
}
