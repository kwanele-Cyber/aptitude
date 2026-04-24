import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiscoverScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const DiscoverScreen({super.key, required this.userData});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<QueryDocumentSnapshot> _matches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    final mySkills = List<String>.from(widget.userData['skills'] ?? []);
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
      .collection('users').get();
    setState(() {
      _matches = snapshot.docs.where((doc) {
        if (doc.id == myUid) return false;
        final skills = List<String>.from(doc['skills'] ?? []);
        return skills.any((s) => mySkills.contains(s));
      }).toList();
      _loading = false;
    });
  }

  Future<void> _sendRequest(String toUid, Map<String, dynamic> toUser) async {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final existing = await FirebaseFirestore.instance
      .collection('invites')
      .where('from', isEqualTo: myUid)
      .where('to', isEqualTo: toUid)
      .get();
    if (existing.docs.isNotEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invite already sent!'),
          backgroundColor: Colors.orange));
      return;
    }
    final mySkills = List<String>.from(widget.userData['skills'] ?? []);
    final theirSkills = List<String>.from(toUser['skills'] ?? []);
    final common = mySkills.where((s) => theirSkills.contains(s)).toList();
    await FirebaseFirestore.instance.collection('invites').add({
      'from': myUid,
      'to': toUid,
      'fromName': '${widget.userData['firstName']} ${widget.userData['lastName']}',
      'toName': '${toUser['firstName']} ${toUser['lastName']}',
      'commonSkills': common,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite sent successfully!'),
        backgroundColor: Color(0xFF22C55E)));
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
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${widget.userData['firstName']} 👋',
                    style: const TextStyle(fontSize: 22,
                      fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('Find people with matching skills',
                    style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(children: [
                  const Icon(Icons.people, color: Color(0xFF7C3AED), size: 14),
                  const SizedBox(width: 4),
                  Text('${_matches.length} matches',
                    style: const TextStyle(
                      color: Color(0xFF7C3AED), fontSize: 12,
                      fontWeight: FontWeight.w600)),
                ]),
              ),
            ]),
          ),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator(
                  color: Color(0xFF7C3AED)))
              : _matches.isEmpty
                ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.people_outline,
                          size: 40, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      Text('No matches yet',
                        style: TextStyle(color: Colors.grey[400],
                          fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text('Update your skills to find matches',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ]))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: _matches.length,
                    itemBuilder: (context, i) {
                      final user = _matches[i].data() as Map<String, dynamic>;
                      final mySkills = List<String>.from(
                        widget.userData['skills'] ?? []);
                      final userSkills = List<String>.from(
                        user['skills'] ?? []);
                      final common = userSkills
                        .where((s) => mySkills.contains(s)).toList();
                      final initials =
                        '${user['firstName'] != null ? user['firstName'][0] : '?'}'
                        '${user['lastName'] != null ? user['lastName'][0] : ''}';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Row(children: [
                          Container(
                            width: 52, height: 52,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Text(
                              initials.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold,
                                color: Colors.white))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Text(
                              '${user['firstName']} ${user['lastName']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(user['title'] ?? '',
                              style: TextStyle(
                                color: Colors.grey[400], fontSize: 12)),
                            if (user['location'] != null &&
                                user['location'].toString().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(children: [
                                Icon(Icons.location_on_outlined,
                                  size: 12, color: Colors.grey[600]),
                                const SizedBox(width: 2),
                                Text(user['location'],
                                  style: TextStyle(
                                    color: Colors.grey[600], fontSize: 11)),
                              ]),
                            ],
                            const SizedBox(height: 8),
                            Wrap(spacing: 6, runSpacing: 4,
                              children: common.take(3).map((s) =>
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7C3AED)
                                      .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(s, style: const TextStyle(
                                    fontSize: 11, color: Color(0xFF9D6FEF))),
                                )).toList()),
                          ])),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _sendRequest(_matches[i].id, user),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Connect',
                                style: TextStyle(color: Colors.white,
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ]),
                      );
                    }),
          ),
        ]),
      ),
    );
  }
}