import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/data/repositories/block_repository.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/core/services/auth_service.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final _blockRepo = BlockRepository();
  final _userRepo = UserRepository();
  final _auth = AuthService();
  String? _myUid;

  @override
  void initState() {
    super.initState();
    _loadUid();
  }

  void _loadUid() async {
    final user = await _auth.getCurrentUser();
    if (mounted) setState(() => _myUid = user?.uid);
  }

  @override
  Widget build(BuildContext context) {
    if (_myUid == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F1A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: const Text('Blocked Users', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<String>>(
        stream: _blockRepo.streamBlockedList(_myUid!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
          }

          final blockedUids = snapshot.data ?? [];

          if (blockedUids.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            itemCount: blockedUids.length,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemBuilder: (context, index) {
              return _buildBlockedUserTile(blockedUids[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildBlockedUserTile(String uid) {
    return FutureBuilder<User?>(
      future: _userRepo.read(uid),
      builder: (context, snapshot) {
        final user = snapshot.data;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  user?.photoURL.isNotEmpty == true 
                      ? user!.photoURL 
                      : 'https://i.pravatar.cc/150?u=$uid'
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user != null ? '${user.firstName} ${user.lastName}' : 'Loading...',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (user != null)
                      Text(
                        user.title,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _blockRepo.unblockUser(_myUid!, uid),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF7C3AED)),
                child: const Text('Unblock', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.security_outlined, size: 80, color: Colors.grey[800]),
          const SizedBox(height: 16),
          Text(
            'Your blocked list is empty',
            style: TextStyle(color: Colors.grey[400], fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Users you block will appear here.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
