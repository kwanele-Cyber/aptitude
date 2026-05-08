import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/feedback/data/datasources/feedback_remote_datasource.dart';
import 'package:myapp/features/feedback/data/models/feedback_model.dart';
import 'package:myapp/features/feedback/domain/entities/feedback_entity.dart';
import 'package:myapp/features/feedback/domain/repository/feedback_repository.dart';
import 'package:uuid/uuid.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource remoteDataSource;

  FeedbackRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, FeedbackEntity>> submitRating(
    String sessionId,
    String reviewerId,
    String reviewerName,
    String revieweeId,
    String revieweeName,
    int rating,
  ) async {
    try {
      final clamped = rating.clamp(1, 5);
      final now = DateTime.now();
      final feedback = FeedbackModel(
        id: const Uuid().v4(),
        sessionId: sessionId,
        reviewerId: reviewerId,
        reviewerName: reviewerName,
        revieweeId: revieweeId,
        revieweeName: revieweeName,
        rating: clamped,
        createdAt: now,
        updatedAt: now,
      );

      await remoteDataSource.createFeedback(feedback);
      return Right(feedback);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, FeedbackEntity>> writeReview(
    String feedbackId,
    String review,
  ) async {
    try {
      final now = DateTime.now();
      await remoteDataSource.updateFeedback(feedbackId, {
        'review': review,
        'updatedAt': now.toIso8601String(),
      });

      final updated = await remoteDataSource.getFeedback(feedbackId);
      if (updated == null) {
        return Left(ServerFailure('Feedback not found'));
      }
      return Right(updated);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<FeedbackEntity>>> viewReviews(
    String userId, {
    int? minRating,
    int? maxRating,
  }) async {
    try {
      final feedbacks = await remoteDataSource.fetchFeedbacksForUser(userId);

      var filtered = feedbacks.where((f) {
        if (minRating != null && f.rating < minRating) return false;
        if (maxRating != null && f.rating > maxRating) return false;
        return true;
      }).toList();

      return Right(filtered);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, FeedbackEntity>> editReview(
    String feedbackId,
    String review,
  ) async {
    try {
      final existing = await remoteDataSource.getFeedback(feedbackId);
      if (existing == null) {
        return Left(ServerFailure('Feedback not found'));
      }

      if (!existing.canEditReview) {
        return Left(ServerFailure(
            'Review can only be edited within 48 hours of submission'));
      }

      final now = DateTime.now();
      await remoteDataSource.updateFeedback(feedbackId, {
        'review': review,
        'updatedAt': now.toIso8601String(),
      });

      final updated = await remoteDataSource.getFeedback(feedbackId);
      if (updated == null) {
        return Left(ServerFailure('Feedback not found after update'));
      }
      return Right(updated);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, FeedbackEntity>> respondToReview(
    String feedbackId,
    String response,
  ) async {
    try {
      final now = DateTime.now();
      await remoteDataSource.updateFeedback(feedbackId, {
        'response': response,
        'respondedAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      final updated = await remoteDataSource.getFeedback(feedbackId);
      if (updated == null) {
        return Left(ServerFailure('Feedback not found'));
      }
      return Right(updated);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<FeedbackEntity>>> getSessionFeedback(
      String sessionId) async {
    try {
      final feedbacks =
          await remoteDataSource.fetchFeedbackBySession(sessionId);
      return Right(feedbacks);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
