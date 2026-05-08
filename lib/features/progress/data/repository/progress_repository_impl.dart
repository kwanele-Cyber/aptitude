import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/progress/data/datasources/progress_remote_datasource.dart';
import 'package:myapp/features/progress/data/models/learning_goal_model.dart';
import 'package:myapp/features/progress/domain/entity/learning_goal_entity.dart';
import 'package:myapp/features/progress/domain/entity/skill_progress_entity.dart';
import 'package:myapp/features/progress/domain/repository/progress_repository.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressRemoteDataSource remoteDataSource;

  ProgressRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> trackProgress({
    required String userId,
    required String skillId,
    required String skillTitle,
    double hoursLogged = 0,
    int sessionsCompleted = 0,
    int xpGained = 0,
  }) async {
    try {
      await remoteDataSource.trackProgress(
        userId: userId,
        skillId: skillId,
        skillTitle: skillTitle,
        hoursLogged: hoursLogged,
        sessionsCompleted: sessionsCompleted,
        xpGained: xpGained,
      );
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SkillProgressEntity>>> fetchProgress(
      String userId) async {
    try {
      final progress = await remoteDataSource.fetchProgress(userId);
      return Right(progress);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> setGoal(LearningGoalEntity goal) async {
    try {
      await remoteDataSource.setGoal(
          goal as LearningGoalModel); // will be model from datasource
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<LearningGoalEntity>>> fetchGoals(
      String userId) async {
    try {
      final goals = await remoteDataSource.fetchGoals(userId);
      return Right(goals);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateGoalProgress(
      String goalId, int progressPercent) async {
    try {
      await remoteDataSource.updateGoalProgress(goalId, progressPercent);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> shareAchievement(
      String progressId, String milestone) async {
    try {
      await remoteDataSource.shareAchievement(progressId, milestone);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
