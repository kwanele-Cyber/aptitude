import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/feedback/domain/entities/feedback_entity.dart';
import 'package:myapp/features/feedback/domain/repository/feedback_repository.dart';

class EditReviewUseCase {
  final FeedbackRepository repository;

  EditReviewUseCase({required this.repository});

  Future<Either<Failure, FeedbackEntity>> call(EditReviewParams params) async {
    if (params.review.trim().isEmpty) {
      return Left(ServerFailure('Review cannot be empty'));
    }
    return repository.editReview(params.feedbackId, params.review);
  }
}

class EditReviewParams extends Equatable {
  final String feedbackId;
  final String review;

  const EditReviewParams({
    required this.feedbackId,
    required this.review,
  });

  @override
  List<Object?> get props => [feedbackId, review];
}
