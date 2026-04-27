import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/data/models/location_model.dart';
import 'package:myapp/core/data/repositories/skills_repository.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/usecase/auth2/auth_service.dart';

import 'package:myapp/core/data/extension/model_extensions.dart';
import 'package:myapp/usecase/skill_match/widgets/skill_chip.dart';

class ProfileScreen extends StatefulWidget {
  final User userData;
  const ProfileScreen({super.key, required this.userData});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isEditing = false;
  final _bioCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _skillCtrl = TextEditingController();
  List<String> _skills = []; // Will store skill NAMES
  String _title = 'Developer';
  bool _saving = false;
  bool _loading = true;

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
  ];

  @override
  void initState() {
    super.initState();
    _user = widget.userData;
    _refreshUser();
  }

  Future<void> _refreshUser() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final skillsRepo = SkillsRepository();
        final skillObjects = await skillsRepo.resolveSkillsByIds(user.skills) ?? [];
        final names = skillObjects.map((s) => s.name).toList();

        if (mounted) {
          setState(() {
            _user = user;
            _skills = names;
            _bioCtrl.text = user.bio ?? '';
            _locationCtrl.text = user.location.address ?? '';
            _title = user.title ?? 'Developer';
            _loading = false;
          });
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _addSkill() {
    final s = _skillCtrl.text.trim();
    if (s.isNotEmpty && !_skills.contains(s)) setState(() => _skills.add(s));
    _skillCtrl.clear();
  }

  void _removeSkill(String s) => setState(() => _skills.remove(s));

  final _authService = AuthService();

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) context.go('/');
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) throw Exception('No user found');

      final userRepo = UserRepository();

      // Clear current skills and re-add from the editor names
      // This ensures we sync the database IDs with the user-provided names
      _user!.skills = [];
      await _user!.addSkillsNames(_skills);

      await userRepo.update(user.uid, {
        'bio': _bioCtrl.text.trim(),
        'location': AddressModel(
          address: _locationCtrl.text.trim(),
          latitude: 0,
          longitude: 0,
        ).toJson(),
        'title': _title,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      await _refreshUser();
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated!'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      final f = e.toString();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update reason: $f'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F1A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _isEditing ? _buildEdit() : _buildView()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text(
            _isEditing ? 'Edit Profile' : 'Profile',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          if (!_isEditing) ...[
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () => setState(() => _isEditing = true),
            ),
            IconButton(
              icon: Icon(
                Icons.logout_outlined,
                color: Colors.grey[400],
                size: 22,
              ),
              onPressed: _logout,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildSectionCard(
            'About',
            child: Text(
              _user?.bio ?? 'No bio yet',
              style: TextStyle(color: Colors.grey[300], height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Skills',
            child: _skills.isEmpty
                ? Text(
                    'No skills added yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skills.map((s) => SkillChip(label: s)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final firstName = _user?.firstName?.toString() ?? '';
    final lastName = _user?.lastName?.toString() ?? '';
    final initials =
        '${firstName.isNotEmpty ? firstName[0] : '?'}'
        '${lastName.isNotEmpty ? lastName[0] : ''}';

    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials.toUpperCase(),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _user?.displayName ?? '',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _title,
            style: const TextStyle(color: Color(0xFF9D6FEF), fontSize: 13),
          ),
        ),
        if (_user != null && _user!.location.address.toString().isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                _user?.location.address ?? '',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSectionCard(String label, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildEdit() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _editCard(
            'Role',
            Container(
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
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[400],
                  ),
                  items: _titles
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _title = v!),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _editCard(
            'Bio',
            TextField(
              controller: _bioCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Tell people about yourself...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _editCard(
            'Location',
            TextField(
              controller: _locationCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'City, Country',
                hintStyle: TextStyle(color: Colors.grey[600]),
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
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _editCard(
            'Skills',
            Column(
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          onSubmitted: (_) => _addSkill(),
                          decoration: InputDecoration(
                            hintText: 'Add a skill...',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _addSkill,
                      child: Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _suggested
                      .map(
                        (s) => GestureDetector(
                          onTap: () {
                            if (!_skills.contains(s))
                              setState(() => _skills.add(s));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xFF7C3AED).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              '+ $s',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9D6FEF),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                if (_skills.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skills
                        .map(
                          (s) => SkillChip(
                            label: s,
                            onDeleted: () => _removeSkill(s),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _isEditing = false;
                    _skills = List<String>.from(widget.userData.skills ?? []);
                    _bioCtrl.text = widget.userData.bio ?? '';
                    _locationCtrl.text = widget.userData.location.address ?? '';
                    _title = widget.userData.title ?? 'Developer';
                  }),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF7C3AED)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF7C3AED), fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _editCard(String label, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
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
