import 'package:equatable/equatable.dart';

class SkillProgressEntity extends Equatable {
  final String id;
  final String userId;
  final String skillId;
  final String skillTitle;
  final int xpPoints;
  final double hoursLogged;
  final int sessionsCompleted;
  final int currentStreak;
  final DateTime? lastPracticedAt;
  final List<String> milestones;
  final DateTime updatedAt;

  const SkillProgressEntity({
    required this.id,
    required this.userId,
    required this.skillId,
    required this.skillTitle,
    this.xpPoints = 0,
    this.hoursLogged = 0,
    this.sessionsCompleted = 0,
    this.currentStreak = 0,
    this.lastPracticedAt,
    this.milestones = const [],
    required this.updatedAt,
  });

  int get level {
    if (xpPoints >= 5000) return 10;
    if (xpPoints >= 2500) return 8;
    if (xpPoints >= 1000) return 5;
    if (xpPoints >= 500) return 3;
    if (xpPoints >= 100) return 2;
    return 1;
  }

  int get xpToNextLevel {
    if (level >= 10) return 0;
    final thresholds = [0, 100, 500, 1000, 2500, 5000];
    final nextThreshold = thresholds.length > level ? thresholds[level] : 5000;
    return nextThreshold - xpPoints;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        skillId,
        skillTitle,
        xpPoints,
        hoursLogged,
        sessionsCompleted,
        currentStreak,
        lastPracticedAt,
        milestones,
        updatedAt,
      ];
}
