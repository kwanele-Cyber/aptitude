import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';

class DeleteSkillUseCase implements UseCase<void, DeleteSkillParams> {
  final SkillRepository repository;

  DeleteSkillUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(DeleteSkillParams params) async {
    return repository.deleteSkill(params.id);
  }
}

class DeleteSkillParams {
  final String id;

  const DeleteSkillParams({required this.id});
}
