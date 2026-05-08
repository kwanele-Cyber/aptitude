import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/disputes/presentation/pages/report_dialog.dart';
import 'package:myapp/features/auth/domain/entity/user_entity.dart';
import 'package:myapp/features/auth/domain/usecases/get_user_profile_usecase.dart';
import 'package:myapp/features/feedback/presentation/widgets/user_reviews_section.dart';
import 'package:myapp/injection_container.dart';

class UserProfilePage extends StatefulWidget {
  final String uid;

  const UserProfilePage({super.key, required this.uid});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Future<Either<Failure, UserEntity>>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Either<Failure, UserEntity>> _loadProfile() {
    return sl<GetUserProfileUseCase>()(GetUserProfileParams(uid: widget.uid));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: FutureBuilder<Either<Failure, UserEntity>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final result = snapshot.data;
          if (result == null) {
            return const Center(child: Text('No profile data.'));
          }

          return result.fold(
            (failure) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      failure.message ?? 'Failed to load user profile.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => setState(() {
                        _profileFuture = _loadProfile();
                      }),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            (user) => ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    child: Text(
                      _initials(user),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                if (user.title.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.title,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
                // Trust score badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _trustColor(user.trustScore).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user,
                          size: 18, color: _trustColor(user.trustScore)),
                      const SizedBox(width: 6),
                      Text(
                        'Trust Score: ${user.trustScore.toInt()}/100',
                        style: TextStyle(
                          color: _trustColor(user.trustScore),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    context.push('/messages/${user.id}', extra: user);
                  },
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('Message'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    context.push('/trust/${user.id}');
                  },
                  icon: const Icon(Icons.verified_user_outlined),
                  label: const Text('View Trust Profile'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    ReportDialog.show(
                      context,
                      reportedUserId: user.id,
                      reportedUserName: user.name,
                    );
                  },
                  icon: const Icon(Icons.flag_outlined),
                  label: const Text('Report User'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                _InfoRow(label: 'Email', value: user.email),
                if (user.phone != null) _InfoRow(label: 'Phone', value: user.phone!),
                if (user.location.address.isNotEmpty)
                  _InfoRow(label: 'Location', value: user.location.address),
                if (user.bio.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Bio', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(user.bio),
                ],
                if (user.skills.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Skills', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.skills.map((s) => Chip(label: Text(s))).toList(),
                  ),
                ],
                if (user.interests.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Interests', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.interests.map((i) => Chip(label: Text(i))).toList(),
                  ),
                ],
                UserReviewsSection(userId: user.id),
              ],
            ),
          );
        },
      ),
    );
  }

  String _initials(UserEntity user) {
    final first = user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '';
    final last = user.lastName.isNotEmpty ? user.lastName[0].toUpperCase() : '';
    return (first + last).isEmpty ? '?' : first + last;
  }

  Color _trustColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
