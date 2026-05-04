import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';

class GetSkillByIdUseCase {
  final SkillRepository repository;

  GetSkillByIdUseCase({required this.repository});

  Future<Either<Failure, SkillEntity>> call(GetSkillByIdParams params) async {
    return repository.getSkillById(params.id);
  }
}

class GetSkillByIdParams extends Equatable {
  final String id;

  const GetSkillByIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}
