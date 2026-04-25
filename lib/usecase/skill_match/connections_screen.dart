import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});
  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

//TODO: UseFirebase Database not Firestore.
class _ConnectionsScreenState extends State<ConnectionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<QueryDocumentSnapshot> _received = [];
  List<QueryDocumentSnapshot> _sent = [];
  bool _loading = true;
  String? _myUid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _myUid = FirebaseAuth.instance.currentUser?.uid;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await FirebaseFirestore.instance
        .collection('invites')
        .where('to', isEqualTo: _myUid)
        .get();
    final s = await FirebaseFirestore.instance
        .collection('invites')
        .where('from', isEqualTo: _myUid)
        .get();
    setState(() {
      _received = r.docs;
      _sent = s.docs;
      _loading = false;
    });
  }

  Future<void> _updateStatus(String id, String status) async {
    await FirebaseFirestore.instance
        .collection('invites')
        .doc(id)
        .update({'status': status});
    _load();
  }

  String _createChatId(String uid1, String uid2) {
    if (uid1.compareTo(uid2) < 0) {
      return '$uid1-$uid2';
    } else {
      return '$uid2-$uid1';
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
              const Text('Connections',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                    '${_received.where((d) => (d.data() as Map)['status'] == 'pending').length} pending',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ),
            ]),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF7C3AED),
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              labelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Received'),
                Tab(text: 'Sent'),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
                : TabBarView(
                    controller: _tabController,
                    children: [
                        _buildList(_received, true),
                        _buildList(_sent, false),
                      ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildList(List<QueryDocumentSnapshot> list, bool isReceived) {
    if (list.isEmpty) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isReceived ? Icons.inbox_outlined : Icons.send_outlined,
              size: 48, color: Colors.grey[700]),
          const SizedBox(height: 12),
          Text(isReceived ? 'No invites received' : 'No invites sent',
              style: TextStyle(color: Colors.grey[500], fontSize: 15)),
        ],
      ));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final req = list[i].data() as Map<String, dynamic>;
        final name = isReceived ? req['fromName'] : req['toName'];
        final status = req['status'] ?? 'pending';
        final commonSkills = List<String>.from(req['commonSkills'] ?? []);
        final receiverId = isReceived ? req['from'] : req['to'];
        Color statusColor = Colors.orange;
        if (status == 'accepted') statusColor = Colors.green;
        if (status == 'rejected') statusColor = Colors.red;
        return GestureDetector(
          onTap: () {
            if (status == 'accepted') {
              final chatId = _createChatId(_myUid!, receiverId);
              context.go('/chat/$chatId');
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                      child: Text(name != null && name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(name ?? 'Unknown',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                      Text(isReceived ? 'wants to connect' : 'invite sent',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ])),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status.toUpperCase(),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor)),
                ),
              ]),
              if (commonSkills.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: commonSkills
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(s,
                                  style: const TextStyle(
                                      fontSize: 11, color: Color(0xFF9D6FEF))),
                            ))
                        .toList()),
              ],
              if (isReceived && status == 'pending') ...[
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                      child: OutlinedButton(
                    onPressed: () => _updateStatus(list[i].id, 'rejected'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Decline',
                        style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () => _updateStatus(list[i].id, 'accepted'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                    child: const Text('Accept',
                        style: TextStyle(fontSize: 13, color: Colors.white)),
                  )),
                ]),
              ],
              if (status == 'accepted') ...[
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      final chatId = _createChatId(_myUid!, receiverId);
                      context.go('/chat/$chatId');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      elevation: 0,
                    ),
                    child: const Text('Chat',
                        style: TextStyle(fontSize: 13, color: Colors.white)),
                  ),
                ),
              ]
            ]),
          ),
        );
      },
    );
  }
}
