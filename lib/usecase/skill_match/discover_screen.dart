import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/core/data/repositories/invite_repository.dart';
import 'package:myapp/core/data/models/user.dart' as model;
import 'package:myapp/usecase/skill_match/widgets/match_card.dart';
import 'package:myapp/core/data/models/invite.dart';
import 'package:uuid/uuid.dart';

class DiscoverScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const DiscoverScreen({super.key, required this.userData});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<model.User> _matches = [];
  bool _loading = true;
  final _userRepo = UserRepository();
  final _inviteRepo = InviteRepository();

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    final mySkills = List<String>.from(widget.userData['skills'] ?? []);
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    final allUsers = await _userRepo.listAll();

    setState(() {
      _matches = allUsers.where((user) {
        if (user.uid == myUid) return false;
        return user.skills.any((s) => mySkills.contains(s));
      }).toList();
      _loading = false;
    });
  }

  Future<void> _sendRequest(String toUid, model.User toUser) async {
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    final alreadySent = await _inviteRepo.hasExistingInvite(myUid, toUid);

    if (alreadySent) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invite already sent!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final mySkills = List<String>.from(widget.userData['skills'] ?? []);
    final theirSkills = toUser.skills;
    final common = mySkills.where((s) => theirSkills.contains(s)).toList();

    final invite = Invite(
      id: const Uuid().v4(),
      from: myUid,
      to: toUid,
      fromName:
          '${widget.userData['firstName']} ${widget.userData['lastName']}',
      toName: '${toUser.firstName} ${toUser.lastName}',
      commonSkills: common,
      status: InviteStatus.pending,
      createdAt: DateTime.now().toIso8601String(),
    );

    await _inviteRepo.sendInvite(invite);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invite sent successfully!'),
          backgroundColor: Color(0xFF22C55E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                    )
                  : _matches.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          itemCount: _matches.length,
                          itemBuilder: (context, i) {
                            final user = _matches[i];
                            final mySkills = List<String>.from(
                                widget.userData['skills'] ?? []);
                            final common = user.skills
                                .where((s) => mySkills.contains(s))
                                .toList();

                            return MatchCard(
                              user: user,
                              commonSkills: common,
                              onConnect: () => _sendRequest(user.uid, user),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${widget.userData['firstName']} 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Find people with matching skills',
                  style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, color: Color(0xFF7C3AED), size: 14),
                const SizedBox(width: 4),
                Text(
                  '${_matches.length} matches',
                  style: const TextStyle(
                    color: Color(0xFF7C3AED),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_outline, size: 40, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Text(
            'No matches yet',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Update your skills to find matches',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }
}

