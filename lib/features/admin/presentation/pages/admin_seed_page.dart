import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:myapp/features/admin/presentation/bloc/admin_event.dart';
import 'package:myapp/features/admin/presentation/bloc/admin_state.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_app_bar.dart';

class AdminSeedPage extends StatelessWidget {
  const AdminSeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(child: Text('Not available in release mode')),
      );
    }

    final theme = Theme.of(context);
    return Scaffold(
      appBar: const AdminAppBar(title: 'Seed Database'),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminSeedInProgress) {
            return _buildProgress(context, theme, state);
          }
          if (state is AdminSeedComplete) {
            return _buildComplete(context, theme, state);
          }
          if (state is AdminSeedError) {
            return _buildError(context, theme, state);
          }
          return _buildIdle(context, theme);
        },
      ),
    );
  }

  Widget _buildIdle(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.science, size: 40, color: Colors.amber),
            ),
            const SizedBox(height: 24),
            Text(
              'Seed Development Database',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This will create test users, skills, and matches in your Firebase database. Only run this in development.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, size: 20, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Seeded data uses shared password: SeedPassword123!',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  context.read<AdminBloc>().add(AdminSeedDatabase());
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Run Seeder'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress(BuildContext context, ThemeData theme, AdminSeedInProgress state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: state.progress > 0 ? state.progress : null,
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              state.step,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: state.progress,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(state.progress * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplete(BuildContext context, ThemeData theme, AdminSeedComplete state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 28),
              ),
              const SizedBox(width: 16),
              Text(
                'Seeding Complete',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in state.results)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      line,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: line.startsWith('   ')
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        fontWeight: line.contains('SEED COMPLETE') ||
                                line.contains('LOGIN CREDENTIALS')
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                context.read<AdminBloc>().add(AdminSeedDatabase());
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Run Again'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, ThemeData theme, AdminSeedError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, size: 40, color: Colors.red),
            ),
            const SizedBox(height: 24),
            Text(
              'Seed Failed',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                context.read<AdminBloc>().add(AdminSeedDatabase());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
