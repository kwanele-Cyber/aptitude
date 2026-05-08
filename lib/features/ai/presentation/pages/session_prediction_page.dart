import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_bloc.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_event.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_state.dart';

Color qualityColorForQuality(double quality) {
  if (quality >= 0.7) return const Color(0xFF2E7D32);
  if (quality >= 0.4) return Colors.orange;
  return Colors.red;
}

class SessionPredictionPage extends StatefulWidget {
  final String matchId;

  const SessionPredictionPage({super.key, required this.matchId});

  @override
  State<SessionPredictionPage> createState() => _SessionPredictionPageState();
}

class _SessionPredictionPageState extends State<SessionPredictionPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<AiBloc>()
        .add(PredictSessionQuality(matchId: widget.matchId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Quality Prediction'),
        centerTitle: true,
      ),
      body: BlocBuilder<AiBloc, AiState>(
        builder: (context, state) {
          if (state is AiLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AiError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 56, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        context.read<AiBloc>().add(PredictSessionQuality(
                            matchId: widget.matchId));
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is SessionPredictionLoaded) {
            final prediction = state.prediction;
            final qualityPercent =
                (prediction.predictedQuality * 100).toInt();
            final confidencePercent =
                (prediction.confidence * 100).toInt();

            final qualityColor = qualityColorForQuality(prediction.predictedQuality);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quality Score Gauge
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            qualityColor.withValues(alpha: 0.1),
                            qualityColor.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Predicted Session Quality',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 160,
                                  height: 160,
                                  child: CircularProgressIndicator(
                                    value: prediction.predictedQuality,
                                    strokeWidth: 12,
                                    backgroundColor: theme
                                        .colorScheme.surfaceContainerHighest,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        qualityColor),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$qualityPercent%',
                                      style:
                                          theme.textTheme.headlineLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: qualityColor,
                                      ),
                                    ),
                                    Text(
                                      'Quality',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: qualityColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$confidencePercent% Confidence',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: qualityColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Key Factors
                  Text(
                    'Key Factors',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Factors that influenced this prediction',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...prediction.keyFactors.map((factor) => _FactorTile(
                        factor: factor,
                        theme: theme,
                      )),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _FactorTile extends StatelessWidget {
  final String factor;
  final ThemeData theme;

  const _FactorTile({required this.factor, required this.theme});

  @override
  Widget build(BuildContext context) {
    final label = factor.replaceAll('_', ' ');
    final capitalized =
        label.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');

    IconData icon;
    switch (factor) {
      case 'complementary_skill_levels':
        icon = Icons.balance;
        break;
      case 'availability_overlap':
        icon = Icons.schedule;
        break;
      case 'historical_completion_rate':
        icon = Icons.history;
        break;
      default:
        icon = Icons.check_circle_outline;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              capitalized,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.check_circle,
                size: 18,
                color: const Color(0xFF2E7D32)),
          ],
        ),
      ),
    );
  }
}
