import 'package:equatable/equatable.dart';

enum RecommendationType { learn, teach }

class SkillRecommendationEntity extends Equatable {
  final String id;
  final String skillTitle;
  final String category;
  final String reason;
  final double confidenceScore;
  final RecommendationType type;

  const SkillRecommendationEntity({
    required this.id,
    required this.skillTitle,
    required this.category,
    required this.reason,
    required this.confidenceScore,
    required this.type,
  });

  @override
  List<Object?> get props => [
        id,
        skillTitle,
        category,
        reason,
        confidenceScore,
        type,
      ];
}
