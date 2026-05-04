import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';

class ArchiveSkillUseCase implements UseCase<void, ArchiveSkillParams> {
  final SkillRepository repository;

  ArchiveSkillUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(ArchiveSkillParams params) async {
    return repository.archiveSkill(params.id);
  }
}

class ArchiveSkillParams {
  final String id;

  const ArchiveSkillParams({required this.id});
}
