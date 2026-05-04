import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';

class SubmitSkillVerificationUseCase {
  final SkillRepository repository;

  SubmitSkillVerificationUseCase({required this.repository});

  Future<Either<Failure, SkillEntity>> call(
      SubmitSkillVerificationParams params) async {
    return repository.updateSkill(params.skillId, {
      'isVerified': true,
      'portfolioUrls': params.portfolioUrls,
    });
  }
}

class SubmitSkillVerificationParams extends Equatable {
  final String skillId;
  final List<String> portfolioUrls;

  const SubmitSkillVerificationParams({
    required this.skillId,
    this.portfolioUrls = const [],
  });

  @override
  List<Object?> get props => [skillId, portfolioUrls];
}
