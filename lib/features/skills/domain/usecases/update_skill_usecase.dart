import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';

class UpdateSkillUseCase implements UseCase<SkillEntity, UpdateSkillParams> {
  final SkillRepository repository;

  UpdateSkillUseCase({required this.repository});

  @override
  Future<Either<Failure, SkillEntity>> call(UpdateSkillParams params) async {
    return repository.updateSkill(params.id, {
      'title': params.title,
      'description': params.description,
      'category': params.category,
      'type': params.type.name,
      'level': params.level.name,
      'format': params.format.name,
      'tags': params.tags,
    });
  }
}

class UpdateSkillParams {
  final String id;
  final String title;
  final String description;
  final String category;
  final SkillType type;
  final SkillLevel level;
  final SkillFormat format;
  final List<String> tags;

  const UpdateSkillParams({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.type = SkillType.offer,
    required this.level,
    required this.format,
    this.tags = const [],
  });
}
