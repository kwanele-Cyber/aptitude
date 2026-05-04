import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';

class CreateSkillOfferUseCase
    implements UseCase<SkillEntity, CreateSkillOfferParams> {
  final SkillRepository repository;

  CreateSkillOfferUseCase({required this.repository});

  @override
  Future<Either<Failure, SkillEntity>> call(
      CreateSkillOfferParams params) async {
    return repository.createSkill({
      'title': params.title,
      'description': params.description,
      'category': params.category,
      'level': params.level.name,
      'format': params.format.name,
      'tags': params.tags,
    });
  }
}

class CreateSkillOfferParams {
  final String title;
  final String description;
  final String category;
  final SkillLevel level;
  final SkillFormat format;
  final List<String> tags;

  CreateSkillOfferParams({
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.format,
    this.tags = const [],
  });
}
