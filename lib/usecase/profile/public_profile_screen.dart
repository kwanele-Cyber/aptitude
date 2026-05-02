import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/user.dart' as model;
import 'package:myapp/core/data/models/rating.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/core/data/repositories/rating_repository.dart';
import 'package:myapp/usecase/skill_match/widgets/skill_chip.dart';
import 'package:myapp/core/widgets/report_dialog.dart';

class PublicProfileScreen extends StatelessWidget {
  final String uid;

  const PublicProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final userRepo = UserRepository();
    final ratingRepo = RatingRepository();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          userRepo.read(uid),
          ratingRepo.getUserRatings(uid),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
          }
          
          final user = snapshot.data?[0] as model.User?;
          final ratings = snapshot.data?[1] as List<Rating>? ?? [];

          if (user == null) {
            return const Center(child: Text('User not found', style: TextStyle(color: Colors.white)));
          }
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, user),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(user, ratings),
                      const SizedBox(height: 32),
                      _buildSectionTitle('About'),
                      const SizedBox(height: 12),
                      Text(
                        user.bio.isEmpty ? 'No bio provided.' : user.bio,
                        style: TextStyle(color: Colors.grey[400], fontSize: 15, height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Skills to Teach'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: user.skills.map((s) => SkillChip(label: s)).toList(),
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Interests / Wants to Learn'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: user.interests.map((s) => SkillChip(label: s, isSelected: true)).toList(),
                      ),
                      if (ratings.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        _buildSectionTitle('Partner Reviews'),
                        const SizedBox(height: 12),
                        ...ratings.take(5).map((r) => _buildReviewTile(r)),
                      ],
                      const SizedBox(height: 120), // Bottom padding for actions
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: _buildBottomActions(context),
    );
  }

  Widget _buildAppBar(BuildContext context, model.User user) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF1A1A2E),
      actions: [
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => ReportDialog(
                reportedUserId: user.uid,
                context: 'profile',
              ),
            );
          },
          icon: const Icon(Icons.flag_outlined, color: Colors.white70),
          tooltip: 'Report User',
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              user.photoURL.isNotEmpty ? user.photoURL : 'https://i.pravatar.cc/300?u=${user.uid}',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0F0F1A).withOpacity(0.8),
                    const Color(0xFF0F0F1A),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeader(model.User user, List<Rating> ratings) {
    double averageRating = 0;
    if (ratings.isNotEmpty) {
      averageRating = ratings.map((r) => r.score).reduce((a, b) => a + b) / ratings.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${user.firstName} ${user.lastName}',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          user.title,
          style: const TextStyle(fontSize: 16, color: Color(0xFF7C3AED), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        if (ratings.isNotEmpty) ...[
          Row(
            children: [
              _buildStarRating(averageRating),
              const SizedBox(width: 8),
              Text(
                '${averageRating.toStringAsFixed(1)} (${ratings.length} reviews)',
                style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              user.location.address.isNotEmpty ? '${user.location}' : 'Remote / No Location',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : (index < rating ? Icons.star_half : Icons.star_border),
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Logic to initiate connect
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Connect to Swap', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTile(Rating rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStarRating(rating.score),
              const Spacer(),
              Text(
                '${rating.createdAt.day}/${rating.createdAt.month}/${rating.createdAt.year}',
                style: TextStyle(color: Colors.grey[600], fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rating.comment.isEmpty ? 'No comment provided.' : '"${rating.comment}"',
            style: const TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
