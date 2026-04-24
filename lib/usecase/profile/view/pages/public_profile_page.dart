import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/usecase/profile/profile_viewmodel.dart';
import 'package:myapp/core/models/user_model.dart';

class PublicProfilePage extends StatefulWidget {
  final String uid;

  const PublicProfilePage({super.key, required this.uid});

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadUserProfile(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final user = viewModel.viewedUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: const Color(0xFF0F2027),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : viewModel.error != null
                ? Center(child: Text(viewModel.error!, style: const TextStyle(color: Colors.white)))
                : user == null
                    ? const Center(child: Text('No user data', style: TextStyle(color: Colors.white)))
                    : _buildProfileContent(user),
      ),
    );
  }

  Widget _buildProfileContent(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white24,
            backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null ? const Icon(Icons.person, size: 60, color: Colors.white70) : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.displayName,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Trust Score: ${user.trustScore.toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildSkillSection('Offered Skills', user.offeredSkills),
          const SizedBox(height: 24),
          _buildSkillSection('Desired Skills', user.desiredSkills),
        ],
      ),
    );
  }

  Widget _buildSkillSection(String title, List skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) => Chip(
            label: Text(skill.name),
            backgroundColor: Colors.white.withOpacity(0.1),
            labelStyle: const TextStyle(color: Colors.white),
          )).toList(),
        ),
        if (skills.isEmpty)
          const Text('None listed', style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
      ],
    );
  }
}
