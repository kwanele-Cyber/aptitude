import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AiHubPage extends StatelessWidget {
  const AiHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Insights'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'AI-Powered Intelligence',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Smart recommendations and insights powered by machine learning',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          _AiFeatureCard(
            icon: Icons.lightbulb_outline,
            title: 'Skill Recommendations',
            subtitle: 'AI suggests skills to learn or teach based on your profile',
            color: const Color(0xFFF0F4FF),
            iconColor: const Color(0xFF5F5CFF),
            onTap: () => context.push('/ai/recommendations'),
          ),
          const SizedBox(height: 12),
          _AiFeatureCard(
            icon: Icons.shield_outlined,
            title: 'Behavior Analysis',
            subtitle: 'Fraud detection and anomaly alerting',
            color: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFE65100),
            onTap: () => context.push('/ai/behavior'),
          ),
          const SizedBox(height: 12),
          _AiFeatureCard(
            icon: Icons.trending_up,
            title: 'Match Optimization',
            subtitle: 'Continuous ML model improvement insights',
            color: const Color(0xFFE8F5E9),
            iconColor: const Color(0xFF2E7D32),
            onTap: () => context.push('/ai/optimization'),
          ),
          const SizedBox(height: 12),
          _AiFeatureCard(
            icon: Icons.analytics_outlined,
            title: 'Session Quality Prediction',
            subtitle: 'Predict likely positive matches before you commit',
            color: const Color(0xFFF3E5F5),
            iconColor: const Color(0xFF7B1FA2),
            onTap: () => context.push('/ai/prediction'),
          ),
        ],
      ),
    );
  }
}

class _AiFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _AiFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
