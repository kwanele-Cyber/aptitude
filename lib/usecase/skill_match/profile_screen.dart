import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    'Developer', 'Designer', 'Product Manager', 'Data Scientist',
    'Marketing', 'Writer', 'Photographer', 'Entrepreneur', 'Student', 'Other'
  ];
  final List<String> _suggested = [
    'Flutter', 'React', 'Python', 'Firebase', 'UI/UX', 'Figma', 'Node.js'
  ];

  @override
  void initState() {
    super.initState();
    _skills = List<String>.from(widget.userData['skills'] ?? []);
    _bioCtrl.text = widget.userData['bio'] ?? '';
    _locationCtrl.text = widget.userData['location'] ?? '';
    _title = widget.userData['title'] ?? 'Developer';
  }

  void _addSkill() {
    final s = _skillCtrl.text.trim();
    if (s.isNotEmpty && !_skills.contains(s)) setState(() => _skills.add(s));
    _skillCtrl.clear();
  }

  void _removeSkill(String s) => setState(() => _skills.remove(s));

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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!'),
          backgroundColor: Color(0xFF22C55E)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update'),
          backgroundColor: Colors.red));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(children: [
              Text(_isEditing ? 'Edit Profile' : 'Profile',
                style: const TextStyle(fontSize: 22,
                  fontWeight: FontWeight.bold, color: Colors.white)),
              const Spacer(),
              if (!_isEditing) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                    color: Colors.white, size: 22),
                  onPressed: () => setState(() => _isEditing = true),
                ),
                IconButton(
                  icon: Icon(Icons.logout_outlined,
                    color: Colors.grey[400], size: 22),
                  onPressed: _logout,
                ),
              ],
            ]),
          ),
          Expanded(
            child: _isEditing ? _buildEdit() : _buildView()),
        ]),
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
      child: Column(children: [
        Container(
          width: 90, height: 90,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(initials.toUpperCase(),
            style: const TextStyle(fontSize: 34,
              fontWeight: FontWeight.bold, color: Colors.white))),
        ),
        const SizedBox(height: 16),
        Text(
          '${widget.userData['firstName']} ${widget.userData['lastName']}',
          style: const TextStyle(fontSize: 22,
            fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(_title,
            style: const TextStyle(color: Color(0xFF9D6FEF), fontSize: 13)),
        ),
        if (widget.userData['location'] != null &&
            widget.userData['location'].toString().isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(widget.userData['location'],
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          ]),
        ],
        const SizedBox(height: 24),
        if (widget.userData['bio'] != null &&
            widget.userData['bio'].toString().isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text('About', style: TextStyle(
                color: Colors.grey[400], fontSize: 12,
                fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text(widget.userData['bio'],
                style: TextStyle(color: Colors.grey[300], height: 1.5)),
            ]),
          ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text('Skills', style: TextStyle(
              color: Colors.grey[400], fontSize: 12,
              fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            _skills.isEmpty
              ? Text('No skills added yet',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13))
              : Wrap(spacing: 8, runSpacing: 8,
                  children: _skills.map((s) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(s, style: const TextStyle(
                      fontSize: 13, color: Colors.white)),
                  )).toList()),
          ]),
        ),
      ]),
    );
  }

  Widget _buildEdit() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        _editCard('Role', Container(
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
              items: _titles.map((t) =>
                DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _title = v!),
            ),
          ),
        )),
        const SizedBox(height: 14),
        _editCard('Bio', TextField(
          controller: _bioCtrl, maxLines: 3,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Tell people about yourself...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(12),
          ),
        )),
        const SizedBox(height: 14),
        _editCard('Location', TextField(
          controller: _locationCtrl,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'City, Country',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(Icons.location_on_outlined,
              color: Colors.grey[500], size: 18),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(12),
          ),
        )),
        const SizedBox(height: 14),
        _editCard('Skills', Column(children: [
          Row(children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _skillCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
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
                height: 46, width: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8,
            children: _suggested.map((s) => GestureDetector(
              onTap: () { if (!_skills.contains(s)) setState(() => _skills.add(s)); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3)),
                ),
                child: Text('+ $s', style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9D6FEF))),
              ),
            )).toList()),
          if (_skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8,
              children: _skills.map((s) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(s, style: const TextStyle(
                    fontSize: 12, color: Colors.white)),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _removeSkill(s),
                    child: const Icon(Icons.close,
                      size: 14, color: Colors.white70)),
                ]),
              )).toList()),
          ],
        ])),
        const SizedBox(height: 28),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => setState(() {
              _isEditing = false;
              _skills = List<String>.from(widget.userData['skills'] ?? []);
              _bioCtrl.text = widget.userData['bio'] ?? '';
              _locationCtrl.text = widget.userData['location'] ?? '';
              _title = widget.userData['title'] ?? 'Developer';
            }),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF7C3AED)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Cancel',
              style: TextStyle(color: Color(0xFF7C3AED), fontSize: 14)),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
            child: _saving
              ? const SizedBox(height: 20, width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
              : const Text('Save Changes',
                  style: TextStyle(fontSize: 14, color: Colors.white)),
          )),
        ]),
        const SizedBox(height: 40),
      ]),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(
          fontSize: 12, color: Colors.grey[400],
          fontWeight: FontWeight.w500, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}