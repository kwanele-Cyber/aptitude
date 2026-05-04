import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';

class FetchUserSkillsUseCase
    implements UseCase<List<SkillEntity>, FetchUserSkillsParams> {
  final SkillRepository repository;

  FetchUserSkillsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<SkillEntity>>> call(
      FetchUserSkillsParams params) async {
    return repository.fetchUserSkills(params.uid);
  }
}

class FetchUserSkillsParams {
  final String uid;

  const FetchUserSkillsParams({required this.uid});
}
