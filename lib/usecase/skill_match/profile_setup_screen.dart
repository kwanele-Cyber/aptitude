import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/core/data/repositories/skills_repository.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/usecase/skill_match/widgets/skill_chip.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/usecase/auth2/auth_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _bio = TextEditingController();
  final _location = TextEditingController();
  final _skillCtrl = TextEditingController();
  List<String> _skills = [];
  String _title = 'Developer';
  bool _isLoading = false;
  String? _error;

  final List<String> _titles = [
    'Developer',
    'Designer',
    'Product Manager',
    'Data Scientist',
    'Marketing',
    'Writer',
    'Photographer',
    'Entrepreneur',
    'Student',
    'Other',
  ];
  final List<String> _suggested = [
    'Flutter',
    'React',
    'Python',
    'Firebase',
    'UI/UX',
    'Figma',
    'Node.js',
    'TypeScript',
    'Swift',
    'Kotlin',
    'Machine Learning',
  ];

  void _addSkill([String? s]) {
    final skill = (s ?? _skillCtrl.text).trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() => _skills.add(skill));
    }
    _skillCtrl.clear();
  }

  void _removeSkill(String s) => setState(() => _skills.remove(s));

  final _authService = AuthService();
  final _skillsRepo = SkillsRepository();

  Future<void> _save() async {
    if (_skills.isEmpty) {
      setState(() => _error = 'Add at least one skill to continue');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) throw Exception('No user found');

      final userRepo = UserRepository();
      await userRepo.update(user.uid, {
        'bio': _bio.text.trim(),
        'location': _location.text.trim(),
        'skills': await _skillsRepo.resolveSkillIds(_skills),
        'title': _title,
        'profileComplete': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = 'Something went wrong. Try again. reason: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildRoleSection(),
            const SizedBox(height: 16),
            _buildBioSection(),
            const SizedBox(height: 16),
            _buildLocationSection(),
            const SizedBox(height: 16),
            _buildSkillsSection(),
            if (_error != null) _buildErrorBanner(),
            const SizedBox(height: 32),
            _buildSaveButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSection() {
    return _card(
      label: 'Your Role',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _title,
            isExpanded: true,
            dropdownColor: const Color(0xFF1A1A2E),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
            items: _titles
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _title = v!),
          ),
        ),
      ),
    );
  }

  Widget _buildBioSection() {
    return _card(
      label: 'Bio',
      child: TextField(
        controller: _bio,
        maxLines: 3,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Tell people about yourself...',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return _card(
      label: 'Location',
      child: TextField(
        controller: _location,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'e.g. Durban, South Africa',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
          prefixIcon: Icon(
            Icons.location_on_outlined,
            color: Colors.grey[500],
            size: 18,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    return _card(
      label: 'Skills',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _skillCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onSubmitted: _addSkill,
                    decoration: InputDecoration(
                      hintText: 'Type a skill and press add...',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _addSkill(),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Suggested skills:',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggested
                .map(
                  (s) => SkillChip(
                    label: s,
                    isSelected: false,
                    onTap: () => _addSkill(s),
                  ),
                )
                .toList(),
          ),
          if (_skills.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills
                  .map(
                    (s) =>
                        SkillChip(label: s, onDeleted: () => _removeSkill(s)),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C3AED),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Find My Matches',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _card({required String label, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
