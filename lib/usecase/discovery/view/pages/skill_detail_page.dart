import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/core/models/skill_model.dart';
import 'package:myapp/usecase/discovery/skill_detail_viewmodel.dart';
import 'package:go_router/go_router.dart';

class SkillDetailPage extends StatefulWidget {
  final SkillModel skill;

  const SkillDetailPage({super.key, required this.skill});

  @override
  State<SkillDetailPage> createState() => _SkillDetailPageState();
}

class _SkillDetailPageState extends State<SkillDetailPage> {
  @override
  void initState() {
    super.initState();
    if (widget.skill.ownerId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<SkillDetailViewModel>().loadOwnerDetails(widget.skill.ownerId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SkillDetailViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.skill.name),
        backgroundColor: const Color(0xFF141E30),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF141E30), Color(0xFF243B55)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeBadge(),
              const SizedBox(height: 16),
              Text(
                widget.skill.name,
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildLevelChip(),
              const SizedBox(height: 32),
              const Text(
                'Description',
                style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                widget.skill.description,
                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 48),
              const Divider(color: Colors.white24),
              const SizedBox(height: 24),
              const Text(
                'Offered By',
                style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (viewModel.owner != null)
                _buildOwnerCard(viewModel.owner!)
              else
                const Text('Owner information unavailable.', style: TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to Chat (P3)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Connect with Teacher', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge() {
    final isOffer = widget.skill.type == 'offer';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOffer ? Colors.greenAccent.withOpacity(0.2) : Colors.orangeAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOffer ? 'TEACHING OFFER' : 'LEARNING REQUEST',
        style: TextStyle(
          color: isOffer ? Colors.greenAccent : Colors.orangeAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLevelChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.skill.level,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }

  Widget _buildOwnerCard(dynamic owner) {
    return InkWell(
      onTap: () => context.push('/profile/${owner.uid}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: owner.photoUrl != null ? NetworkImage(owner.photoUrl!) : null,
              child: owner.photoUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    owner.displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    owner.location ?? 'Unknown Location',
                    style: const TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
