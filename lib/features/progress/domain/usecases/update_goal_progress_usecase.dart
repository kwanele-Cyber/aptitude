import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/progress/domain/repository/progress_repository.dart';

class UpdateGoalProgressUseCase {
  final ProgressRepository repository;

  UpdateGoalProgressUseCase({required this.repository});

  Future<Either<Failure, void>> call(UpdateGoalProgressParams params) async {
    return repository.updateGoalProgress(
        params.goalId, params.progressPercent);
  }
}

class UpdateGoalProgressParams extends Equatable {
  final String goalId;
  final int progressPercent;

  const UpdateGoalProgressParams({
    required this.goalId,
    required this.progressPercent,
  });

  @override
  List<Object?> get props => [goalId, progressPercent];
}
