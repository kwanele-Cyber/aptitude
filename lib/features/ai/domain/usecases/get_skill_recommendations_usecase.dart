import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/ai/domain/entities/skill_recommendation_entity.dart';
import 'package:myapp/features/ai/domain/repository/ai_repository.dart';

class GetSkillRecommendationsUseCase {
  final AiRepository repository;

  GetSkillRecommendationsUseCase({required this.repository});

  Future<Either<Failure, List<SkillRecommendationEntity>>> call(
      GetSkillRecommendationsParams params) async {
    return repository.getSkillRecommendations(params.userId);
  }
}

class GetSkillRecommendationsParams extends Equatable {
  final String userId;

  const GetSkillRecommendationsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
