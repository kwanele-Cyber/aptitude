import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/progress/domain/entity/learning_goal_entity.dart';
import 'package:myapp/features/progress/domain/entity/skill_progress_entity.dart';

abstract class ProgressRepository {
  Future<Either<Failure, void>> trackProgress({
    required String userId,
    required String skillId,
    required String skillTitle,
    double hoursLogged = 0,
    int sessionsCompleted = 0,
    int xpGained = 0,
  });
  Future<Either<Failure, List<SkillProgressEntity>>> fetchProgress(
      String userId);
  Future<Either<Failure, void>> setGoal(LearningGoalEntity goal);
  Future<Either<Failure, List<LearningGoalEntity>>> fetchGoals(String userId);
  Future<Either<Failure, void>> updateGoalProgress(
      String goalId, int progressPercent);
  Future<Either<Failure, void>> shareAchievement(
      String progressId, String milestone);
}
