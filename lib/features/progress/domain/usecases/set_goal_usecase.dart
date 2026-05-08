import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/progress/domain/entity/learning_goal_entity.dart';
import 'package:myapp/features/progress/domain/repository/progress_repository.dart';

class SetGoalUseCase {
  final ProgressRepository repository;

  SetGoalUseCase({required this.repository});

  Future<Either<Failure, void>> call(SetGoalParams params) async {
    return repository.setGoal(params.goal);
  }
}

class SetGoalParams extends Equatable {
  final LearningGoalEntity goal;

  const SetGoalParams({required this.goal});

  @override
  List<Object?> get props => [goal];
}
