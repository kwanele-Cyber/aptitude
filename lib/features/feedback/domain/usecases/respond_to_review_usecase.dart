import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/feedback/domain/entities/feedback_entity.dart';
import 'package:myapp/features/feedback/domain/repository/feedback_repository.dart';

class RespondToReviewUseCase {
  final FeedbackRepository repository;

  RespondToReviewUseCase({required this.repository});

  Future<Either<Failure, FeedbackEntity>> call(
      RespondToReviewParams params) async {
    return repository.respondToReview(params.feedbackId, params.response);
  }
}

class RespondToReviewParams extends Equatable {
  final String feedbackId;
  final String response;

  const RespondToReviewParams({
    required this.feedbackId,
    required this.response,
  });

  @override
  List<Object?> get props => [feedbackId, response];
}
