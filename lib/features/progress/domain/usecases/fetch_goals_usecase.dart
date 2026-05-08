import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/progress/domain/entity/learning_goal_entity.dart';
import 'package:myapp/features/progress/domain/repository/progress_repository.dart';

class FetchGoalsUseCase {
  final ProgressRepository repository;

  FetchGoalsUseCase({required this.repository});

  Future<Either<Failure, List<LearningGoalEntity>>> call(
      FetchGoalsParams params) async {
    return repository.fetchGoals(params.userId);
  }
}

class FetchGoalsParams extends Equatable {
  final String userId;

  const FetchGoalsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
