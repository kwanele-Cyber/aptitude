import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/rules/data/datasources/rules_remote_datasource.dart';
import 'package:myapp/features/rules/domain/entities/platform_rule_entity.dart';
import 'package:myapp/features/rules/domain/repositories/rules_repository.dart';

class RulesRepositoryImpl implements RulesRepository {
  final RulesRemoteDataSource remoteDataSource;

  RulesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PlatformRuleEntity>>> getPlatformRules() async {
    try {
      final rules = await remoteDataSource.getPlatformRules();
      return Right(rules);
    } catch (e) {
      return Left(ServerFailure('Failed to load platform rules.'));
    }
  }
}
