import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';

class CloneSkillUseCase implements UseCase<SkillEntity, CloneSkillParams> {
  final SkillRepository repository;

  CloneSkillUseCase({required this.repository});

  @override
  Future<Either<Failure, SkillEntity>> call(CloneSkillParams params) async {
    final result = await repository.getSkillById(params.skillId);
    return result.fold(
      (failure) => Left(failure),
      (skill) => repository.createSkill({
        'title': skill.title,
        'description': skill.description,
        'category': skill.category,
        'type': skill.type.name,
        'level': skill.level.name,
        'format': skill.format.name,
        'tags': skill.tags,
      }),
    );
  }
}

class CloneSkillParams {
  final String skillId;

  const CloneSkillParams({required this.skillId});
}
