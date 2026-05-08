import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/progress/domain/repository/progress_repository.dart';

class ShareAchievementUseCase {
  final ProgressRepository repository;

  ShareAchievementUseCase({required this.repository});

  Future<Either<Failure, void>> call(ShareAchievementParams params) async {
    return repository.shareAchievement(
        params.progressId, params.milestone);
  }
}

class ShareAchievementParams extends Equatable {
  final String progressId;
  final String milestone;

  const ShareAchievementParams({
    required this.progressId,
    required this.milestone,
  });

  @override
  List<Object?> get props => [progressId, milestone];
}
