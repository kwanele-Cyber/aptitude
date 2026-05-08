import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/ai/data/datasources/ai_remote_datasource.dart';
import 'package:myapp/features/ai/domain/entities/behavior_flag_entity.dart';
import 'package:myapp/features/ai/domain/entities/match_optimization_entity.dart';
import 'package:myapp/features/ai/domain/entities/session_prediction_entity.dart';
import 'package:myapp/features/ai/domain/entities/skill_recommendation_entity.dart';
import 'package:myapp/features/ai/domain/repository/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource remoteDataSource;

  AiRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SkillRecommendationEntity>>>
      getSkillRecommendations(String userId) async {
    try {
      final models = await remoteDataSource.getSkillRecommendations(userId);
      return Right(models);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<BehaviorFlagEntity>>> analyzeBehavior(
      String userId) async {
    try {
      final models = await remoteDataSource.analyzeBehavior(userId);
      return Right(models);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<MatchOptimizationEntity>>> getMatchOptimizations(
      String userId) async {
    try {
      final models = await remoteDataSource.getMatchOptimizations(userId);
      return Right(models);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SessionPredictionEntity>> predictSessionQuality(
      String matchId) async {
    try {
      final model = await remoteDataSource.predictSessionQuality(matchId);
      return Right(model);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
