import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/rules/presentation/bloc/rules_bloc.dart';
import 'package:myapp/features/rules/presentation/bloc/rules_event.dart';
import 'package:myapp/features/rules/presentation/bloc/rules_state.dart';

class PlatformRulesPage extends StatefulWidget {
  const PlatformRulesPage({super.key});

  @override
  State<PlatformRulesPage> createState() => _PlatformRulesPageState();
}

class _PlatformRulesPageState extends State<PlatformRulesPage> {
  @override
  void initState() {
    super.initState();
    context.read<RulesBloc>().add(GetPlatformRulesRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Guidelines'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<RulesBloc, RulesState>(
        builder: (context, state) {
          if (state is RulesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RulesError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        context
                            .read<RulesBloc>()
                            .add(GetPlatformRulesRequested());
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is RulesLoaded) {
            final rules = state.rules;
            if (rules.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.rule_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'No rules defined yet.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Group rules by category
            final grouped = <String, List<_RuleItem>>{};
            for (final rule in rules) {
              grouped.putIfAbsent(rule.category, () => []).add(
                  _RuleItem(rule.title, rule.description, rule.order));
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                        theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.auto_awesome,
                          color: theme.colorScheme.primary, size: 32),
                      const SizedBox(height: 12),
                      Text(
                        'Welcome to Aptitude',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Our community guidelines help maintain a safe, respectful, '
                        'and productive environment for everyone. Please take a moment '
                        'to review the rules below.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ...grouped.entries.map((entry) => _buildCategory(
                    context, entry.key, entry.value)),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCategory(
      BuildContext context, String category, List<_RuleItem> rules) {
    final theme = Theme.of(context);
    final categoryIcons = <String, IconData>{
      'Conduct': Icons.people_outline,
      'Commitments': Icons.handshake_outlined,
      'Privacy': Icons.lock_outline,
      'Community': Icons.groups_outlined,
      'Security': Icons.shield_outlined,
      'General': Icons.info_outline,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                categoryIcons[category] ?? Icons.info_outline,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                category,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rules.map((rule) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _RuleCard(
                  number: rule.order,
                  title: rule.title,
                  description: rule.description,
                ),
              )),
        ],
      ),
    );
  }
}

class _RuleItem {
  final String title;
  final String description;
  final int order;
  _RuleItem(this.title, this.description, this.order);
}

class _RuleCard extends StatelessWidget {
  final int number;
  final String title;
  final String description;

  const _RuleCard({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
