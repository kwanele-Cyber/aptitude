import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/progress/data/datasources/progress_remote_datasource.dart';
import 'package:myapp/features/progress/data/models/learning_goal_model.dart';
import 'package:myapp/features/progress/data/models/skill_progress_model.dart';

class ProgressRemoteDataSourceFirebase implements ProgressRemoteDataSource {
  final FirebaseDatabase _database;

  ProgressRemoteDataSourceFirebase({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  DatabaseReference _progressRef(String userId) =>
      _database.ref('progress').child(userId);

  DatabaseReference _goalsRef(String userId) =>
      _database.ref('learningGoals').child(userId);

  @override
  Future<SkillProgressModel> trackProgress({
    required String userId,
    required String skillId,
    required String skillTitle,
    double hoursLogged = 0,
    int sessionsCompleted = 0,
    int xpGained = 0,
  }) async {
    try {
      final progressKey = '${skillId}_progress';
      final ref = _progressRef(userId).child(progressKey);
      final snapshot = await ref.get();

      SkillProgressModel existing;
      if (snapshot.exists && snapshot.value != null) {
        existing = SkillProgressModel.fromJson(
          progressKey,
          Map<String, dynamic>.from(snapshot.value as Map),
        );
      } else {
        existing = SkillProgressModel(
          id: progressKey,
          userId: userId,
          skillId: skillId,
          skillTitle: skillTitle,
          updatedAt: DateTime.now(),
        );
      }

      final updated = SkillProgressModel(
        id: progressKey,
        userId: userId,
        skillId: skillId,
        skillTitle: skillTitle,
        xpPoints: existing.xpPoints + xpGained,
        hoursLogged: existing.hoursLogged + hoursLogged,
        sessionsCompleted: existing.sessionsCompleted + sessionsCompleted,
        currentStreak: sessionsCompleted > 0
            ? existing.currentStreak + 1
            : existing.currentStreak,
        lastPracticedAt: sessionsCompleted > 0 || hoursLogged > 0
            ? DateTime.now()
            : existing.lastPracticedAt,
        milestones: _checkMilestones(
          existing.xpPoints + xpGained,
          existing.milestones,
        ),
        updatedAt: DateTime.now(),
      );

      await ref.set(updated.toJson());
      return updated;
    } catch (e) {
      throw ServerException();
    }
  }

  List<String> _checkMilestones(int totalXp, List<String> existing) {
    final newMilestones = List<String>.from(existing);
    final milestoneXp = [100, 500, 1000, 2500, 5000];
    for (final xp in milestoneXp) {
      final label = 'Earned ${xp}XP';
      if (totalXp >= xp && !newMilestones.contains(label)) {
        newMilestones.add(label);
      }
    }
    return newMilestones;
  }

  @override
  Future<List<SkillProgressModel>> fetchProgress(String userId) async {
    try {
      final snapshot = await _progressRef(userId).get();
      if (!snapshot.exists) return [];

      final map =
          snapshot.value is Map ? Map<String, dynamic>.from(snapshot.value as Map) : null;
      if (map == null) return [];

      final list = <SkillProgressModel>[];
      map.forEach((key, value) {
        list.add(SkillProgressModel.fromJson(
            key, Map<String, dynamic>.from(value as Map)));
      });
      return list;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> setGoal(LearningGoalModel goal) async {
    try {
      await _goalsRef(goal.userId).child(goal.id).set(goal.toJson());
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<LearningGoalModel>> fetchGoals(String userId) async {
    try {
      final snapshot = await _goalsRef(userId).get();
      if (!snapshot.exists) return [];

      final map =
          snapshot.value is Map ? Map<String, dynamic>.from(snapshot.value as Map) : null;
      if (map == null) return [];

      final list = <LearningGoalModel>[];
      map.forEach((key, value) {
        list.add(LearningGoalModel.fromJson(
            key, Map<String, dynamic>.from(value as Map)));
      });
      return list;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> updateGoalProgress(String goalId, int progressPercent) async {
    try {
      final parts = goalId.split('_');
      if (parts.length < 2) return;
      final userId = parts[0];
      await _goalsRef(userId).child(goalId).update({
        'progressPercent': progressPercent,
      });
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> shareAchievement(String progressId, String milestone) async {
    try {
      final parts = progressId.split('_');
      if (parts.length < 2) return;
      final userId = parts[0];
      final ref = _progressRef(userId).child(progressId);
      final snapshot = await ref.get();
      if (!snapshot.exists || snapshot.value == null) return;

      final existing = SkillProgressModel.fromJson(
        progressId,
        Map<String, dynamic>.from(snapshot.value as Map),
      );

      final sharedMilestones = List<String>.from(existing.milestones);
      final sharedLabel = '[Shared] $milestone';
      if (!sharedMilestones.contains(sharedLabel)) {
        sharedMilestones.add(sharedLabel);
      }

      await ref.update({'milestones': sharedMilestones});
    } catch (e) {
      throw ServerException();
    }
  }
}
