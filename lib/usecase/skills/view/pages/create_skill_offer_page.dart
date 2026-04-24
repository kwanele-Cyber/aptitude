import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/usecase/skills/skill_viewmodel.dart';
import 'package:myapp/usecase/auth/auth_viewmodel.dart';
import 'package:go_router/go_router.dart';

class CreateSkillOfferPage extends StatefulWidget {
  const CreateSkillOfferPage({super.key});

  @override
  State<CreateSkillOfferPage> createState() => _CreateSkillOfferPageState();
}

class _CreateSkillOfferPageState extends State<CreateSkillOfferPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedLevel = 'Intermediate';

  @override
  Widget build(BuildContext context) {
    final skillViewModel = context.watch<SkillViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer a Skill'),
        backgroundColor: const Color(0xFF1D2671),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D2671), Color(0xFFC33764)],
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
                'What can you teach?',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Share your expertise with the community.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 32),
              _buildTextField(_nameController, 'Skill Name (e.g. Flutter, Piano)', Icons.star),
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
                          final success = await skillViewModel.createSkillOffer(
                            userId: user.uid,
                            name: _nameController.text,
                            description: _descriptionController.text,
                            level: _selectedLevel,
                          );
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Skill offer created!')),
                            );
                            context.pop();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFC33764),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: skillViewModel.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Publish Offer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          dropdownColor: const Color(0xFF1D2671),
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
