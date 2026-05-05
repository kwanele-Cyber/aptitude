import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_bloc.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_event.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_state.dart';

class SkillDetailsPage extends StatefulWidget {
  final String skillId;

  const SkillDetailsPage({super.key, required this.skillId});

  @override
  State<SkillDetailsPage> createState() => _SkillDetailsPageState();
}

class _SkillDetailsPageState extends State<SkillDetailsPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<SkillBloc>()
        .add(ViewSkillDetailsRequested(id: widget.skillId));
  }

  void _showVerificationDialog(SkillEntity skill) {
    final urlController = TextEditingController();
    final urls = <String>[];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Submit for Verification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add portfolio links or credentials to verify your expertise.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'Portfolio URL',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              if (urls.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: urls
                      .map((u) => Chip(
                            label: Text(u, style: const TextStyle(fontSize: 11)),
                            onDeleted: () {
                              setDialogState(() => urls.remove(u));
                            },
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
              TextButton.icon(
                onPressed: () {
                  final text = urlController.text.trim();
                  if (text.isNotEmpty && !urls.contains(text)) {
                    setDialogState(() => urls.add(text));
                    urlController.clear();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Add URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<SkillBloc>().add(
                      SubmitVerificationRequested(
                        skillId: skill.id,
                        portfolioUrls: urls,
                      ),
                    );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skill Details')),
      body: BlocConsumer<SkillBloc, SkillState>(
        listener: (context, state) {
          if (state is VerificationSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is SkillError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SkillLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SkillDetailsLoaded || state is VerificationSubmitted) {
            final skill = state is SkillDetailsLoaded
                ? state.skill
                : (state as VerificationSubmitted).skill;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(skill.title,
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                      if (skill.isVerified)
                        const _VerifiedBadge(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('ID: ${skill.userId}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => context.push('/profile/${skill.userId}'),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('View Profile'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _infoRow('Description', skill.description),
                  _infoRow('Category', skill.category),
                  _infoRow('Level', skill.level.name),
                  _infoRow('Format', skill.format.name),
                  _infoRow('Type', skill.type.name),
                  if (skill.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Tags',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: skill.tags
                          .map((tag) => Chip(label: Text(tag)))
                          .toList(),
                    ),
                  ],
                  if (skill.portfolioUrls.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Portfolio',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...skill.portfolioUrls.map(
                      (url) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: InkWell(
                          onTap: () {}, // Future: open URL
                          child: Text(
                            url,
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (!skill.isVerified) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _showVerificationDialog(skill),
                        icon: const Icon(Icons.verified_outlined),
                        label: const Text('Submit for Verification'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          if (state is SkillError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SkillBloc>().add(
                          ViewSkillDetailsRequested(id: widget.skillId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Loading...'));
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Verified expertise',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, size: 16, color: Colors.green.shade700),
            const SizedBox(width: 4),
            Text(
              'Verified',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
