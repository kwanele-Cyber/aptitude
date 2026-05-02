import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/skill.dart';
import 'package:myapp/core/data/models/user.dart' as model;
import 'package:myapp/core/data/repositories/skills_repository.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/usecase/skill_match/widgets/match_card.dart';
import 'package:myapp/core/data/models/match_result.dart';
import 'package:myapp/core/data/models/skill_offer.dart';
import 'package:myapp/core/data/models/skill_request.dart';
import 'package:myapp/core/data/models/skill_enums.dart';
import 'package:myapp/core/data/repositories/user_skills_repository.dart';

class SkillDetailsScreen extends StatefulWidget {
  final String sid;
  final String? skillName;

  const SkillDetailsScreen({
    super.key,
    required this.sid,
    this.skillName,
  });

  @override
  State<SkillDetailsScreen> createState() => _SkillDetailsScreenState();
}

class _SkillDetailsScreenState extends State<SkillDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _skillsRepo = SkillsRepository();
  final _userSkillsRepo = UserSkillsRepository();
  final _userRepo = UserRepository();

  Skill? _skill;
  List<model.User> _mentors = [];
  List<model.User> _peers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final skill = await _skillsRepo.getSkill(widget.sid);
      
      // Fetch all users to find mentors/peers (In production, use indexed queries)
      final allUsers = await _userRepo.listAll();
      final List<model.User> mentors = [];
      final List<model.User> peers = [];

      for (var user in allUsers) {
        final offers = await _userSkillsRepo.getUserOffers(user.uid);
        final requests = await _userSkillsRepo.getUserRequests(user.uid);

        if (offers.any((o) => o.sid == widget.sid && !o.isArchived)) {
          mentors.add(user);
        }
        if (requests.any((r) => r.sid == widget.sid && !r.isArchived)) {
          peers.add(user);
        }
      }

      if (mounted) {
        setState(() {
          _skill = skill;
          _mentors = mentors;
          _peers = peers;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading skill details: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: _buildSkillInfo(),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFF7C3AED),
                      indicatorWeight: 3,
                      tabs: [
                        Tab(text: 'Mentors (${_mentors.length})'),
                        Tab(text: 'Peers (${_peers.length})'),
                      ],
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUserList(_mentors, 'No mentors offering this skill yet.'),
                      _buildUserList(_peers, 'No peers looking for this skill yet.'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: const Color(0xFF1A1A2E),
      flexibleSpace: FlexibleSpaceBar(
        title: Hero(
          tag: 'skill-${widget.sid}',
          child: Text(
            _skill?.name ?? widget.skillName ?? widget.sid,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkillInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_skill?.category.isNotEmpty ?? false)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3)),
              ),
              child: Text(
                _skill!.category.toUpperCase(),
                style: const TextStyle(color: Color(0xFF9D6FEF), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            _skill?.description ?? 'No description available for this skill.',
            style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<model.User> users, String emptyMessage) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_outlined, size: 48, color: Colors.grey[800]),
            const SizedBox(height: 16),
            Text(emptyMessage, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return MatchCard(
          onConnect: () {
            // TODO: Implement direct connection or chat initiation
          },
          onReject: () {},
          onIgnore: () {},
          onSave: () {},
          result: MatchResult(
            peer: user,
            score: 0,
            matchingOffers: _tabController.index == 0 
                ? [SkillOffer(
                    uid: user.uid,
                    sid: widget.sid,
                    skillName: widget.skillName ?? '',
                    level: SkillLevel.beginner,
                    format: SkillFormat.online,
                    description: '',
                  )] 
                : [],
            matchingRequests: _tabController.index == 1
                ? [SkillRequest(
                    uid: user.uid,
                    sid: widget.sid,
                    skillName: widget.skillName ?? '',
                    targetLevel: SkillLevel.beginner,
                    preferredFormat: SkillFormat.online,
                    description: '',
                  )]
                : [],
          )
        );
      },
    );
  }
}

class _SliverTabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF0F0F1A),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabDelegate oldDelegate) => false;
}
