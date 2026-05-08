import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/progress/domain/entity/skill_progress_entity.dart';
import 'package:myapp/features/progress/domain/repository/progress_repository.dart';

class FetchProgressUseCase {
  final ProgressRepository repository;

  FetchProgressUseCase({required this.repository});

  Future<Either<Failure, List<SkillProgressEntity>>> call(
      FetchProgressParams params) async {
    return repository.fetchProgress(params.userId);
  }
}

class FetchProgressParams extends Equatable {
  final String userId;

  const FetchProgressParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
