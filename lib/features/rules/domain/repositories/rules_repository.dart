import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/rules/domain/entities/platform_rule_entity.dart';

abstract class RulesRepository {
  Future<Either<Failure, List<PlatformRuleEntity>>> getPlatformRules();
}
