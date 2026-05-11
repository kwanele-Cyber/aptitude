import 'package:myapp/features/ai/domain/entities/skill_recommendation_entity.dart';

class SkillRecommendationModel extends SkillRecommendationEntity {
  const SkillRecommendationModel({
    required super.id,
    required super.skillTitle,
    required super.category,
    required super.reason,
    required super.confidenceScore,
    required super.type,
  });

  factory SkillRecommendationModel.fromJson(Map<String, dynamic> json) {
    return SkillRecommendationModel(
      id: json['id'] as String? ?? json['uid'] as String? ?? '',
      skillTitle: json['skillTitle'] as String? ?? '',
      category: json['category'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      type: RecommendationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RecommendationType.learn,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'skillTitle': skillTitle,
        'category': category,
        'reason': reason,
        'confidenceScore': confidenceScore,
        'type': type.name,
      };
}
