import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/usecase/skills/skill_viewmodel.dart';
import 'package:myapp/usecase/auth/auth_viewmodel.dart';
import 'package:myapp/core/models/skill_model.dart';
import 'package:go_router/go_router.dart';

class EditSkillPage extends StatefulWidget {
  final SkillModel skill;

  const EditSkillPage({super.key, required this.skill});

  @override
  State<EditSkillPage> createState() => _EditSkillPageState();
}

class _EditSkillPageState extends State<EditSkillPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _selectedLevel;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.skill.name);
    _descriptionController = TextEditingController(text: widget.skill.description);
    _selectedLevel = widget.skill.level;
  }

  @override
  Widget build(BuildContext context) {
    final skillViewModel = context.watch<SkillViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Skill'),
        backgroundColor: const Color(0xFF373B44),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF373B44), Color(0xFF4286f4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update Skill Details',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              _buildTextField(_nameController, 'Skill Name', Icons.star),
              const SizedBox(height: 20),
              _buildTextField(_descriptionController, 'Description', Icons.description, maxLines: 3),
              const SizedBox(height: 20),
              _buildLevelDropdown(),
              const SizedBox(height: 40),
              if (skillViewModel.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(skillViewModel.error!, style: const TextStyle(color: Colors.redAccent)),
                ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: skillViewModel.isLoading
                      ? null
                      : () async {
                          if (user == null) return;
                          final updatedSkill = widget.skill.copyWith(
                            name: _nameController.text,
                            description: _descriptionController.text,
                            level: _selectedLevel,
                          );
                          final success = await skillViewModel.updateSkill(
                            userId: user.uid,
                            skill: updatedSkill,
                          );
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Skill updated!')),
                            );
                            context.pop();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4286f4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: skillViewModel.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              if (!skillViewModel.isLoading)
                Center(
                  child: TextButton.icon(
                    onPressed: () => _showDeleteConfirmation(context, skillViewModel, user?.uid),
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    label: const Text('Delete Skill', style: TextStyle(color: Colors.redAccent)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, SkillViewModel viewModel, String? userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Skill?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (userId != null) {
                final success = await viewModel.deleteSkill(skillId: widget.skill.id, userId: userId);
                if (success && mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to profile
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Skill deleted')));
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildLevelDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLevel,
          dropdownColor: const Color(0xFF373B44),
          style: const TextStyle(color: Colors.white),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          isExpanded: true,
          onChanged: (String? newValue) {
            setState(() {
              _selectedLevel = newValue!;
            });
          },
          items: <String>['Beginner', 'Intermediate', 'Advanced', 'Expert']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
