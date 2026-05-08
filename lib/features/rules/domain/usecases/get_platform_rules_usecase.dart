import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/rules/domain/entities/platform_rule_entity.dart';
import 'package:myapp/features/rules/domain/repositories/rules_repository.dart';

class GetPlatformRulesUseCase {
  final RulesRepository repository;
  GetPlatformRulesUseCase({required this.repository});

  Future<Either<Failure, List<PlatformRuleEntity>>> call() {
    return repository.getPlatformRules();
  }
}
