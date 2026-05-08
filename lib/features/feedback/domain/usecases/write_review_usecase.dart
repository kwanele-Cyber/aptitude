import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/feedback/domain/entities/feedback_entity.dart';
import 'package:myapp/features/feedback/domain/repository/feedback_repository.dart';

class WriteReviewUseCase {
  final FeedbackRepository repository;

  WriteReviewUseCase({required this.repository});

  Future<Either<Failure, FeedbackEntity>> call(WriteReviewParams params) async {
    return repository.writeReview(params.feedbackId, params.review);
  }
}

class WriteReviewParams extends Equatable {
  final String feedbackId;
  final String review;

  const WriteReviewParams({
    required this.feedbackId,
    required this.review,
  });

  @override
  List<Object?> get props => [feedbackId, review];
}
