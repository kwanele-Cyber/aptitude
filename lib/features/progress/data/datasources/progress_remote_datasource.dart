import 'package:myapp/features/progress/data/models/learning_goal_model.dart';
import 'package:myapp/features/progress/data/models/skill_progress_model.dart';

abstract class ProgressRemoteDataSource {
  Future<SkillProgressModel> trackProgress({
    required String userId,
    required String skillId,
    required String skillTitle,
    double hoursLogged = 0,
    int sessionsCompleted = 0,
    int xpGained = 0,
  });
  Future<List<SkillProgressModel>> fetchProgress(String userId);
  Future<void> setGoal(LearningGoalModel goal);
  Future<List<LearningGoalModel>> fetchGoals(String userId);
  Future<void> updateGoalProgress(String goalId, int progressPercent);
  Future<void> shareAchievement(String progressId, String milestone);
}

