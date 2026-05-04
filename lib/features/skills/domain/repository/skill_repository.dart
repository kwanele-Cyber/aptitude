import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';

abstract class SkillRepository {
  Future<Either<Failure, SkillEntity>> createSkill(Map<String, dynamic> data);
  Future<Either<Failure, SkillEntity>> updateSkill(
      String id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteSkill(String id);
  Future<Either<Failure, List<SkillEntity>>> fetchUserSkills(String uid);
  Future<Either<Failure, SkillEntity>> getSkillById(String id);
  Future<Either<Failure, void>> archiveSkill(String id);
  Future<Either<Failure, void>> restoreSkill(String id);
}
