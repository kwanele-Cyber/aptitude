import 'package:equatable/equatable.dart';

class MatchOptimizationEntity extends Equatable {
  final String id;
  final String metric;
  final double currentValue;
  final double suggestedValue;
  final String insight;
  final String impact;

  const MatchOptimizationEntity({
    required this.id,
    required this.metric,
    required this.currentValue,
    required this.suggestedValue,
    required this.insight,
    required this.impact,
  });

  @override
  List<Object?> get props => [
        id,
        metric,
        currentValue,
        suggestedValue,
        insight,
        impact,
      ];
}
