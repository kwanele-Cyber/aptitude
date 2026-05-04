import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';

class RestoreSkillUseCase implements UseCase<void, RestoreSkillParams> {
  final SkillRepository repository;

  RestoreSkillUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(RestoreSkillParams params) async {
    return repository.restoreSkill(params.id);
  }
}

class RestoreSkillParams {
  final String id;

  const RestoreSkillParams({required this.id});
}
