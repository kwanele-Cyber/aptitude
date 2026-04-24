import 'package:flutter/material.dart';
import 'package:myapp/core/models/skill_model.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/usecase/auth/auth_viewmodel.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _pageController = PageController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) => setState(() => _currentStep = index),
                  children: [
                    _buildCredentialStep(viewModel),
                    _buildSkillStep(viewModel),
                    _buildLocationStep(),
                  ],
                ),
              ),
              _buildFooter(viewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 48), // Spacer to center title
              const Text(
                'Aptitude',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () async {
                  await context.read<AuthViewModel>().logout();
                  if (mounted) {
                    GoRouter.of(context).go('/login');
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Create Account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${_currentStep + 1} of 3',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          if (_currentStep == 0) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? ", style: TextStyle(color: Colors.white70)),
                TextButton(
                  onPressed: () => GoRouter.of(context).go('/login'),
                  child: const Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCredentialStep(AuthViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTextField(_nameController, 'Full Name', Icons.person),
          const SizedBox(height: 16),
          _buildTextField(_emailController, 'Email', Icons.email),
          const SizedBox(height: 16),
          _buildTextField(_passwordController, 'Password', Icons.lock, obscureText: true),
          if (viewModel.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                viewModel.error!,
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkillStep(AuthViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListView(
        children: [
          _buildSkillSection(
            title: 'I can teach...',
            skills: viewModel.offeredSkills,
            onAdd: (name) => viewModel.addOfferedSkill(
              SkillModel(id: DateTime.now().toString(), name: name, description: '', level: 'Beginner'),
            ),
            onRemove: (skill) => viewModel.removeOfferedSkill(skill),
          ),
          const SizedBox(height: 32),
          _buildSkillSection(
            title: 'I want to learn...',
            skills: viewModel.desiredSkills,
            onAdd: (name) => viewModel.addDesiredSkill(
              SkillModel(id: DateTime.now().toString(), name: name, description: '', level: 'Beginner'),
            ),
            onRemove: (skill) => viewModel.removeDesiredSkill(skill),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillSection({
    required String title,
    required List<SkillModel> skills,
    required Function(String) onAdd,
    required Function(SkillModel) onRemove,
  }) {
    final controller = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(controller, 'Add a skill...', Icons.add_circle_outline),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  onAdd(controller.text);
                  controller.clear();
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills
              .map((skill) => Chip(
                    label: Text(skill.name),
                    onDeleted: () => onRemove(skill),
                    backgroundColor: Colors.white.withOpacity(0.2),
                    labelStyle: const TextStyle(color: Colors.white),
                    deleteIconColor: Colors.white70,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLocationStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_on, size: 80, color: Colors.white54),
          const SizedBox(height: 24),
          const Text(
            'Almost there!',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'We use your location to find nearby matches. You can skip this for now or set it up later.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Placeholder for location permission
            },
            icon: const Icon(Icons.my_location),
            label: const Text('Share Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFooter(AuthViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              child: const Text('Back', style: TextStyle(color: Colors.white)),
            )
          else
            const SizedBox(),
          ElevatedButton(
            onPressed: viewModel.isLoading
                ? null
                : () async {
                    if (_currentStep == 0) {
                      final success = await viewModel.register(
                        email: _emailController.text,
                        password: _passwordController.text,
                        displayName: _nameController.text,
                      );
                      if (success) {
                        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      }
                    } else if (_currentStep == 1) {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    } else if (_currentStep == 2) {
                      final success = await viewModel.completeProfile();
                      if (success && mounted) {
                        // Navigate to home or dashboard
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile completed successfully!')),
                        );
                        GoRouter.of(context).go('/profile');
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF203A43),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: viewModel.isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_currentStep == 2 ? 'Complete' : 'Next'),
          ),
        ],
      ),
    );
  }
}
