import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/usecase/skill/add_skill_to_profile_usecase.dart';
import 'package:myapp/usecase/skill/delete_skill_usecase.dart';

// ✅ ADDED USECASES

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProfileScreen({super.key, required this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _bioCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _skillCtrl = TextEditingController();
  List<String> _skills = [];
  String _title = 'Developer';
  bool _saving = false;

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
    _skills = List<String>.from(widget.userData['skills'] ?? []);
    _bioCtrl.text = widget.userData['bio'] ?? '';
    _locationCtrl.text = widget.userData['location'] ?? '';
    _title = widget.userData['title'] ?? 'Developer';
  }

  // =========================
  // ✅ UPDATED: ADD SKILL
  // =========================
  Future<void> _addSkill() async {
    final s = _skillCtrl.text.trim();
    if (s.isEmpty) return;

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await AddSkillToProfileUseCase().execute(
        userId: uid,
        skillName: s,
        description: "",
        category: "General",
      );

      setState(() {
        if (!_skills.contains(s)) _skills.add(s);
      });

      _skillCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to add skill"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================
  // ✅ UPDATED: REMOVE SKILL
  // =========================
  Future<void> _removeSkill(String s) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await DeleteSkillUseCase().execute(userId: uid, skillName: s);

      setState(() => _skills.remove(s));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to remove skill"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'bio': _bioCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'skills': _skills,
        'title': _title,
        'updatedAt': FieldValue.serverTimestamp(),
      });

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update'),
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
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
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
            ),
            Expanded(child: _isEditing ? _buildEdit() : _buildView()),
          ],
        ),
      ),
    );
  }

  Widget _buildView() {
    final firstName = widget.userData['firstName']?.toString() ?? '';
    final lastName = widget.userData['lastName']?.toString() ?? '';

    final initials =
        '${firstName.isNotEmpty ? firstName[0] : '?'}'
        '${lastName.isNotEmpty ? lastName[0] : ''}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
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
            '${widget.userData['firstName']} ${widget.userData['lastName']}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // SKILLS (unchanged UI)
          Container(
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
                  'Skills',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const SizedBox(height: 12),
                _skills.isEmpty
                    ? Text(
                        'No skills added yet',
                        style: TextStyle(color: Colors.grey[600]),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _skills
                            .map(
                              (s) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF7C3AED),
                                      Color(0xFFEC4899),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  s,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEdit() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // SKILL INPUT (UNCHANGED UI, ONLY LOGIC CHANGED)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skillCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Add skill",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              IconButton(
                onPressed: _addSkill,
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            children: _skills
                .map(
                  (s) => GestureDetector(
                    onTap: () => _removeSkill(s),
                    child: Chip(label: Text(s)),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
