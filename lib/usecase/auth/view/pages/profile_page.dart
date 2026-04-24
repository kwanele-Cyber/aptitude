import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/usecase/auth/auth_viewmodel.dart';
import 'package:myapp/core/models/skill_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().user;
    _nameController = TextEditingController(text: user?.displayName ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final user = viewModel.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF203A43),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final success = await viewModel.saveProfileChanges(
                displayName: _nameController.text,
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated!')),
                );
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildAvatar(user.photoUrl),
              const SizedBox(height: 24),
              _buildTextField(_nameController, 'Full Name', Icons.person),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.push('/matches'),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('View Skill Matches'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent.withOpacity(0.1),
                  foregroundColor: Colors.cyanAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(
                title: 'Teaching',
                onAdd: () => context.push('/skills/create-offer').then((_) {
                  if (mounted) context.read<AuthViewModel>().refreshUser();
                }),
              ),
              const SizedBox(height: 12),
              _buildSkillChips(viewModel.offeredSkills, (skill) => viewModel.removeOfferedSkill(skill)),
              const SizedBox(height: 32),
              _buildSectionHeader(
                title: 'Learning',
                onAdd: () => context.push('/skills/create-request').then((_) {
                  if (mounted) context.read<AuthViewModel>().refreshUser();
                }),
              ),
              const SizedBox(height: 12),
              _buildSkillChips(viewModel.desiredSkills, (skill) => viewModel.removeDesiredSkill(skill)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required VoidCallback onAdd}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildSkillChips(List<SkillModel> skills, Function(SkillModel) onRemove) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((skill) => InputChip(
        label: Text(skill.name),
        onPressed: () => context.push('/skills/edit', extra: skill).then((_) {
          if (mounted) context.read<AuthViewModel>().refreshUser();
        }),
        onDeleted: () => onRemove(skill),
        backgroundColor: Colors.white.withOpacity(0.2),
        labelStyle: const TextStyle(color: Colors.white),
        deleteIconColor: Colors.white70,
      )).toList(),
    );
  }

  Widget _buildAvatar(String? photoUrl) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white24,
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null ? const Icon(Icons.person, size: 60, color: Colors.white70) : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blueAccent,
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                onPressed: () {
                  // TODO: Image picker
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
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

}
