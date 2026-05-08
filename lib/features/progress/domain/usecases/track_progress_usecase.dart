import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/progress/domain/repository/progress_repository.dart';

class TrackProgressUseCase {
  final ProgressRepository repository;

  TrackProgressUseCase({required this.repository});

  Future<Either<Failure, void>> call(TrackProgressParams params) async {
    return repository.trackProgress(
      userId: params.userId,
      skillId: params.skillId,
      skillTitle: params.skillTitle,
      hoursLogged: params.hoursLogged,
      sessionsCompleted: params.sessionsCompleted,
      xpGained: params.xpGained,
    );
  }
}

class TrackProgressParams extends Equatable {
  final String userId;
  final String skillId;
  final String skillTitle;
  final double hoursLogged;
  final int sessionsCompleted;
  final int xpGained;

  const TrackProgressParams({
    required this.userId,
    required this.skillId,
    required this.skillTitle,
    this.hoursLogged = 0,
    this.sessionsCompleted = 0,
    this.xpGained = 0,
  });

  @override
  List<Object?> get props =>
      [userId, skillId, skillTitle, hoursLogged, sessionsCompleted, xpGained];
}
