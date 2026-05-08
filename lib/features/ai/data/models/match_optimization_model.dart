import 'package:myapp/features/ai/domain/entities/match_optimization_entity.dart';

class MatchOptimizationModel extends MatchOptimizationEntity {
  const MatchOptimizationModel({
    required super.id,
    required super.metric,
    required super.currentValue,
    required super.suggestedValue,
    required super.insight,
    required super.impact,
  });

  factory MatchOptimizationModel.fromJson(Map<String, dynamic> json) {
    return MatchOptimizationModel(
      id: json['id'] as String,
      metric: json['metric'] as String,
      currentValue: (json['currentValue'] as num).toDouble(),
      suggestedValue: (json['suggestedValue'] as num).toDouble(),
      insight: json['insight'] as String,
      impact: json['impact'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'metric': metric,
        'currentValue': currentValue,
        'suggestedValue': suggestedValue,
        'insight': insight,
        'impact': impact,
      };
}
