import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/usecase/skills/skill_viewmodel.dart';
import 'package:myapp/usecase/auth/auth_viewmodel.dart';
import 'package:go_router/go_router.dart';

class CreateSkillRequestPage extends StatefulWidget {
  const CreateSkillRequestPage({super.key});

  @override
  State<CreateSkillRequestPage> createState() => _CreateSkillRequestPageState();
}

class _CreateSkillRequestPageState extends State<CreateSkillRequestPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedLevel = 'Beginner';

  @override
  Widget build(BuildContext context) {
    final skillViewModel = context.watch<SkillViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request a Skill'),
        backgroundColor: const Color(0xFF4B0082),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4B0082), Color(0xFF000080)],
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
                'What do you want to learn?',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tell the community what skills you are looking for.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 32),
              _buildTextField(_nameController, 'Skill Name (e.g. Cooking, Coding)', Icons.search),
              const SizedBox(height: 20),
              _buildTextField(_descriptionController, 'Why do you want to learn this?', Icons.info_outline, maxLines: 3),
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
                          final success = await skillViewModel.createSkillRequest(
                            userId: user.uid,
                            name: _nameController.text,
                            description: _descriptionController.text,
                            level: _selectedLevel,
                          );
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Skill request published!')),
                            );
                            context.pop();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4B0082),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: skillViewModel.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Publish Request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
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
          dropdownColor: const Color(0xFF4B0082),
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
