import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/feedback/domain/entities/feedback_entity.dart';

abstract class FeedbackRepository {
  Future<Either<Failure, FeedbackEntity>> submitRating(
    String sessionId,
    String reviewerId,
    String reviewerName,
    String revieweeId,
    String revieweeName,
    int rating,
  );

  Future<Either<Failure, FeedbackEntity>> writeReview(
    String feedbackId,
    String review,
  );

  Future<Either<Failure, List<FeedbackEntity>>> viewReviews(
    String userId, {
    int? minRating,
    int? maxRating,
  });

  Future<Either<Failure, FeedbackEntity>> editReview(
    String feedbackId,
    String review,
  );

  Future<Either<Failure, FeedbackEntity>> respondToReview(
    String feedbackId,
    String response,
  );

  Future<Either<Failure, List<FeedbackEntity>>> getSessionFeedback(
      String sessionId);
}
